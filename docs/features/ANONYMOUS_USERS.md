# Sistema de Usuários Anônimos

**Risk Place Angola - Mobile App**  
**Versão**: 1.0.0 | **Atualizado**: Novembro 17, 2025

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Implementação Mobile](#implementação-mobile)
- [API Endpoints](#api-endpoints)
- [WebSocket](#websocket)
- [Arquivos do Projeto](#arquivos-do-projeto)
- [Comparação Autenticado vs Anônimo](#comparação)
- [Boas Práticas](#boas-práticas)
- [Troubleshooting](#troubleshooting)

---

## Visão Geral

O sistema Risk Place Angola suporta **usuários anônimos** (não autenticados) que podem receber notificações de alertas e reports sem necessidade de criar conta ou fazer login, similar ao funcionamento do Waze.

### Características
- ✅ Uso imediato sem cadastro
- ✅ Recebe alertas e reports próximos em tempo real
- ✅ Push notifications via FCM
- ✅ WebSocket para comunicação bidirecional
- ✅ Rastreamento de localização com consentimento
- ❌ Não pode criar conteúdo (apenas recebe)

---

## Arquitetura

### Fluxo Completo

```
┌─────────────────────┐
│   Mobile App        │
│   (Sem Login)       │
└──────────┬──────────┘
           │
           │ 1. Gera Device ID (UUID v4)
           │    Armazena em SharedPreferences
           ▼
┌─────────────────────┐
│  DeviceIdManager    │
│  Persistente        │
└──────────┬──────────┘
           │
           │ 2. POST /api/v1/devices/register
           │    { device_id, fcm_token, location }
           ▼
┌─────────────────────┐
│   Backend API       │
│   Cria/Atualiza     │
│   AnonymousSession  │
└──────────┬──────────┘
           │
           │ 3. WebSocket Connect
           │    Header: X-Device-ID: <uuid>
           ▼
┌─────────────────────┐
│  WebSocket Server   │
│  Registra Cliente   │
│  Anônimo            │
└──────────┬──────────┘
           │
           │ 4. Timer 30s
           │    Atualiza localização
           ▼
┌─────────────────────┐
│  Location Service   │
│  GPS Tracking       │
└──────────┬──────────┘
           │
           │ 5. Recebe Notificações
           │    - Alertas próximos
           │    - Reports próximos
           ▼
┌─────────────────────┐
│  Push Notifications │
│  (FCM - Offline)    │
└─────────────────────┘
```

### Componentes Mobile

1. **DeviceIdManager** - Gera e persiste UUID v4
2. **DeviceService** - Comunicação HTTP com backend
3. **AnonymousUserManager** - Orquestrador principal
4. **AlertWebSocketService** - Conexão WebSocket com device_id
5. **LocationService** - Rastreamento GPS

---

## Implementação Mobile

### 1. Estrutura de Arquivos

```
lib/
├── core/
│   ├── device/
│   │   └── device_id_manager.dart          ✅ Gerencia Device ID
│   └── managers/
│       └── anonymous_user_manager.dart     ✅ Orquestrador
├── data/
│   ├── dtos/
│   │   └── device_dto.dart                 ✅ DTOs de Device
│   └── services/
│       ├── device.service.dart             ✅ HTTP Client
│       └── alert_websocket_service.dart    ✅ WebSocket
```

### 2. DeviceIdManager

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdManager {
  static const String _deviceIdKey = 'device_id';
  String? _cachedDeviceId;

  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
  }
}
```

### 3. Device DTOs

```dart
class DeviceRegisterRequestDTO {
  final String deviceId;
  final String? fcmToken;
  final String platform;
  final double? latitude;
  final double? longitude;
  final int alertRadiusMeters;

  DeviceRegisterRequestDTO({
    required this.deviceId,
    this.fcmToken,
    String? platform,
    this.latitude,
    this.longitude,
    this.alertRadiusMeters = 1000,
  }) : platform = platform ?? (Platform.isIOS ? 'ios' : 'android');

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    if (fcmToken != null) 'fcm_token': fcmToken,
    'platform': platform,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'alert_radius_meters': alertRadiusMeters,
  };
}
```

### 4. AnonymousUserManager

```dart
class AnonymousUserManager {
  final DeviceIdManager _deviceIdManager = DeviceIdManager();
  final DeviceService _deviceService;
  final AlertWebSocketService _wsService;
  final LocationService _locationService;
  
  String? _deviceId;
  Timer? _locationUpdateTimer;

  Future<void> initialize() async {
    // 1. Gerar/obter device ID
    _deviceId = await _deviceIdManager.getDeviceId();
    
    // 2. Solicitar permissão de localização
    await _locationService.handleLocationPermission();
    
    // 3. Obter FCM token
    final fcmToken = await _getFCMToken();
    
    // 4. Registrar dispositivo no backend
    await _registerDevice(fcmToken);
    
    // 5. Conectar WebSocket
    await _connectWebSocket();
    
    // 6. Iniciar rastreamento de localização
    _startLocationTracking();
  }

  Future<void> _registerDevice(String? fcmToken) async {
    final position = await _locationService.getCurrentPosition();
    
    final request = DeviceRegisterRequestDTO(
      deviceId: _deviceId!,
      fcmToken: fcmToken,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
    
    await _deviceService.registerDevice(request: request);
  }

  Future<void> _connectWebSocket() async {
    _wsService.connect(
      deviceId: _deviceId,
      onAlert: (alert) => log('🚨 Alert: ${alert['message']}'),
      onError: (error) => log('❌ Error: $error'),
    );
  }

  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          // Atualiza via WebSocket
          _wsService.updateLocation(position.latitude, position.longitude);
          
          // Atualiza via HTTP
          await _deviceService.updateLocation(
            request: UpdateDeviceLocationDTO(
              deviceId: _deviceId!,
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
        }
      },
    );
  }

  void dispose() {
    _locationUpdateTimer?.cancel();
    _wsService.disconnect();
  }
}
```

### 5. Integração na HomePage

```dart
class HomePage extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnonymousUser();
    });
  }

  Future<void> _initializeAnonymousUser() async {
    try {
      await ref.read(anonymousUserManagerProvider).initialize();
      log('✅ Anonymous user initialized');
    } catch (e) {
      log('❌ Error initializing anonymous user: $e');
    }
  }
}
```

---

## API Endpoints

### 1. Registrar Dispositivo

```http
POST /api/v1/devices/register
Content-Type: application/json

