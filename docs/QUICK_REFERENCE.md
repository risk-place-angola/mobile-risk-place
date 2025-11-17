# ⚡ Quick Reference# ⚡ Quick Reference Guide# 🚀 Quick Reference - Backend Integration



**Risk Place Mobile - Cheat Sheet Completo****Risk Place Mobile - Cheat Sheet**



---## Imports Essenciais



## 📋 Índice## 📋 Índice Rápido



- [Auth](#-autenticação)```dart

- [Risk Types](#-risk-types)

- [Reports](#-reports)- [Authentication](#authentication)// Auth Token Manager

- [WebSocket](#-websocket)

- [Location](#-localização)- [API Calls](#api-calls)import 'package:rpa/data/providers/repository_providers.dart';

- [UI Panel](#-ui-panel)

- [Error Handling](#-error-handling)- [WebSocket](#websocket)

- [Providers](#-providers)

- [Widgets](#-widgets)- [UI Panel Control](#ui-panel-control)// Controllers



---- [Error Handling](#error-handling)import 'package:rpa/presenter/controllers/risk_types.controller.dart';



## 🔐 Autenticação- [Providers](#providers)import 'package:rpa/presenter/controllers/create_report.controller.dart';



### Loginimport 'package:rpa/presenter/controllers/nearby_reports.controller.dart';

```dart

AuthTokenManager().setToken(token);---

await ref.read(riskTypesControllerProvider).initialize();

```// DTOs



### Logout## 🔐 Authenticationimport 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';

```dart

AuthTokenManager().clearToken();```

ref.read(alertWebSocketProvider).disconnect();

```### Login (3 linhas)



### Check Token---

```dart

final hasToken = AuthTokenManager().hasToken; // bool```dart

```

final authService = ref.read(authServiceProvider);## 🔐 Auth Token (1 linha)

---

final user = await authService.login(user: LoginRequestDTO(...));

## 📋 Risk Types

// Token é salvo automaticamente```dart

### Inicializar

```dart```// Login

await ref.read(riskTypesControllerProvider).initialize();

```AuthTokenManager().setToken(token);



### Obter ID### Logout (2 linhas)

```dart

final typeId = ref.read(riskTypesControllerProvider)// Logout

    .getRiskTypeId('crime');

```dartAuthTokenManager().clearToken();

final topicId = ref.read(riskTypesControllerProvider)

    .getRiskTopicId('roubo');ref.read(alertWebSocketConnectionProvider).disconnect();

```

await ref.read(authServiceProvider).logout();// Check

### Types Disponíveis

``````AuthTokenManager().hasToken;

crime, accident, natural_disaster, fire, health, 

infrastructure, environment```

```

### Check Token

### Topics por Type

- **crime**: roubo, assalto, furtos, vandalismo---

- **accident**: acidente_transito, acidente_trabalho, queda

- **fire**: incendio_florestal```dart

- **health**: doenca_infecciosa, emergencia_medica

AuthTokenManager().hasToken  // bool## 📋 Risk Types (3 linhas)

---

```

## 📍 Reports

```dart

### Carregar Nearby

```dart---// Inicializar

await ref.read(nearbyReportsControllerProvider).loadNearbyReports(

  latitude: -8.839987,await ref.read(riskTypesControllerProvider).initialize();

  longitude: 13.289437,

  radius: 10000,## 📡 API Calls

);

```// Obter ID



### Criar Report### Get Risk Types (1 linha)final typeId = ref.read(riskTypesControllerProvider).getRiskTypeId('crime');

```dart

final success = await ref.read(createReportControllerProvider).createReport(final topicId = ref.read(riskTypesControllerProvider).getRiskTopicId('roubo');

  riskTypeName: 'crime',

  riskTopicName: 'roubo',```dart```

  description: 'Descrição detalhada',

  latitude: -8.839987,final types = await ref.read(riskTypesProvider.future);

  longitude: 13.289437,

  province: 'Luanda',```---

  municipality: 'Viana',

);

```

### Get Risk Topics (1 linha)## 📍 Carregar Reports (3 linhas)

### Observar Estado

```dart

final controller = ref.watch(nearbyReportsControllerProvider);

```dart```dart

if (controller.isLoading) { /* loading */ }

if (controller.hasError) { /* erro: controller.errorMessage */ }final topics = await ref.read(riskTopicsProvider.future);await ref.read(nearbyReportsControllerProvider).loadNearbyReports(

if (controller.hasReports) { /* usar: controller.reports */ }

``````  latitude: lat,



### Acessar Dados  longitude: lng,

```dart

final reports = ref.read(nearbyReportsControllerProvider).reports;### Get Nearby Reports (3 linhas)  radius: 10000,

for (final report in reports) {

  print(report.description););

  print('${report.distance}m de distância');

}```dart```

```

final reports = await ref.read(

---

  nearbyReportsProvider(NearbyReportsParams(lat: -8.8383, lng: 13.2344, radius: 1000)).future---

## 🔌 WebSocket

);

### Conectar (Autenticado)

```dart```## ➕ Criar Report (8 linhas)

final wsService = ref.read(alertWebSocketProvider);

wsService.connect(

  token: '', // Auto-retrieved from AuthTokenManager

  onAlert: (alert) => print('🚨 ${alert['message']}'),### Create Report (8 linhas)```dart

  onError: (error) => print('❌ $error'),

  onConnected: () => print('✅ Connected'),final success = await ref.read(createReportControllerProvider).createReport(

);

``````dart  riskTypeName: 'crime',



### Conectar (Anônimo)final service = ref.read(reportServiceProvider);  riskTopicName: 'roubo',

```dart

wsService.connect(final report = await service.createReport(  description: 'Descrição',

  deviceId: await DeviceIdManager().getDeviceId(),

  onAlert: (alert) => showNotification(alert),  reportData: CreateReportRequestDTO(  latitude: lat,

);

```    userId: 'user-id',  longitude: lng,



### Atualizar Localização    riskTypeId: 'type-uuid',  province: 'Luanda',

```dart

wsService.updateLocation(latitude, longitude);    riskTopicId: 'topic-uuid',  municipality: 'Viana',

```

    description: 'Descrição',);

### Desconectar

```dart    latitude: -8.8383,```

wsService.disconnect();

```    longitude: 13.2344,



### Verificar Conexão  ),---

```dart

if (wsService.isConnected) {);

  // Connected

}```## 👀 Observar Estado

```



---

---```dart

## 📍 Localização

// Nearby Reports

### Iniciar Tracking

```dart## 🔌 WebSocketfinal controller = ref.watch(nearbyReportsControllerProvider);

ref.read(locationControllerProvider).startLocationUpdates();

```if (controller.isLoading) { /* loading */ }



### Parar Tracking### Connect (4 linhas)if (controller.hasError) { /* erro: controller.errorMessage */ }

```dart

ref.read(locationControllerProvider).stopLocationUpdates();if (controller.hasReports) { /* usar: controller.reports */ }

```

```dart

### Obter Posição Atual

```dartfinal wsManager = ref.read(websocketNotificationsProvider);// Create Report

final position = await Geolocator.getCurrentPosition();

print('${position.latitude}, ${position.longitude}');await wsManager.connect();final createCtrl = ref.watch(createReportControllerProvider);

```

_startLocationUpdates();if (createCtrl.isSubmitting) { /* loading */ }

### Verificar Permissão

```dart```if (createCtrl.hasError) { /* erro: createCtrl.errorMessage */ }

final permission = await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {

  await Geolocator.requestPermission();

}### Update Location (3 linhas)// Risk Types

```

final typesCtrl = ref.watch(riskTypesControllerProvider);

---

```dartif (typesCtrl.isLoading) { /* loading */ }

## 🎨 UI Panel

final wsService = ref.read(alertWebSocketConnectionProvider);if (typesCtrl.isInitialized) { /* OK */ }

### Controlar Panel

```dartwsService.updateLocation(latitude, longitude);```

final controller = ref.read(homePanelControllerProvider);

```

controller.expandPanel();    // Expandir

controller.collapsePanel();  // Colapsar---

controller.hidePanel();      // Esconder

controller.showPanel();      // Mostrar collapsed### Disconnect (1 linha)

```

## 🔄 Refresh

### Adicionar Items Recentes

```dart```dart

controller.addRecentItem(RecentSearchItem(

  type: 'location',ref.read(websocketNotificationsProvider).disconnect();```dart

  title: 'Casa',

  latitude: -8.839987,```// Recarregar reports

  longitude: 13.289437,

));await ref.read(nearbyReportsControllerProvider).refresh();

```

---```

### Configurar Endereços

```dart

controller.setHomeAddress('Rua ABC, Viana');

controller.setWorkAddress('Rua XYZ, Talatona');## 🎨 UI Panel Control---

```



---

### States## 🧹 Limpar Estado

## 🚨 Error Handling



### Pattern Completo

```dart```dart```dart

try {

  final result = await service.method();final controller = ref.read(homePanelControllerProvider);ref.read(riskTypesControllerProvider).clear();

} on UnauthorizedException {

  // 401 - Redirect to loginref.read(nearbyReportsControllerProvider).clear();

  Navigator.pushNamed(context, '/login');

} on NetworkException {controller.expandPanel();    // Expandirref.read(createReportControllerProvider).clear();

  showSnackbar('Sem conexão com internet');

} on ServerException catch (e) {controller.collapsePanel();  // Colapsar```

  showSnackbar(e.message);

} on HttpException catch (e) {controller.hidePanel();      // Esconder

  showSnackbar('Erro: ${e.message}');

}controller.showPanel();      // Mostrar collapsed---

```

```

### Pattern Simples

```dart## 📊 Acessar Dados

try {

  await service.method();### Data Management

} catch (e) {

  showSnackbar('Erro: $e');```dart

}

``````dart// Reports



---controller.addRecentItem(item);       // Adicionar recentefinal reports = ref.read(nearbyReportsControllerProvider).reports;



## 🎯 Providerscontroller.clearRecentItems();        // Limparfor (final report in reports) {



### Auth Servicecontroller.setHomeAddress('Home');    // Casa  print(report.description);

```dart

final authServiceProvider = Provider<AuthService>((ref) {controller.setWorkAddress('Work');    // Trabalho  print(report.latitude);

  final httpClient = ref.read(httpClientProvider);

  return AuthService(httpClient: httpClient);```  print(report.riskType.name);

});

```}



### HTTP Client---

```dart

final httpClientProvider = Provider<IHttpClient>((ref) {// Types

  return DioHttpClient();

});## 🚨 Error Handlingfinal types = ref.read(riskTypesControllerProvider).types;

```

for (final type in types) {

### WebSocket

```dart### Pattern Completo  print(type.name); // "crime", "accident", etc

final alertWebSocketProvider = Provider((ref) {

  return AlertWebSocketService();}

});

``````dart



### Locationtry {// Topics

```dart

final locationControllerProvider = ChangeNotifierProvider((ref) {  final result = await service.method();final topics = ref.read(riskTypesControllerProvider).topics;

  final locationService = ref.read(locationServiceProvider);

  final wsService = ref.read(alertWebSocketProvider);} on UnauthorizedException {for (final topic in topics) {

  return LocationController(locationService, wsService);

});  // 401 - Redirect to login  print(topic.name); // "roubo", "assalto", etc

```

} on NetworkException {}

---

  // Sem internet```

## 📱 Widgets

} on ServerException catch (e) {

### Loading Indicator

```dart  // Erro servidor---

final controller = ref.watch(nearbyReportsControllerProvider);

if (controller.isLoading) {  showError(e.message);

  return const Center(child: CircularProgressIndicator());

}} on HttpException catch (e) {## ⚡ Fluxo Completo (Copy-Paste)

```

  // Erro genérico

### Error Display

```dart  showError(e.message);```dart

if (controller.hasError) {

  return Center(}// 1. LOGIN

    child: Text(

      controller.errorMessage ?? 'Erro desconhecido',```AuthTokenManager().setToken(userToken);

      style: const TextStyle(color: Colors.red),

    ),await ref.read(riskTypesControllerProvider).initialize();

  );

}### Pattern Simples

```

// 2. CARREGAR REPORTS

### Empty State

```dart```dartawait ref.read(nearbyReportsControllerProvider).loadNearbyReports(

if (!controller.hasReports) {

  return const Center(try {  latitude: -8.839987,

    child: Text('Nenhum report encontrado'),

  );  await service.method();  longitude: 13.289437,

}

```} on HttpException catch (e) {  radius: 10000,



### List Builder  showError(e.message););

```dart

ListView.builder(}

  itemCount: controller.reports.length,

  itemBuilder: (context, index) {```// 3. CRIAR REPORT

    final report = controller.reports[index];

    return ListTile(final success = await ref.read(createReportControllerProvider).createReport(

      title: Text(report.description),

      subtitle: Text('${report.distance.toStringAsFixed(0)}m'),---  riskTypeName: 'crime',

      leading: Icon(Icons.warning, color: _getSeverityColor(report)),

    );  riskTopicName: 'roubo',

  },

)## 🎯 Providers  description: 'Descrição aqui',

```

  latitude: -8.839987,

---

### HTTP Client  longitude: 13.289437,

## ⚡ Fluxo Completo

  province: 'Luanda',

### Setup Inicial

```dart```dart  municipality: 'Viana',

// 1. Login

AuthTokenManager().setToken(userToken);final httpClientProvider = Provider<IHttpClient>((ref) {  neighborhood: 'Zango 3',

await ref.read(riskTypesControllerProvider).initialize();

  return HttpClient();  address: 'Rua X',

// 2. WebSocket

final wsService = ref.read(alertWebSocketProvider);}););

await wsService.connect(

  token: '',```

  onAlert: (alert) => showNotification(alert),

);// 4. REFRESH



// 3. Location Tracking### Auth Serviceif (success) {

ref.read(locationControllerProvider).startLocationUpdates();

  await ref.read(nearbyReportsControllerProvider).refresh();

// 4. Carregar Reports

await ref.read(nearbyReportsControllerProvider).loadNearbyReports(```dart}

  latitude: -8.839987,

  longitude: 13.289437,final authServiceProvider = Provider<AuthService>((ref) {

  radius: 10000,

);  final httpClient = ref.read(httpClientProvider);// 5. LOGOUT

```

  return AuthService(httpClient: httpClient);AuthTokenManager().clearToken();

### Criar Report

```dart});ref.read(riskTypesControllerProvider).clear();

final success = await ref.read(createReportControllerProvider).createReport(

  riskTypeName: 'crime',```ref.read(nearbyReportsControllerProvider).clear();

  riskTopicName: 'roubo',

  description: 'Assalto na Rua X',```

  latitude: -8.839987,

  longitude: 13.289437,### Risk Types

  province: 'Luanda',

  municipality: 'Viana',---

);

```dart

if (success) {

  await ref.read(nearbyReportsControllerProvider).refresh();final riskTypesProvider = FutureProvider<List<RiskType>>((ref) async {## 📱 Widgets Práticos

  showSnackbar('Report criado com sucesso!');

}  final service = ref.read(riskTypesServiceProvider);

```

  return await service.getRiskTypes();### Loading Indicator

### Logout

```dart});```dart

AuthTokenManager().clearToken();

wsService.disconnect();```final controller = ref.watch(nearbyReportsControllerProvider);

ref.read(locationControllerProvider).stopLocationUpdates();

ref.read(riskTypesControllerProvider).clear();if (controller.isLoading) {

ref.read(nearbyReportsControllerProvider).clear();

```### Nearby Reports  return const CircularProgressIndicator();



---}



## 🗺️ Map Helpers```dart```



### Adicionar Markerfinal nearbyReportsProvider = FutureProvider.family<

```dart

Marker(  List<Report>,### Error Display

  point: LatLng(latitude, longitude),

  width: 40,  NearbyReportsParams```dart

  height: 40,

  builder: (ctx) => const Icon(>((ref, params) async {if (controller.hasError) {

    Icons.warning,

    color: Colors.red,  final service = ref.read(reportServiceProvider);  return Text(

    size: 30,

  ),  return await service.getNearbyReports(    controller.errorMessage ?? 'Erro desconhecido',

)

```    latitude: params.latitude,    style: const TextStyle(color: Colors.red),



### Adicionar Círculo (Raio)    longitude: params.longitude,  );

```dart

CircleMarker(    radius: params.radius,}

  point: LatLng(latitude, longitude),

  radius: 1000, // metros  );```

  color: Colors.red.withOpacity(0.3),

  borderColor: Colors.red,});

  borderStrokeWidth: 2,

)```### Empty State

```

```dart

---

### WebSocket Managerif (!controller.hasReports) {

## 🔗 URLs e Endpoints

  return const Text('Nenhum report encontrado');

**Backend**: `https://risk-place-angola-904a.onrender.com`

```dart}

**Endpoints**:

```final websocketNotificationsProvider = ```

GET  /api/v1/risks/types

GET  /api/v1/risks/topics    Provider<WebSocketNotificationsManager>((ref) {

POST /api/v1/reports

GET  /api/v1/reports/nearby  final wsService = ref.read(alertWebSocketConnectionProvider);### List Builder

POST /api/v1/alerts

POST /api/v1/devices/register (anônimo)  final notificationService = ref.read(notificationServiceProvider);```dart

PUT  /api/v1/devices/location (anônimo)

```  return WebSocketNotificationsManager(wsService, notificationService);ListView.builder(



**WebSocket**:});  itemCount: controller.reports.length,

```

wss://risk-place-angola-904a.onrender.com/ws/alerts```  itemBuilder: (context, index) {

```

    final report = controller.reports[index];

---

---    return ListTile(

## 🆘 Erros Comuns

      title: Text(report.description),

| Erro | Causa | Solução |

|------|-------|---------|## 📱 Common Patterns      subtitle: Text('${report.distance.toStringAsFixed(0)}m'),

| "Authentication token required" | Token não configurado | `AuthTokenManager().setToken(token)` |

| "RiskTypesRepository not initialized" | Types não carregados | `await controller.initialize()` |    );

| 401 Unauthorized | Token inválido/expirado | Fazer logout e login novamente |

| WebSocket não conecta | Token ausente ou URL incorreta | Verificar AuthTokenManager e BASE_URL |### Watch Provider (Auto-Rebuild)  },

| Localização não atualiza | Permissão negada | Solicitar permissão GPS |

)

---

```dart```

## 📚 Documentação Detalhada

final data = ref.watch(providerName);

- **[Anonymous Users](features/ANONYMOUS_USERS.md)** - Sistema de usuários anônimos

- **[Location Tracking](features/LOCATION_TRACKING.md)** - Rastreamento GPS e WebSocket---

- **[API Guide](api/API_COMPLETE_GUIDE.md)** - Documentação completa da API

- **[WebSocket Guide](websocket/WEBSOCKET_GUIDE.md)** - Real-time communicationdata.when(

- **[HTTP Client](architecture/HTTP_CLIENT_GUIDE.md)** - Arquitetura HTTP

- **[Setup Guide](setup/ENVIRONMENT_SETUP.md)** - Configuração do ambiente  data: (value) => Text('Success: $value'),## 🎯 Risk Type/Topic Names

- **[FCM iOS Setup](setup/FCM_IOS_SETUP.md)** - Push notifications iOS

  loading: () => CircularProgressIndicator(),

---

  error: (error, stack) => Text('Error: $error'),### Types

**Última Atualização:** 17 de Novembro de 2025

);```

```crime, accident, natural_disaster, fire, health, infrastructure, environment

```

### Read Provider (One-Time)

### Topics (Crime)

```dart```

final service = ref.read(providerName);roubo, assalto, furtos, vandalismo

final result = await service.method();```

```

### Topics (Accident)

### Refresh Provider```

acidente_transito, acidente_trabalho, queda

```dart```

ref.refresh(providerName);

ref.invalidate(providerName);### Topics (Natural Disaster)

``````

enchente, deslizamento, tempestade

---```



## 🗺️ Map Markers### Topics (Fire)

```

### Add Markerincendio_florestal

```

```dart

Marker(### Topics (Health)

  point: LatLng(latitude, longitude),```

  width: 40,doenca_infecciosa, emergencia_medica

  height: 40,```

  builder: (ctx) => Icon(Icons.warning, color: Colors.red),

)### Topics (Infrastructure)

``````

queda_ponte, queda_energia

### Add Circle```



```dart### Topics (Environment)

CircleMarker(```

  point: LatLng(latitude, longitude),poluicao, vazamento_quimico

  radius: radius, // metros```

  color: Colors.red.withOpacity(0.3),

  borderColor: Colors.red,---

  borderStrokeWidth: 2,

)## 🔗 URLs

```

**Backend:** `https://risk-place-angola-904a.onrender.com`

---

**Endpoints:**

## 🔄 State Management```

GET  /api/v1/risks/types

### ChangeNotifier ControllerGET  /api/v1/risks/topics

POST /api/v1/reports

```dartGET  /api/v1/reports/nearby

class MyController extends ChangeNotifier {POST /api/v1/alerts

  bool _isLoading = false;```

  

  bool get isLoading => _isLoading;---

  

  void setLoading(bool value) {## 🆘 Erros Comuns

    _isLoading = value;

    notifyListeners();| Erro | Causa | Solução |

  }|------|-------|---------|

}| "Authentication token required" | Token não configurado | `AuthTokenManager().setToken(token)` |

| "RiskTypesRepository not initialized" | Types não carregados | `await controller.initialize()` |

// Provider| 401 Unauthorized | Token inválido/expirado | Fazer logout e login |

final myControllerProvider = ChangeNotifierProvider((ref) {| 403 Forbidden | Sem permissão | Apenas autoridades criam alerts |

  return MyController();

});---

```

**Tudo em um lugar! 📚✨**

### StateNotifier

```dart
class MyNotifier extends StateNotifier<List<Item>> {
  MyNotifier() : super([]);
  
  void addItem(Item item) {
    state = [...state, item];
  }
}

// Provider
final myNotifierProvider = StateNotifierProvider<MyNotifier, List<Item>>((ref) {
  return MyNotifier();
});
```

---

## 🎯 Imports Essenciais

### Authentication

```dart
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/providers/repository_providers.dart';
```

### API Services

```dart
import 'package:rpa/data/services/risk_types.service.dart';
import 'package:rpa/data/services/report.service.dart';
import 'package:rpa/data/services/alert.service.dart';
```

### HTTP Client

```dart
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
```

### WebSocket

```dart
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/data/providers/websocket_notifications_provider.dart';
```

### UI Components

```dart
import 'package:rpa/presenter/pages/home_page/widgets/home_panel.widget.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
```

### Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

---

## 🚀 Quick Start Template

### Basic Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: data.when(
        data: (value) => ListView(...),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

### StatefulConsumer

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerStatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(myProvider);
    
    return Scaffold(
      body: ...,
    );
  }
}
```

---

## 📚 Documentação Completa

- **Setup**: `/docs/setup/ENVIRONMENT_SETUP.md`
- **API**: `/docs/api/API_COMPLETE_GUIDE.md`
- **WebSocket**: `/docs/websocket/WEBSOCKET_GUIDE.md`
- **HTTP Client**: `/docs/architecture/HTTP_CLIENT_GUIDE.md`
- **UI/UX**: `/docs/ui-ux/WAZE_PANEL_GUIDE.md`

---

**Última Atualização:** 17 de Novembro de 2025
