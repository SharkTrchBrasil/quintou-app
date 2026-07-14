import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // User properties
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  static Future<void> setUserProperties({
    required bool isHost,
    String? kycStatus,
  }) async {
    await _analytics.setUserProperty(name: 'is_host', value: isHost.toString());
    if (kycStatus != null) {
      await _analytics.setUserProperty(name: 'kyc_status', value: kycStatus);
    }
  }

  static Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
    await _crashlytics.setUserIdentifier('');
  }

  // Screen tracking
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Auth events
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Booking events
  static Future<void> logBookingCreated({
    required String spaceId,
    required double totalPrice,
    required int hours,
  }) async {
    await _analytics.logEvent(
      name: 'booking_created',
      parameters: {
        'space_id': spaceId,
        'total_price': totalPrice,
        'hours': hours,
      },
    );
  }

  static Future<void> logBookingCancelled({
    required String bookingId,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'booking_cancelled',
      parameters: {
        'booking_id': bookingId,
        'reason': reason,
      },
    );
  }

  // Space events
  static Future<void> logSpaceViewed(String spaceId) async {
    await _analytics.logEvent(
      name: 'space_viewed',
      parameters: {'space_id': spaceId},
    );
  }

  static Future<void> logSpaceCreated(String spaceId) async {
    await _analytics.logEvent(
      name: 'space_created',
      parameters: {'space_id': spaceId},
    );
  }

  // Search events
  static Future<void> logSearch(String query, {String? category}) async {
    await _analytics.logSearch(searchTerm: query);
    if (category != null) {
      await _analytics.logEvent(
        name: 'search_with_category',
        parameters: {
          'query': query,
          'category': category,
        },
      );
    }
  }

  // Chat events
  static Future<void> logMessageSent(String conversationId) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {'conversation_id': conversationId},
    );
  }

  // Error tracking
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: context,
      information: additionalData?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    );
  }

  // Custom events
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Breadcrumbs for debugging
  static Future<void> logBreadcrumb(String message) async {
    await _crashlytics.log(message);
  }
}