{
  "device_id": "550e8400-e29b-41d4-a716-446655440000",
  "fcm_token": "dQw4w9WgXcQ:APA91b...",
  "platform": "android",
  "latitude": -8.8383,
  "longitude": 13.2344,
  "alert_radius_meters": 1000
}
```

**Response** (200 OK):
```json
{
  "device_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Device registered successfully"
}
```

### 2. Atualizar Localização

```http
PUT /api/v1/devices/location
Content-Type: application/json

{
  "device_id": "550e8400-e29b-41d4-a716-446655440000",
  "latitude": -8.8400,
  "longitude": 13.2350
}
```

**Response** (200 OK):
```json
{
  "message": "Location updated successfully"
}
```

---

## WebSocket

### Conexão Anônima

```
ws://host:port/ws/alerts
Header: X-Device-ID: 550e8400-e29b-41d4-a716-446655440000
```

### Mensagens Recebidas

**Novo Alerta**:
```json
{
  "type": "alert",
  "data": {
    "id": "abc-123",
    "message": "🚨 Assalto reportado na área",
    "latitude": -8.8390,
    "longitude": 13.2345,
    "severity": "high"
  }
}
```

**Novo Report**:
```json
{
  "type": "report",
  "data": {
    "id": "def-456",
    "message": "📍 Buraco na via",
    "latitude": -8.8395,
    "longitude": 13.2348
  }
}
```

### Mensagens Enviadas

**Atualização de Localização**:
```json
{
  "event": "update_location",
  "data": {
    "latitude": -8.8400,
    "longitude": 13.2350
  }
}
```

---

## Arquivos do Projeto

### ✅ Arquivos Criados

```
lib/core/device/device_id_manager.dart
lib/core/managers/anonymous_user_manager.dart
lib/data/dtos/device_dto.dart
lib/data/services/device.service.dart
docs/features/ANONYMOUS_USERS.md
```

### 📝 Arquivos Modificados

```
lib/data/services/alert_websocket_service.dart
  - Suporte a deviceId na conexão
  - Header X-Device-ID

