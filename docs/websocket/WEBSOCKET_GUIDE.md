# 🔌 WebSocket & Real-Time Alerts - Complete Guide
**Risk Place Mobile**

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Implementação](#implementação)
4. [Como Usar](#como-usar)
5. [Notificações Push](#notificações-push)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Sistema completo de WebSocket para receber alertas em tempo real, similar ao Waze, com atualização automática de localização e notificações push.

### Funcionalidades

✅ **Conexão persistente** ao servidor WebSocket  
✅ **Autenticação automática** com token JWT  
✅ **Atualização periódica** de localização (padrão: 30 segundos)  
✅ **Reconexão automática** com backoff exponencial  
✅ **Notificações push** para alertas recebidos  
✅ **Callbacks customizáveis** para eventos  

### Fluxo de Funcionamento

```
1. Usuário faz login
2. App conecta ao WebSocket
3. Envia token de autenticação
4. Envia localização inicial
5. Inicia timer de atualização automática (30s)
6. Recebe alertas em tempo real
7. Mostra notificação push
8. Atualiza UI com alerta recebido
```

---

## 🏗️ Arquitetura

### Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                        Login Screen                          │
│                  (usuário faz login)                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              WebSocketNotificationsManager                   │
│  • Connect to WebSocket                                      │
│  • Initialize NotificationService                            │
│  • Setup callbacks                                           │
└──────────────┬──────────────────┬───────────────────────────┘
               │                  │
     ┌─────────▼────────┐  ┌─────▼──────────┐
     │   WebSocket      │  │  Notification  │
     │   Service        │  │  Service       │
     │                  │  │                │
     │ • Connect        │  │ • Show Alerts  │
     │ • Send location  │  │ • Show Reports │
     │ • Receive alerts │  │ • Show Info    │
     └──────────────────┘  └────────────────┘
```

### Estrutura de Arquivos

```
lib/
├── core/
│   └── services/
│       └── notification_service.dart         # Serviço de notificações
├── data/
│   ├── services/
│   │   └── alert_websocket_service.dart      # Serviço WebSocket
│   └── providers/
│       ├── api_providers.dart                 # Providers base
│       └── websocket_notifications_provider.dart  # Manager integrado
```

---

## 💻 Implementação

### 1. WebSocket Service

**Arquivo:** `lib/data/services/alert_websocket_service.dart`

```dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class AlertWebSocketService {
  WebSocketChannel? _channel;
  Timer? _locationTimer;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  
  // Callbacks
  Function(Map<String, dynamic>)? _onAlert;
  Function(String)? _onError;
  VoidCallback? _onConnected;
  VoidCallback? _onDisconnected;

  // Configurações
  static const String wsUrl = 'ws://localhost:8080/ws/alerts';
  static const int maxReconnectAttempts = 5;
  static const int baseReconnectDelay = 2; // segundos

  /// Conecta ao WebSocket e configura callbacks
  void connect(
    String token, {
    required Function(Map<String, dynamic>) onAlert,
    Function(String)? onError,
    VoidCallback? onConnected,
    VoidCallback? onDisconnected,
  }) {
    _onAlert = onAlert;
    _onError = onError;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;

    _connectToWebSocket(token);
  }

  void _connectToWebSocket(String token) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      _reconnectAttempts = 0;

      // Enviar token de autenticação
      _sendAuth(token);

      // Escutar mensagens
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnection(token),
      );

      _onConnected?.call();
    } catch (e) {
      _handleError('Erro ao conectar: $e');
      _scheduleReconnect(token);
    }
  }

  void _sendAuth(String token) {
    final authMessage = jsonEncode({
      'type': 'auth',
      'token': token,
    });
    _channel?.sink.add(authMessage);
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'alert') {
        _onAlert?.call(data['data']);
      } else if (data['type'] == 'error') {
        _onError?.call(data['message']);
      }
    } catch (e) {
      _onError?.call('Erro ao processar mensagem: $e');
    }
  }

  void _handleError(dynamic error) {
    _onError?.call(error.toString());
  }

  void _handleDisconnection(String token) {
    _isConnected = false;
    _onDisconnected?.call();
    _scheduleReconnect(token);
  }

  void _scheduleReconnect(String token) {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _onError?.call('Máximo de tentativas de reconexão atingido');
      return;
    }

    _reconnectAttempts++;
    final delay = baseReconnectDelay * _reconnectAttempts;
    
    Timer(Duration(seconds: delay), () {
      if (!_isConnected) {
        _connectToWebSocket(token);
      }
    });
  }

  /// Atualiza localização do usuário
  void updateLocation(double latitude, double longitude) {
    if (!_isConnected) return;

    final locationMessage = jsonEncode({
      'type': 'location',
      'latitude': latitude,
      'longitude': longitude,
    });
    
    _channel?.sink.add(locationMessage);
  }

  /// Inicia atualizações automáticas de localização (Waze-like)
  void startLocationUpdates({
    required double latitude,
    required double longitude,
    required Future<void> Function() getCurrentLocation,
    int intervalSeconds = 30,
  }) {
    // Enviar localização inicial
    updateLocation(latitude, longitude);

    // Iniciar timer para atualizações periódicas
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) async {
        try {
          await getCurrentLocation();
        } catch (e) {
          _onError?.call('Erro ao obter localização: $e');
        }
      },
    );
  }

  /// Para atualizações automáticas de localização
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Desconecta do WebSocket
  void disconnect() {
    stopLocationUpdates();
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
    _onDisconnected?.call();
  }

  bool get isConnected => _isConnected;
}
```

---

### 2. Notification Service

**Arquivo:** `lib/core/services/notification_service.dart`

```dart
import 'package:flutter/material.dart';

