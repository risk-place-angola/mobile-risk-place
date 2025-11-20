import 'package:rpa/domain/entities/user_alert.dart';

abstract class IAlertRepository {
  Future<List<UserAlert>> getMyAlerts();

  Future<List<UserAlert>> getSubscribedAlerts();

  Future<UserAlert> updateAlert({
    required String alertId,
    required String message,
    required AlertSeverity severity,
    required int radiusMeters,
  });

  Future<void> deleteAlert(String alertId);

  Future<void> subscribeToAlert(String alertId);

  Future<void> unsubscribeFromAlert(String alertId);
}
