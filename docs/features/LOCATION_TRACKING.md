# Sistema de Rastreamento de Localização e WebSocket

**Risk Place Angola - Mobile App**  
**Versão**: 1.0.0 | **Atualizado**: Novembro 17, 2025

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Implementação](#implementação)
- [Formato de Mensagens](#formato-de-mensagens)
- [Uso Rápido](#uso-rápido)
- [Fluxo Completo](#fluxo-completo)
- [Testes](#testes)
- [Troubleshooting](#troubleshooting)

---

## Visão Geral

Sistema de rastreamento de localização em tempo real com atualizações automáticas via WebSocket, seguindo as melhores práticas de aplicativos como Waze.

### Características
- ✅ Atualizações automáticas quando o usuário se move
- ✅ Precisão de 1 metro (bestForNavigation)
- ✅ WebSocket com formato padrão de mensagens
- ✅ Autenticação automática via AuthTokenManager
- ✅ Timer de 30 segundos para updates periódicos

---

## Arquitetura

### Componentes

```
┌─────────────────────────────────────────────┐
│          LocationController                  │
│  - Gerencia stream de localização           │
│  - Envia updates automáticos ao WebSocket   │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│          LocationService                     │
│  - Solicita permissões GPS                   │
│  - Stream de posições (distanceFilter: 1m)  │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│       AlertWebSocketService                  │
│  - Conecta com /ws/alerts                    │
│  - Formata mensagens update_location         │
│  - Gerencia autenticação                     │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│          Backend WebSocket                   │
│  - Recebe atualizações de localização        │
│  - Envia alertas próximos                    │
└─────────────────────────────────────────────┘
```

### Fluxo de Dados

```
┌──────────────┐
│  GPS Device  │
└──────┬───────┘
       │ Posição muda > 1m
       ▼
┌──────────────────┐
│ Geolocator Stream│
└──────┬───────────┘
       │
       ▼
┌────────────────────┐
│ LocationController │ ◄── Escuta mudanças
│ .currentPosition   │
└──────┬─────────────┘
       │
       │ Se WebSocket conectado
       ▼
┌────────────────────────┐
│ AlertWebSocketService  │
│ .updateLocation()      │
└──────┬─────────────────┘
       │
       │ Formato JSON
       ▼
{
  "event": "update_location",
  "data": {
    "latitude": -8.842560,
    "longitude": 13.300120
  }
}
       │
       ▼
┌──────────────────┐
│ Backend processa │
│ Envia alertas    │
│ próximos         │
└──────────────────┘
```

---

## Implementação

### 1. LocationController

**Arquivo**: `lib/presenter/controllers/location.controller.dart`

```dart
class LocationController extends ChangeNotifier {
  final LocationService _locationService;
  final AlertWebSocketService? _webSocketService;
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;

  void startLocationUpdates() {
    _positionStreamSubscription = _locationService
        .getPositionStream(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1, // Atualiza a cada 1 metro
        )
        .listen((Position position) {
          _currentPosition = position;
          notifyListeners();
          
          log('[LocationController] Position: ${position.latitude}, ${position.longitude}');
          
          // Envia ao WebSocket se conectado
          if (_webSocketService != null && _webSocketService!.isConnected) {
            _webSocketService!.updateLocation(
              position.latitude,
              position.longitude,
            );
            log('[LocationController] Location sent to WebSocket');
          }
        });
  }

  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}
```

### 2. AlertWebSocketService

**Arquivo**: `lib/data/services/alert_websocket_service.dart`

```dart
class AlertWebSocketService {
  WebSocketChannel? _channel;

  void connect({
    String? token,
    String? deviceId,
    Function(Map<String, dynamic>)? onAlert,
  }) {
    final wsUrl = BASE_URL
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    
    final fullUrl = '$wsUrl/ws/alerts';
    
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else if (deviceId != null && deviceId.isNotEmpty) {
      headers['X-Device-ID'] = deviceId;
    }

    _channel = IOWebSocketChannel.connect(
      Uri.parse(fullUrl),
      headers: headers,
    );

    _channel?.stream.listen(
      (message) => _handleMessage(message),
      onDone: () => log('🔌 WebSocket closed'),
      onError: (error) => log('❌ WebSocket error: $error'),
    );
  }

  void updateLocation(double latitude, double longitude) {
    if (_channel == null) {
      log('⚠️ Cannot update location: WebSocket not connected');
      return;
    }

    final locationUpdateData = LocationUpdateData(
      latitude: latitude,
      longitude: longitude,
    );

    final locationMessage = WebSocketMessage(
      event: WebSocketEventType.updateLocation,
      data: locationUpdateData,
    );

    final jsonMessage = jsonEncode(
      locationMessage.toJson((data) => data.toJson()),
    );
    
    _channel?.sink.add(jsonMessage);
    log('📍 Location update sent: ($latitude, $longitude)');
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  bool get isConnected => _channel != null;
}
```

### 3. WebSocket Messages

**Arquivo**: `lib/data/models/websocket/websocket_message.dart`

```dart
class WebSocketMessage<T> {
  final WebSocketEventType event;
  final T data;

  WebSocketMessage({
    required this.event,
    required this.data,
  });

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) => {
    'event': event.value,
    'data': dataToJson(data),
  };
}

class LocationUpdateData {
  final double latitude;
  final double longitude;

  LocationUpdateData({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
```

**Arquivo**: `lib/data/models/enums/websocket_event_type.dart`

```dart
enum WebSocketEventType {
  updateLocation('update_location'),
  newAlert('new_alert'),
  reportCreated('report_created');

  final String value;
  const WebSocketEventType(this.value);
}
```

---

## Formato de Mensagens

### Mensagens Enviadas (Client → Server)

**Atualização de Localização**:
```json
{
  "event": "update_location",
  "data": {
    "latitude": -8.842560,
    "longitude": 13.300120
  }
}
```

### Mensagens Recebidas (Server → Client)

**Novo Alerta**:
```json
{
  "type": "alert",
  "data": {
    "id": "alert-123",
    "message": "Accident nearby",
    "severity": "high",
    "latitude": -8.842000,
    "longitude": 13.300000
  }
}
```

**Novo Report**:
```json
{
  "type": "report",
  "data": {
    "id": "report-456",
    "message": "Pothole on road",
    "latitude": -8.843000,
    "longitude": 13.301000
  }
}
```

---

## Uso Rápido

### Inicializar no HomePage

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Inicia tracking de localização
    ref.read(locationControllerProvider).startLocationUpdates();
  });
}
```

### Conectar WebSocket após Login

```dart
// LoginController
final wsService = ref.read(alertWebSocketProvider);
wsService.connect(
  token: '', // Auto-retrieved from AuthTokenManager
  onAlert: (alertData) {
    showNotification(alertData);
  },
  onConnected: () {
    log('✅ WebSocket connected');
  },
);
```

### Atualização Manual de Localização

```dart
final wsService = ref.read(alertWebSocketProvider);
final position = await Geolocator.getCurrentPosition();

wsService.updateLocation(
  position.latitude,
  position.longitude,
);
```

### Parar Tracking

```dart
ref.read(locationControllerProvider).stopLocationUpdates();
```

---

## Fluxo Completo

```
┌────────────────────────────────────────────────────┐
│            USUÁRIO ABRE O APP                       │
└───────────────────┬────────────────────────────────┘
                    │
                    ▼
            ┌───────────────┐
            │  Login Page   │
            └───────┬───────┘
                    │ Login bem-sucedido
                    ▼
            ┌───────────────┐
            │ AuthTokenManager│ ◄─── Token armazenado
            │ .setToken()   │
            └───────────────┘
                    │
                    ▼
            ┌───────────────┐
            │  Home Page    │
            └───────┬───────┘
                    │ Navega para mapa
                    ▼
┌───────────────────────────────────────────────────┐
│           MAP VIEW CARREGADO                       │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ LocationController   │
         │ .startLocationUpdates│
         └──────┬───────────────┘
                │
    ┌───────────┴───────────┐
    │                       │
    ▼                       ▼
┌──────────┐        ┌──────────────────┐
│LocationSvc│        │AlertWebSocketSvc │
│GPS Stream│        │.connect()        │
└────┬─────┘        └────┬─────────────┘
     │                   │
     │                   │ Token do AuthTokenManager
     │                   ▼
     │          ┌────────────────────┐
     │          │ WebSocket Connected│
     │          │ wss://api/ws/alerts│
     │          └────────────────────┘
     │                   │
     │                   │ ✅ Conectado
     ▼                   ▼
┌────────────────────────────────────┐
│   LOCATION STREAM ATIVO             │
│   • Accuracy: bestForNavigation    │
│   • Distance Filter: 1 meter       │
│   • Updates: Quando usuário move   │
└────────────┬───────────────────────┘
             │
             │ Usuário move > 1m
             ▼
      ┌──────────────┐
      │Position Event│
      │(-8.84, 13.23)│
      └──────┬───────┘
             │
             ▼
  ┌───────────────────────┐
  │LocationController     │
  │recebe position update │
  └──────┬────────────────┘
         │
         │ Verifica se WS conectado
         ▼
  ┌──────────────────────┐
  │wsService.isConnected?│
  └──────┬───────────────┘
         │
         │ SIM ✅
         ▼
  ┌──────────────────────┐
  │wsService.updateLocation│
  │(lat, lon)            │
  └──────┬───────────────┘
         │
         │ Cria mensagem WebSocket
         ▼
  ┌─────────────────────────┐
  │ WebSocketMessage        │
  │ event: update_location  │
  │ data: { lat, lon }      │
  └──────┬──────────────────┘
         │
         │ Serializa JSON
         ▼
  ┌─────────────────────┐
  │ _channel.sink.add() │
  └──────┬──────────────┘
         │
         │ Envia via WebSocket
         ▼
  ┌───────────────────────┐
  │   BACKEND RECEBE      │
  │   1. Atualiza DB      │
  │   2. Calcula alertas  │
  │      próximos         │
  │   3. Envia via WS     │
  └───────┬───────────────┘
          │
          ▼
   ┌─────────────────┐
   │ APP RECEBE      │
   │ ALERTAS         │
   │ PRÓXIMOS        │
   └─────────────────┘
```

---

## Testes

### 1. Iniciar o App

```bash
flutter run
```

### 2. Fazer Login

- Entre com credenciais
- WebSocket deve conectar automaticamente

### 3. Navegar para o Mapa

- Mapa carrega
- Permissão de localização solicitada
- Stream de localização inicia

### 4. Logs Esperados

```
[LocationController] Position stream updated: -8.842560, 13.300120
[LocationController] Location sent to WebSocket
AlertWebSocketService: 📍 Location update sent: (-8.842560, 13.300120)
```

**A cada movimento > 1 metro**, esses logs aparecem novamente.

### Indicadores de Sucesso

✅ **WebSocket Conectado**:
```
AlertWebSocketService: ✅ Retrieved token from AuthTokenManager
AlertWebSocketService: Connecting to WebSocket: wss://api.com/ws/alerts
AlertWebSocketService: Connected to WebSocket successfully
```

✅ **Location Updates**:
```
[LocationController] Position stream updated: LAT, LNG
[LocationController] Location sent to WebSocket
AlertWebSocketService: Updated location: (LAT, LNG)
```

✅ **Mensagem WebSocket Enviada**:
```json
{
  "event": "update_location",
  "data": {
    "latitude": -8.842560,
    "longitude": 13.300120
  }
}
```

### Indicadores de Erro

❌ **Sem Conexão WebSocket**:
```
AlertWebSocketService: ⚠️ No authentication token available
```
**Fix**: Fazer login e garantir que token está salvo

❌ **WebSocket Não Conectado**:
```
AlertWebSocketService: Cannot update location: WebSocket not connected
```
**Fix**: Verificar conexão de rede e URL do WebSocket

❌ **Permissão Negada**:
```
LocationController: Permissão de localização negada
```
**Fix**: Conceder permissão nas configurações do dispositivo

---

## Troubleshooting

### Problema: Localização não atualiza

**Checklist**:
1. ✅ Permissões de localização concedidas?
2. ✅ GPS habilitado no dispositivo?
3. ✅ Stream iniciado? (`startLocationUpdates()` chamado?)
4. ✅ App em foreground?

**Solução**:
```dart
// Verificar permissões
final permission = await Geolocator.checkPermission();
print('Permission: $permission');

// Verificar se stream está ativo
print('Stream active: ${_positionStreamSubscription != null}');
```

### Problema: WebSocket desconecta frequentemente

**Solução**:
- Implementar reconexão automática
- Adicionar heartbeat/ping
- Verificar timeout do servidor

```dart
// Exemplo de reconexão
void _handleReconnect() {
  Timer.periodic(Duration(seconds: 5), (timer) {
    if (!wsService.isConnected) {
      wsService.connect(token: AuthTokenManager().token);
    }
  });
}
```

### Problema: Muitas atualizações (bateria)

**Solução**:
Aumentar `distanceFilter`:

```dart
_locationService.getPositionStream(
  accuracy: LocationAccuracy.best, // Reduzir precisão
  distanceFilter: 10, // 10 metros em vez de 1
)
```

### Problema: Não recebo alertas

**Checklist**:
1. ✅ WebSocket conectado?
2. ✅ Localização sendo atualizada?
3. ✅ Dentro do raio de alertas (1000m)?
4. ✅ Callback `onAlert` configurado?

**Debug**:
```dart
wsService.connect(
  token: '',
  onAlert: (alert) {
    print('🚨 ALERT RECEIVED: $alert');
  },
  onConnected: () {
    print('✅ WS CONNECTED');
  },
  onError: (error) {
    print('❌ WS ERROR: $error');
  },
);
```

---

## Configurações Avançadas

### Personalizar Precisão

```dart
// Máxima precisão (mais bateria)
LocationAccuracy.bestForNavigation

// Boa precisão (balanceado)
LocationAccuracy.best

// Média precisão (economia)
LocationAccuracy.high
```

### Ajustar Frequência de Updates

```dart
// Atualizar apenas com movimento significativo
distanceFilter: 50 // 50 metros

// Atualizar frequentemente
distanceFilter: 1 // 1 metro
```

### Timer de Updates (além do stream)

```dart
Timer.periodic(Duration(seconds: 30), (_) async {
  final position = await _locationService.getCurrentPosition();
  wsService.updateLocation(position.latitude, position.longitude);
});
```

---

## Referências

- [Geolocator Package](https://pub.dev/packages/geolocator)
- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)
- [WebSocket Guide](../websocket/WEBSOCKET_GUIDE.md)
- [Anonymous Users](ANONYMOUS_USERS.md)