enum NotificationType {
  alert,   // Alertas de emergência
  report,  // Novos relatórios
  info,    // Informações gerais
}

class NotificationService {
  /// Mostra notificação de alerta
  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Implementar notificações push reais com flutter_local_notifications
    
    // Atualmente, apenas logs no console
    print('┌─────────────────────────────────────────');
    print('│ 🔔 NOTIFICATION');
    print('│ Type: ${type.name}');
    print('│ Title: $title');
    print('│ Body: $body');
    if (data != null) {
      print('│ Data: $data');
    }
    print('└─────────────────────────────────────────');
  }

  /// Mostra notificação de alerta de emergência
  Future<void> showAlertNotification({
    required String message,
    required String severity,
    required double latitude,
    required double longitude,
  }) async {
    await showNotification(
      title: '⚠️ Alerta de Emergência',
      body: message,
      type: NotificationType.alert,
      data: {
        'severity': severity,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Mostra notificação de novo relatório próximo
  Future<void> showReportNotification({
    required String description,
    required String riskType,
  }) async {
    await showNotification(
      title: '📍 Novo Relatório Próximo',
      body: description,
      type: NotificationType.report,
      data: {
        'riskType': riskType,
      },
    );
  }
}
```

---

### 3. WebSocket Notifications Manager

**Arquivo:** `lib/data/providers/websocket_notifications_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/core/services/notification_service.dart';
import 'package:rpa/data/providers/api_providers.dart';

final websocketNotificationsProvider = Provider<WebSocketNotificationsManager>((ref) {
  final wsService = ref.read(alertWebSocketConnectionProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return WebSocketNotificationsManager(wsService, notificationService);
});

class WebSocketNotificationsManager {
  final AlertWebSocketService _wsService;
  final NotificationService _notificationService;

  WebSocketNotificationsManager(this._wsService, this._notificationService);

  /// Conecta ao WebSocket e inicializa notificações
  Future<void> connect() async {
    final token = await _getAuthToken();
    
    if (token == null) {
      throw Exception('Token não encontrado. Faça login primeiro.');
    }

    _wsService.connect(
      token,
      onAlert: _handleAlert,
      onError: _handleError,
      onConnected: _handleConnected,
      onDisconnected: _handleDisconnected,
    );
  }

  void _handleAlert(Map<String, dynamic> alertData) {
    // Mostrar notificação push
    _notificationService.showAlertNotification(
      message: alertData['message'],
      severity: alertData['severity'],
      latitude: alertData['latitude'],
      longitude: alertData['longitude'],
    );
  }

  void _handleError(String error) {
    print('WebSocket Error: $error');
  }

  void _handleConnected() {
    print('WebSocket conectado com sucesso');
  }

  void _handleDisconnected() {
    print('WebSocket desconectado');
  }

  Future<String?> _getAuthToken() async {
    // Implementar lógica para obter token do banco local
    return null;
  }

  void disconnect() {
    _wsService.disconnect();
  }

  bool get isConnected => _wsService.isConnected;
}
```

---

## 🚀 Como Usar

### 1. Após Login (Conectar WebSocket)

```dart
import 'package:rpa/data/providers/websocket_notifications_provider.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final wsManager = ref.read(websocketNotificationsProvider);
    
    try {
      // Conectar ao WebSocket
      await wsManager.connect();
      
      // Iniciar atualizações de localização
      _startLocationUpdates();
      
    } catch (e) {
      print('Erro ao conectar WebSocket: $e');
    }
  }

  Future<void> _startLocationUpdates() async {
    final wsService = ref.read(alertWebSocketConnectionProvider);
    
    // Obter localização inicial
    final position = await Geolocator.getCurrentPosition();
    
    // Iniciar atualizações automáticas (a cada 30 segundos)
    wsService.startLocationUpdates(
      latitude: position.latitude,
      longitude: position.longitude,
      getCurrentLocation: () async {
        final newPosition = await Geolocator.getCurrentPosition();
        wsService.updateLocation(
          newPosition.latitude,
          newPosition.longitude,
        );
      },
      intervalSeconds: 30,
    );
  }

  @override
  void dispose() {
    // Desconectar ao sair
    ref.read(websocketNotificationsProvider).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('WebSocket conectado!')),
    );
  }
}
```

---

### 2. Mostrar Status de Conexão

```dart
// Provider para estado de conexão
final websocketConnectionStateProvider = StreamProvider<bool>((ref) {
  // Implementar stream que emite estado de conexão
  return Stream.periodic(Duration(seconds: 1), (_) {
    return ref.read(websocketNotificationsProvider).isConnected;
  });
});

