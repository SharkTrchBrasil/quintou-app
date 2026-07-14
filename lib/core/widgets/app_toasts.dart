import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

Function showLoading({String? message}) {
  final cancelLoading = BotToast.showCustomLoading(
    toastBuilder: (_) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const CircularProgressIndicator(
          color: Color(0xFF00AEEF), // Cor Quintou Azul
        ),
      );
    },
    clickClose: false,
  );
  return cancelLoading;
}

Function showError(
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  return BotToast.showText(
    text: message,
    contentColor: Colors.red,
    duration: duration,
  );
}

Function showSuccess(
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  return BotToast.showText(
    text: message,
    contentColor: Colors.blue,
    duration: duration,
  );
}

Function showInfo(
    String message, {
      Duration duration = const Duration(seconds: 3),
    }) {
  return BotToast.showText(
    text: message,
    contentColor: Colors.amber, 
    duration: duration,
  );
}
