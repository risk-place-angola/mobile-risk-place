import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/services/notification_service.dart';
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';

/// Provider para gerenciar WebSocket com notificações integradas
final websocketNotificationsProvider =
    Provider<WebSocketNotificationsManager>((ref) {
  final wsService = ref.watch(alertWebSocketServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return WebSocketNotificationsManager(
    wsService: wsService,
    notificationService: notificationService,
  );
});

/// Manager que conecta WebSocket com Notificações
class WebSocketNotificationsManager {
  final AlertWebSocketService wsService;
  final NotificationService notificationService;

  WebSocketNotificationsManager({
    required this.wsService,
    required this.notificationService,
  });

  /// Conecta ao WebSocket e configura notificações
  Future<void> connect() async {
    try {
      // Initialize notifications first
      final initialized = await notificationService.initialize();
      if (!initialized) {
        log('⚠️ Notification service failed to initialize',
            name: 'WSNotifications');
      }

      // Configure WebSocket callbacks
      wsService.onAlertReceived = _handleAlert;
      wsService.onError = _handleError;
      wsService.onConnected = _handleConnected;
      wsService.onDisconnected = _handleDisconnected;

      wsService.connect(
        onAlert: _handleAlert,
        onError: _handleError,
        onConnected: _handleConnected,
        onDisconnected: _handleDisconnected,
      );

      log('✅ WebSocket + Notifications connected', name: 'WSNotifications');
    } catch (e) {
      log('❌ Error connecting: $e', name: 'WSNotifications');
    }
  }

  /// Desconecta do WebSocket
  Future<void> disconnect() async {
    wsService.disconnect();
    log('🔌 WebSocket disconnected', name: 'WSNotifications');
  }

  /// Handler para alertas recebidos
  void _handleAlert(Map<String, dynamic> alert) {
    log('🚨 Alert received: $alert', name: 'WSNotifications');

    try {
      final type = alert['type'] as String?;
      final severity = alert['severity'] as String? ?? 'medium';
      final title = alert['title'] as String? ?? 'Novo Alerta';
      final message =
          alert['message'] as String? ?? 'Você recebeu um novo alerta';

      if (type == 'alert') {
        // Emergency alert - show high priority notification
        notificationService.showAlertNotification(
          title: title,
          message: message,
          severity: severity,
          data: alert,
        );
      } else {
        // Regular report - show normal priority notification
        notificationService.showReportNotification(
          title: title,
          message: message,
          status: 'pending',
          data: alert,
        );
      }
    } catch (e) {
      log('❌ Error handling alert: $e', name: 'WSNotifications');
    }
  }

  /// Handler para erros
  void _handleError(String error) {
    log('❌ WebSocket error: $error', name: 'WSNotifications');

    // Show error notification only for critical issues
    if (error.contains('connection') || error.contains('timeout')) {
      notificationService.showInfoNotification(
        title: 'Erro de Conexão',
        message: 'Tentando reconectar...',
        data: {'error': error},
      );
    }
  }

  /// Handler para conexão estabelecida
  void _handleConnected() {
    log('✅ WebSocket connected', name: 'WSNotifications');

    // Optional: Show success notification
    // notificationService.showInfoNotification(
    //   title: 'Conectado',
    //   message: 'Você está recebendo alertas em tempo real',
    // );
  }

  /// Handler para desconexão
  void _handleDisconnected() {
    log('🔌 WebSocket disconnected', name: 'WSNotifications');
  }

  /// Atualiza localização do usuário (Waze-like)
  void updateLocation(double latitude, double longitude) {
    wsService.updateLocation(latitude, longitude);
  }

  /// Verifica se está conectado
  bool get isConnected => wsService.isConnected;
}

/// Provider para estado de conexão
final websocketConnectionStateProvider = StreamProvider<bool>((ref) async* {
  final manager = ref.watch(websocketNotificationsProvider);

  // Poll connection state every 2 seconds
  while (true) {
    yield manager.isConnected;
    await Future.delayed(const Duration(seconds: 2));
  }
});
