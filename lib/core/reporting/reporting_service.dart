import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:route_flow/core/config/app_config.dart';

@singleton
class ReportingService {
  bool get isEnabled => AppConfig.sentryDsn.isNotEmpty;

  Future<void> reportError(dynamic error, dynamic stackTrace, {String? hint}) async {
    if (!isEnabled) {
      debugPrint('[ReportingService] Reporting disabled. Error: $error');
      return;
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (hint != null) scope.setTag('hint', hint);
      },
    );
  }

  void addBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    if (!isEnabled) return;
    
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  void setUserContext(String userId, {String? email}) {
    if (!isEnabled) return;
    
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }
}