lib/presenter/pages/home_page/home.page.dart
  - Inicialização do AnonymousUserManager

lib/presenter/controllers/login.controller.dart
  - Reconexão WebSocket com JWT após login

pubspec.yaml
  - shared_preferences: ^2.2.2
  - firebase_messaging: ^16.0.4
```

---

## Comparação

| Funcionalidade | Usuário Autenticado | Usuário Anônimo |
|----------------|---------------------|-----------------|
| **Receber Alertas** | ✅ Sim | ✅ Sim |
| **Receber Reports** | ✅ Sim | ✅ Sim |
| **WebSocket** | 🔑 JWT Token | 🆔 Device ID |
| **Push Notifications** | ✅ Sim | ✅ Sim |
| **Criar Alertas** | ✅ Sim | ❌ Não |
| **Criar Reports** | ✅ Sim | ❌ Não |
| **Comentar** | ✅ Sim | ❌ Não |
| **Histórico** | ✅ Sim | ❌ Não |
| **Perfil** | ✅ Sim | ❌ Não |

### Upgrade Anônimo → Autenticado

Quando o usuário faz login:

```dart
// LoginController
onSuccess: () {
  // Desconecta WebSocket anônimo
  wsService.disconnect();
  
  // Reconecta com JWT
  wsService.connect(
    token: '', // Pega do AuthTokenManager
    onAlert: (alert) => log('🚨 Alert: ${alert['message']}'),
  );
}
```

---

## Boas Práticas

### ✅ Device ID
- Usar UUID v4 (36 caracteres)
- Persistir em SharedPreferences
- Nunca regenerar após instalação
- Cache em memória para performance

### ✅ Localização
- Solicitar permissão explícita
- Atualizar a cada 30 segundos
- Parar em background (economia bateria)
- Usar `distanceFilter: 1m` para precisão

### ✅ WebSocket
- Reconexão automática com backoff
- Desconectar em background
- Heartbeat a cada 30s

### ✅ FCM Token
- Atualizar quando mudar
- Reenviar ao backend
- Tratar mensagens em background

---

## Troubleshooting

### ❌ Não recebo notificações

**Checklist**:
1. Device ID está persistente?
2. FCM token válido?
3. Localização atualizando?
4. WebSocket conectado?
5. Dentro do raio (1000m)?

**Logs esperados**:
```
✅ FCM token obtained: <token>
✅ Device registered
✅ WebSocket connected
📍 Location sent to WebSocket: (-8.838, 13.234)
```

### ❌ WebSocket desconecta

**Solução**:
- Verificar rede
- Implementar retry com backoff
- Verificar timeout do servidor

### ❌ Localização não atualiza

**Solução**:
- Permissões concedidas?
- GPS habilitado?
- Timer rodando?
- Verificar logs: `[LocationController] Position stream updated`

---

## Segurança

### Limitações de Usuários Anônimos

- ✅ Receber notificações passivamente
- ❌ Criar alertas/reports
- ❌ Comentar ou interagir
- ❌ Acessar histórico

### Limpeza Automática

Sessões anônimas inativas por **30 dias** são removidas automaticamente pelo backend.

---

## Referências

- [Firebase Cloud Messaging](../setup/FCM_IOS_SETUP.md)
- [WebSocket Guide](../websocket/WEBSOCKET_GUIDE.md)
- [API Complete Guide](../api/API_COMPLETE_GUIDE.md)
