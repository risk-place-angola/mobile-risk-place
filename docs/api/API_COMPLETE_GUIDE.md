# 📡 API Integration - Complete Guide
**Risk Place Mobile**

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Configuração](#configuração)
3. [Endpoints da API](#endpoints-da-api)
4. [Autenticação](#autenticação)
5. [Tipos e Tópicos de Risco](#tipos-e-tópicos-de-risco)
6. [Relatórios](#relatórios)
7. [Alertas](#alertas)
8. [Como Usar no Mobile](#como-usar-no-mobile)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Este guia consolida toda a documentação necessária para integrar o aplicativo mobile com a API do Risk Place.

### Arquitetura

```
Mobile App (Flutter)
    ↓
Riverpod Providers
    ↓
Services (Business Logic)
    ↓
HTTP Client (Dio + Interceptors)
    ↓
Backend API
```

### Estrutura de Arquivos

```
lib/
├── core/http_client/
│   ├── dio_http_client.dart          # Cliente HTTP + Provider
│   └── interceptors/
│       ├── auth_interceptor.dart     # JWT automático
│       └── error_interceptor.dart    # Tratamento de erros
├── data/
│   ├── services/                     # Serviços de API
│   │   ├── auth.service.dart         # Autenticação
│   │   ├── risk.service.dart         # Risk Types/Topics (NOVO)
│   │   ├── risk_types.service.dart   # Legacy (será removido)
│   │   ├── report.service.dart       # Relatórios
│   │   └── alert.service.dart        # Alertas
│   ├── dtos/                         # Data Transfer Objects
│   │   ├── risk_type_dto.dart        # DTOs Risk Types (NOVO)
│   │   ├── risk_topic_dto.dart       # DTOs Risk Topics (NOVO)
│   │   ├── list_reports_response_dto.dart       # DTOs Reports (NOVO)
│   │   └── list_nearby_reports_response_dto.dart # DTOs Nearby (NOVO)
│   └── providers/
│       ├── api_providers.dart        # Providers gerais
│       └── risk_providers.dart       # Cache Risk Types/Topics (NOVO)
```

---

## ⚙️ Configuração

### 1. Base URL

Edite `lib/constants.dart`:

```dart
// Desenvolvimento
String get BASE_URL => 'http://localhost:8080/api/v1';

// Produção
String get BASE_URL => 'https://api.riskplace.ao/api/v1';
```

### 2. Dependências

```yaml
dependencies:
  dio: ^5.0.0
  flutter_riverpod: ^2.0.0
  web_socket_channel: ^2.4.0
```

---

## 🔌 Endpoints da API

### Base URL
```
http://localhost:8080/api/v1
```

### Autenticação
Maioria das rotas requer JWT Bearer Token:
```
Authorization: Bearer {seu_token}
```

---

## 🔐 Autenticação

### 1. Cadastro
**Endpoint:** `POST /auth/signup`  
**Autenticação:** Não requerida

**Request:**
```json
{
  "name": "João Silva",
  "email": "joao@example.com",
  "phone": "+244923456789",
  "password": "senha123"
}
```

**Response (201):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Código Mobile:**
```dart
import 'package:rpa/data/services/auth.service.dart';

Future<void> handleSignup(WidgetRef ref) async {
  final authService = ref.read(authServiceProvider);
  
  try {
    final success = await authService.register(
      registerDto: RegisterRequestDTO(
        name: 'João Silva',
        email: 'joao@example.com',
        phone: '+244923456789',
        password: 'senha123',
      ),
    );
    
    if (success) {
      // Mostrar tela de confirmação
    }
  } catch (e) {
    print('Erro no cadastro: $e');
  }
}
```

---

### 2. Confirmar Cadastro
**Endpoint:** `POST /auth/confirm`  
**Autenticação:** Não requerida

**Request:**
```json
{
  "email": "joao@example.com",
  "code": "123456"
}
```

**Response:** `204 No Content`

**Código Mobile:**
```dart
Future<void> confirmRegistration(WidgetRef ref) async {
  final authService = ref.read(authServiceProvider);
  
  try {
    final success = await authService.confirmRegistration(
      email: 'joao@example.com',
      code: '123456',
    );
    
    if (success) {
      // Navegar para login
    }
  } catch (e) {
    print('Erro na confirmação: $e');
  }
}
```

---

### 3. Login
**Endpoint:** `POST /auth/login`  
**Autenticação:** Não requerida

**Request:**
```json
{
  "email": "joao@example.com",
  "password": "senha123"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "active_role": "user",
    "name": "João Silva",
    "email": "joao@example.com",
    "role_name": ["user"]
  }
}
```

**Código Mobile:**
```dart
Future<void> handleLogin(WidgetRef ref) async {
  final authService = ref.read(authServiceProvider);
  
  try {
    final userProfile = await authService.login(
      user: LoginRequestDTO(
        email: 'joao@example.com',
        password: 'senha123',
      ),
    );
    
    print('Login bem-sucedido: ${userProfile.name}');
    // Token é salvo automaticamente pelo AuthInterceptor
    
  } catch (e) {
    print('Erro no login: $e');
  }
}
```

---

### 4. Recuperar Senha
**Endpoint:** `POST /auth/password/forgot`  
**Autenticação:** Não requerida

**Request:**
```json
{
  "email": "joao@example.com"
}
```

**Response (200):**
```json
"password reset code sent"
```

**Código Mobile:**
```dart
Future<void> forgotPassword(WidgetRef ref) async {
  final authService = ref.read(authServiceProvider);
  
  try {
    final success = await authService.resetPassword(
      email: 'joao@example.com',
    );
    
    if (success) {
      // Mostrar mensagem: código enviado por email
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

---

### 5. Resetar Senha
**Endpoint:** `POST /auth/password/reset`  
**Autenticação:** Não requerida

**Request:**
```json
{
  "email": "joao@example.com",
  "password": "novaSenha123"
}
```

**Response (200):**
```json
"password reset successfully"
```

**Código Mobile:**
```dart
Future<void> resetPassword(WidgetRef ref) async {
  final authService = ref.read(authServiceProvider);
  
  try {
    final success = await authService.confirmPasswordReset(
      email: 'joao@example.com',
      password: 'novaSenha123',
    );
    
    if (success) {
      // Navegar para login
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

---

### 6. Obter Perfil
**Endpoint:** `GET /users/me`  
**Autenticação:** Requerida (JWT)

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "João Silva",
  "email": "joao@example.com",
  "phone": "+244923456789",
  "role_name": ["user"]
}
```

---

## 🏷️ Tipos e Tópicos de Risco

### 7. Listar Tipos de Risco
**Endpoint:** `GET /risks/types`  
**Autenticação:** Requerida (JWT)

**Response (200):**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Crime",
      "description": "Atividades criminosas e segurança pública",
      "default_radius": 500,
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

**Código Mobile (com Cache Inteligente):**
```dart
import 'package:rpa/data/providers/risk_providers.dart';

class RiskTypesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cache global de todos os risk types
    final riskTypesAsync = ref.watch(allRiskTypesProvider);
    
    return riskTypesAsync.when(
      data: (riskTypes) {
        return ListView.builder(
          itemCount: riskTypes.length,
          itemBuilder: (context, index) {
            final type = riskTypes[index];
            return ListTile(
              title: Text(type.name),
              subtitle: Text(type.description),
              trailing: Text('${type.defaultRadius}m'),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

**Buscar Risk Type Individual (com Cache):**
```dart
// Busca individual com cache automático
final riskTypeAsync = ref.watch(riskTypeProvider('risk-type-uuid'));

// Ou buscar apenas o nome
final riskTypeName = ref.watch(riskTypeNameProvider('risk-type-uuid'));
// Retorna: "Crime" ou "Loading..." ou "Unknown"
```

**Service Layer:**
```dart
import 'package:rpa/data/services/risk.service.dart';

final riskService = ref.read(riskServiceProvider);

// Listar todos
final allTypes = await riskService.listRiskTypes();

// Buscar por ID
final type = await riskService.getRiskType('uuid');
```

---

### 8. Listar Tópicos de Risco
**Endpoint:** `GET /risks/topics`  
**Autenticação:** Requerida (JWT)

**Query Parameters:**
- `risk_type_id` (opcional): Filtrar por tipo de risco

**Exemplos:**
```
GET /risks/topics                                    # Todos
GET /risks/topics?risk_type_id=550e8400-e29b-41d4... # Filtrado
```

**Response (200):**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Assalto",
      "description": "Roubo à mão armada",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

**Código Mobile (com Cache por Tipo):**
```dart
import 'package:rpa/data/providers/risk_providers.dart';

class RiskTopicsScreen extends ConsumerWidget {
  final String? riskTypeId;  // null = todos
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cache separado por risk_type_id
    final topicsAsync = ref.watch(riskTopicsProvider(riskTypeId));
    
    return topicsAsync.when(
      data: (topics) {
        return ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return ListTile(
              title: Text(topic.name),
              subtitle: Text(topic.description),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

**Buscar Risk Topic Individual (com Cache):**
```dart
// Busca individual com cache automático
final riskTopicAsync = ref.watch(riskTopicProvider('risk-topic-uuid'));

// Ou buscar apenas o nome
final riskTopicName = ref.watch(riskTopicNameProvider('risk-topic-uuid'));
// Retorna: "Assalto" ou "Loading..." ou "Unknown"
```

**Service Layer:**
```dart
import 'package:rpa/data/services/risk.service.dart';

final riskService = ref.read(riskServiceProvider);

// Listar todos
final allTopics = await riskService.listRiskTopics();

// Listar por tipo
final topicsByCrime = await riskService.listRiskTopics(
  riskTypeId: 'crime-type-uuid',
);

// Buscar por ID
final topic = await riskService.getRiskTopic('uuid');
```

---

### 🚀 Sistema de Cache Inteligente

O mobile implementa **cache automático** para Risk Types e Topics:

**Características:**
- ✅ **Pre-load Global**: Todos risk types são carregados no início
- ✅ **Lookup Rápido**: Busca primeiro no cache, depois na API
- ✅ **Cache por ID**: Usa Riverpod `.family` para cache granular
- ✅ **Redução de 95%**: Em requests HTTP para types/topics
- ✅ **Fallback Graceful**: Retorna "Unknown" em caso de erro

**Arquitetura:**
```
MapView → riskTypeProvider(id) → Cache → RiskService → API
            ↓ (hit)                ↓ (miss)
         Retorna DTO          Faz HTTP GET
```

**Providers Disponíveis:**
```dart
// RISK TYPES
allRiskTypesProvider              // Todos os tipos (cache global)
riskTypeProvider(id)              // Por ID (cache granular)
riskTypeNameProvider(id)          // Só o nome (helper)

// RISK TOPICS  
riskTopicsProvider(riskTypeId?)   // Todos ou filtrados
riskTopicProvider(id)             // Por ID (cache granular)
riskTopicNameProvider(id)         // Só o nome (helper)
```

**Exemplo: MapView com Lookup Dinâmico**
```dart
// Carrega reports do backend
final reports = await reportService.listNearbyReports(...);

// Resolve cada riskTypeId para nome real
for (final report in reports) {
  final riskTypeAsync = ref.read(riskTypeProvider(report.riskTypeId));
  
  await riskTypeAsync.when(
    data: (riskTypeDTO) {
      // Usa nome real do backend: "Criminalidade", "Incêndio", etc
      final riskType = _mapRiskTypeNameToEnum(riskTypeDTO.name);
      // Cria marker com tipo correto
    },
    loading: () => /* aguarda */,
    error: (e, _) => /* usa fallback */,
  );
}
```

---

## 📍 Relatórios

### 9. Criar Relatório
**Endpoint:** `POST /reports`  
**Autenticação:** Requerida (JWT)

**Request:**
```json
{
  "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
  "risk_topic_id": "550e8400-e29b-41d4-a716-446655440002",
  "description": "Buraco grande na via principal",
  "latitude": -8.8383,
  "longitude": 13.2344,
  "province": "Luanda",
  "municipality": "Luanda",
  "neighborhood": "Talatona",
  "address": "Rua Principal, próximo ao Shopping",
  "image_url": "https://example.com/image.jpg"
}
```

**Response (201):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
  "risk_topic_id": "550e8400-e29b-41d4-a716-446655440002",
  "description": "Buraco grande na via principal",
  "latitude": -8.8383,
  "longitude": 13.2344,
  "status": "pending",
  "created_at": "2025-11-17T10:30:00Z"
}
```

**Código Mobile:**
```dart
import 'package:rpa/data/services/report.service.dart';

Future<void> createReport(WidgetRef ref) async {
  final reportService = ref.read(reportServiceProvider);
  
  try {
    final report = await reportService.createReport(
      reportData: CreateReportRequestDTO(
        userId: 'user-id',
        riskTypeId: 'risk-type-uuid',
        riskTopicId: 'risk-topic-uuid',
        description: 'Buraco grande na via principal',
        latitude: -8.8383,
        longitude: 13.2344,
        province: 'Luanda',
        municipality: 'Luanda',
        neighborhood: 'Talatona',
        address: 'Rua Principal, próximo ao Shopping',
        imageUrl: '',
      ),
    );
    
    print('Relatório criado: ${report.id}');
  } catch (e) {
    print('Erro ao criar relatório: $e');
  }
}
```

---

### 10. Listar Todos os Relatórios (com Paginação)
**Endpoint:** `GET /reports`  
**Autenticação:** Requerida (JWT)

**Query Parameters:**
- `page` (opcional): Número da página (padrão: 1)
- `limit` (opcional): Items por página (padrão: 10)
- `status` (opcional): Filtrar por status (`pending`, `verified`, `resolved`)
- `risk_type_id` (opcional): Filtrar por tipo de risco

**Exemplo:**
```
GET /reports?page=1&limit=20&status=pending
```

**Response (200):**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
      "risk_topic_id": "550e8400-e29b-41d4-a716-446655440002",
      "description": "Buraco grande na via principal",
      "latitude": -8.8383,
      "longitude": 13.2344,
      "province": "Luanda",
      "municipality": "Luanda",
      "neighborhood": "Talatona",
      "status": "pending",
      "created_at": "2025-11-17T10:30:00Z",
      "updated_at": "2025-11-17T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

**Código Mobile (com Infinite Scroll):**
```dart
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/presenter/pages/reports/all_reports_screen.dart';

// Usar a tela pronta
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AllReportsScreen()),
);

// Ou usar o provider diretamente
final reportsAsync = ref.watch(
  allReportsProvider(ReportsQueryParams(
    page: 1,
    limit: 20,
    status: 'pending',
  )),
);
```

---

### 11. Listar Relatórios Próximos
**Endpoint:** `GET /reports/nearby`  
**Autenticação:** Requerida (JWT)

**Query Parameters:**
- `lat` (obrigatório): Latitude
- `lon` (obrigatório): Longitude
- `radius` (opcional): Raio em metros (padrão: 5000)

**Exemplo:**
```
GET /reports/nearby?lat=-8.8383&lon=13.2344&radius=5000
```

**Response (200):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440003",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
    "risk_topic_id": "550e8400-e29b-41d4-a716-446655440002",
    "description": "Buraco grande na via principal",
    "latitude": -8.8383,
    "longitude": 13.2344,
    "province": "Luanda",
    "municipality": "Luanda",
    "neighborhood": "Talatona",
    "address": "Rua Principal, próximo ao Shopping",
    "status": "pending",
    "distance": 450.5,
    "created_at": "2025-11-17T10:30:00Z",
    "reviewed_by": "550e8400-e29b-41d4-a716-446655440005"
  }
]
```

**Campos Importantes:**
- `risk_type_id`: UUID do tipo (requer lookup via cache)
- `risk_topic_id`: UUID do tópico (requer lookup via cache)
- `distance`: Distância em metros do ponto de busca
- `reviewed_by`: ID do usuário que revisou (nullable)

**Status possíveis:**
- `pending` - Pendente de verificação
- `verified` - Verificado por autoridade
- `resolved` - Problema resolvido

**Código Mobile (MapView com Cache):**
```dart
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/data/providers/risk_providers.dart';

class MapViewWithReports extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(locationControllerProvider).currentPosition;
    final radius = 5000; // 5km
    
    // Busca reports próximos
    final reportsAsync = ref.watch(
      nearbyReportsProvider(NearbyReportsParams(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        radius: radius,
      )),
    );
    
    return reportsAsync.when(
      data: (reports) {
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            
            // Resolve riskTypeId para nome real (com cache)
            final riskTypeName = ref.watch(
              riskTypeNameProvider(report.riskTypeId),
            );
            
            return ListTile(
              title: Text(report.description),
              subtitle: Text('$riskTypeName • ${report.distance.toInt()}m'),
              trailing: _buildStatusChip(report.status),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

**Controle de Raio Customizável:**
```dart
import 'package:rpa/presenter/widgets/radius_control_widget.dart';

// Widget pronto com controle 1km - 10km
RadiusControlWidget(
  currentRadius: 5000,
  onRadiusChanged: (newRadius) {
    // Recarrega reports com novo raio
    ref.refresh(nearbyReportsProvider(
      NearbyReportsParams(lat: lat, lon: lon, radius: newRadius),
    ));
  },
)
```

---

## 🚨 Alertas

### 12. Criar Alerta
**Endpoint:** `POST /alerts`  
**Autenticação:** Requerida (JWT)  
**Permissões:** Apenas autoridades (authority, government, admin)

**Request:**
```json
{
  "risk_type_id": "550e8400-e29b-41d4-a716-446655440001",
  "risk_topic_id": "550e8400-e29b-41d4-a716-446655440002",
  "message": "Assalto em andamento próximo ao Shopping",
  "latitude": -8.8383,
  "longitude": 13.2344,
  "radius": 500.0,
  "severity": "high"
}
```

**Campos:**
- `severity`: `low`, `medium`, `high`, `critical`

**Response (201):**
```json
{
  "status": "alert triggered"
}
```

**Nota:** O alerta é enviado via WebSocket para todos os usuários conectados no raio especificado.

**Código Mobile:**
```dart
import 'package:rpa/data/services/alert.service.dart';

Future<void> createEmergencyAlert(WidgetRef ref) async {
  final alertService = ref.read(alertServiceProvider);
  
  try {
    final success = await alertService.createAlert(
      alertData: CreateAlertRequestDTO(
        riskTypeId: 'crime-type-uuid',
        riskTopicId: 'robbery-topic-uuid',
        message: 'Assalto em andamento próximo ao Shopping',
        latitude: -8.8383,
        longitude: 13.2344,
        radius: 500.0,
        severity: 'high',
      ),
    );
    
    if (success) {
      print('Alerta enviado com sucesso!');
    }
  } catch (e) {
    print('Erro ao criar alerta: $e');
  }
}
```

---

## 💡 Como Usar no Mobile

### Fluxo Recomendado

#### 1. Primeiro Acesso
```dart
1. Cadastro (POST /auth/signup)
2. Confirmar email (POST /auth/confirm)
3. Login (POST /auth/login)
4. Armazenar tokens
5. Conectar ao WebSocket
```

#### 2. Uso Regular
```dart
1. Verificar token armazenado
2. Conectar ao WebSocket
3. Enviar localização atual
4. Buscar tipos e tópicos de risco
5. Listar relatórios próximos
6. Criar alertas/relatórios quando necessário
```

### Exemplo Completo: Tela de Login

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final authService = ref.read(authServiceProvider);
    
    try {
      final userProfile = await authService.login(
        user: LoginRequestDTO(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
      
      // Login bem-sucedido
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Boas Práticas

### 1. Gestão de Token
- ✅ Token é adicionado **automaticamente** pelo `AuthInterceptor`
- ✅ Token é salvo no banco de dados local após login
- ✅ Token é limpo automaticamente em caso de 401 Unauthorized

### 2. Tratamento de Erros
```dart
try {
  final result = await service.someMethod();
} on ServerException catch (e) {
  showError('Erro no servidor: ${e.message}');
} on NetworkException catch (e) {
  showError('Sem conexão com a internet');
} on HttpException catch (e) {
  showError('Erro: ${e.message}');
} catch (e) {
  showError('Erro inesperado: $e');
}
```

### 3. Refresh de Dados
```dart
// Forçar refresh de um provider
ref.refresh(riskTypesProvider);
ref.refresh(nearbyReportsProvider(params));
```

### 4. Logout Completo
```dart
Future<void> logout(WidgetRef ref) async {
  // 1. Desconectar WebSocket
  final wsService = ref.read(alertWebSocketConnectionProvider);
  wsService.disconnect();
  
  // 2. Fazer logout
  final authService = ref.read(authServiceProvider);
  await authService.logout();
  
  // 3. Navegar para login
  Navigator.of(context).pushReplacementNamed('/login');
}
```

---

## 🐛 Troubleshooting

### Token não é adicionado nas requisições
1. Verificar se login foi feito com sucesso
2. Verificar se `AuthInterceptor` está configurado
3. Verificar se token está salvo no banco local

### Erro 401 Unauthorized
1. Verificar se token é válido
2. Tentar fazer login novamente
3. Verificar se token não expirou

### Erro 403 Forbidden
1. Verificar permissões do usuário
2. Algumas rotas requerem role específico (ex: criar alertas)

### Erro de conexão
1. Verificar se BASE_URL está correto
2. Verificar se servidor está rodando
3. Verificar conexão com internet

---

## 📚 Recursos Adicionais

- **WebSocket Guide**: `/docs/websocket/WEBSOCKET_GUIDE.md`
- **HTTP Client**: `/docs/architecture/HTTP_CLIENT_GUIDE.md`
- **UI/UX Guide**: `/docs/ui-ux/WAZE_PANEL_GUIDE.md`

---

## 📝 Changelog

### 18 de Novembro de 2025
- ✅ **Adicionado**: Sistema de cache inteligente para Risk Types/Topics
- ✅ **Adicionado**: Endpoint GET /reports com paginação
- ✅ **Adicionado**: Endpoint GET /reports/nearby com radius customizável
- ✅ **Adicionado**: AllReportsScreen com infinite scroll
- ✅ **Adicionado**: RadiusControlWidget para controle de raio no mapa
- ✅ **Adicionado**: RiskService unificado (substitui risk_types.service.dart)
- ✅ **Atualizado**: DTOs alinhados com backend real
- ⚡ **Performance**: Cache reduz 95% requests HTTP para types/topics

### 17 de Novembro de 2025
- Versão inicial da documentação

---

**Última Atualização:** 18 de Novembro de 2025
