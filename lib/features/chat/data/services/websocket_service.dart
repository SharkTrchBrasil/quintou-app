import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:quintou_app/core/services/secure_storage_service.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/features/chat/data/models/message_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, String>>.broadcast();
  
  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal() {
    SystemChannels.lifecycle.setMessageHandler(_handleAppLifecycle);
  }
  
  bool _isConnected = false;
  bool _isReconnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  // Exponential backoff delays in seconds: 1, 2, 4, 8, 16, 30, 60
  static const _backoffDelays = [1, 2, 4, 8, 16, 30, 60];
  static const _maxReconnectAttempts = 10;
  static const _heartbeatInterval = Duration(seconds: 30);



  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<Map<String, String>> get typingStream => _typingController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _isReconnecting) return;

    _isReconnecting = true;
    _shouldReconnect = true;

    try {
      final token = await SecureStorageService.getAccessToken();
      if (token == null) {
        print('No access token found for WebSocket connection');
        _isReconnecting = false;
        return;
      }
      
      // Convert https:// URL to wss:// or http to ws
      final wsUrl = ApiClient.baseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/ws/chat?token=$token');

      print('Connecting to WebSocket: $uri');
      _channel = WebSocketChannel.connect(uri);
      
      await _channel!.ready;
      _isConnected = true;
      _isReconnecting = false;
      _reconnectAttempts = 0;
      
      print('WebSocket connected successfully');
      
      // Start heartbeat
      _startHeartbeat();

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      _isConnected = false;
      _isReconnecting = false;
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final payload = jsonDecode(data);
      
      if (payload['type'] == 'new_message') {
        final message = ChatMessage.fromJson(payload['data']);
        _messageController.add(message);
      } else if (payload['type'] == 'user_typing') {
        _typingController.add({
          'user_id': payload['user_id'].toString(),
          'conversation_id': payload['conversation_id'].toString(),
        });
      } else if (payload['type'] == 'pong') {
        // Heartbeat response - connection is alive
        print('Received pong from server');
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _stopHeartbeat();
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached. Giving up.');
      return;
    }

    final delayIndex = _reconnectAttempts < _backoffDelays.length 
        ? _reconnectAttempts 
        : _backoffDelays.length - 1;
    final delay = Duration(seconds: _backoffDelays[delayIndex]);
    
    print('Scheduling reconnect in ${delay.inSeconds}s (attempt ${_reconnectAttempts + 1})');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        _sendRaw('{"type": "ping"}');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<String?> _handleAppLifecycle(String? lifecycle) async {
    if (lifecycle == null) return null;
    
    print('App lifecycle changed: $lifecycle');
    
    switch (lifecycle) {
      case 'AppLifecycleState.resumed':
        // App came back to foreground - reconnect if needed
        if (!_isConnected && _shouldReconnect) {
          _reconnectAttempts = 0; // Reset attempts on resume
          await connect();
        }
        break;
      case 'AppLifecycleState.paused':
        // App went to background - we'll let the connection live
        // but stop heartbeat to save battery
        _stopHeartbeat();
        break;
      case 'AppLifecycleState.detached':
        // App is being killed
        _shouldReconnect = false;
        disconnect();
        break;
    }
    return null;
  }

  void sendMessage(String conversationId, String content) {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({
        'type': 'send_message',
        'conversation_id': conversationId,
        'content': content,
      });
      _sendRaw(payload);
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }

  void sendTypingIndicator(String conversationId) {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({
        'type': 'typing',
        'conversation_id': conversationId,
      });
      _sendRaw(payload);
    }
  }

  void _sendRaw(String data) {
    try {
      _channel?.sink.add(data);
    } catch (e) {
      print('Error sending WebSocket data: $e');
      _handleDisconnection();
    }
  }

  void disconnect() {
    print('Disconnecting WebSocket');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    SystemChannels.lifecycle.setMessageHandler(null);
  }
}