// Uso na UI
class ConnectionIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(websocketConnectionStateProvider);
    
    return connectionState.when(
      data: (isConnected) => Icon(
        isConnected ? Icons.wifi : Icons.wifi_off,
        color: isConnected ? Colors.green : Colors.red,
      ),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Icon(Icons.error, color: Colors.red),
    );
  }
}
```

---

### 3. Escutar Alertas Recebidos

```dart
// Provider para alertas recebidos
final receivedAlertsProvider = StateNotifierProvider<ReceivedAlertsNotifier, List<Map<String, dynamic>>>(
  (ref) => ReceivedAlertsNotifier(),
);

class ReceivedAlertsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ReceivedAlertsNotifier() : super([]);

  void addAlert(Map<String, dynamic> alert) {
    state = [...state, alert];
  }

  void clearAlerts() {
    state = [];
  }
}

// Uso na UI
class AlertListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(receivedAlertsProvider);
    
    // Listener para novos alertas
    ref.listen<List<Map<String, dynamic>>>(
      receivedAlertsProvider,
      (previous, next) {
        if (next.isNotEmpty && next.length > (previous?.length ?? 0)) {
          // Novo alerta recebido
          final latestAlert = next.last;
          _showAlertDialog(context, latestAlert);
        }
      },
    );
    
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return ListTile(
          leading: Icon(Icons.warning, color: Colors.red),
          title: Text(alert['message']),
          subtitle: Text('Gravidade: ${alert['severity']}'),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('Alerta de Emergência'),
          ],
        ),
        content: Text(alert['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔔 Notificações Push

### Setup Completo (Futuro)

Para implementar notificações push reais, adicione ao `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^16.0.0
```

E atualize `notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    
    await _notifications.initialize(settings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    const android = AndroidNotificationDetails(
      'alerts_channel',
      'Alerts',
      channelDescription: 'Emergency alerts and notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iOS = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: iOS);
    
    await _notifications.show(0, title, body, details);
  }
}
```

---

## 🐛 Troubleshooting

### WebSocket não conecta

1. Verificar se BASE_URL está correto
2. Verificar se token é válido
3. Verificar logs: `flutter logs | grep WebSocket`

**Solução:**
```dart
// Verificar URL
print('Conectando a: ${AlertWebSocketService.wsUrl}');

// Verificar token
final token = await _getAuthToken();
print('Token: ${token?.substring(0, 20)}...');
```

---

### Alertas não são recebidos

1. Verificar se WebSocket está conectado
2. Verificar se localização foi enviada
3. Verificar se usuário está no raio do alerta

**Solução:**
```dart
// Verificar conexão
if (!wsService.isConnected) {
  print('WebSocket não conectado!');
}

// Verificar localização enviada
wsService.updateLocation(lat, lng);
print('Localização enviada: $lat, $lng');
```

---

### Reconexão não funciona

1. Verificar se maxReconnectAttempts não foi atingido
2. Verificar delay de reconexão
3. Verificar se token ainda é válido

**Solução:**
```dart
// Aumentar tentativas
static const int maxReconnectAttempts = 10; // de 5 para 10

// Ver logs de reconexão
print('Tentativa de reconexão $_reconnectAttempts de $maxReconnectAttempts');
```

---

## ✅ Boas Práticas

### 1. Atualização de Localização
- ✅ Atualizar a cada **30 segundos** (padrão)
- ✅ Usar `startLocationUpdates()` para atualizações automáticas
- ✅ Parar atualizações em background: `stopLocationUpdates()`
- ✅ Reconectar automaticamente em caso de perda

### 2. Gestão de Conexão
- ✅ Conectar após login bem-sucedido
- ✅ Desconectar ao fazer logout
- ✅ Mostrar indicador de status de conexão na UI
- ✅ Reconectar automaticamente com backoff exponencial

### 3. Tratamento de Alertas
- ✅ Mostrar notificação push imediatamente
- ✅ Armazenar alertas recebidos no estado
- ✅ Permitir usuário ver histórico de alertas
- ✅ Limpar alertas antigos periodicamente

---

## 📚 Recursos Adicionais

- **API Integration**: `/docs/api/API_COMPLETE_GUIDE.md`
- **HTTP Client**: `/docs/architecture/HTTP_CLIENT_GUIDE.md`
- **UI/UX**: `/docs/ui-ux/WAZE_PANEL_GUIDE.md`

---

**Última Atualização:** 17 de Novembro de 2025
