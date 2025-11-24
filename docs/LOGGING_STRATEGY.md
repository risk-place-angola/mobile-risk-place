# 📊 Estratégia de Logs - MakaNetu

**Versão:** 1.0.0  
**Última Atualização:** 23 de Novembro de 2025

---

## 🎯 Objetivo

Manter logs **limpos, concisos e úteis** para debugging, evitando poluição do console com informações redundantes ou desnecessárias.

---

## 📋 Princípios

### ✅ O Que Logar

1. **Eventos Críticos**
   - Conexões/Desconexões
   - Erros e exceções
   - Mudanças de estado importantes
   - Recebimento de dados do backend

2. **Métricas Relevantes**
   - Quantidade de usuários próximos
   - Quantidade de avatares no mapa
   - Status de conexões

3. **Operações de Sucesso**
   - Apenas resultado final (não intermediários)
   - Confirmações importantes

### ❌ O Que NÃO Logar

1. **Operações Intermediárias**
   - Parsing de JSON (exceto erros)
   - Transformações de dados
   - Validações internas

2. **Detalhes Verbosos**
   - Raw data completo
   - Coordenadas detalhadas (exceto debug específico)
   - Informações redundantes

3. **Throttling/Debouncing**
   - Logs de operações que foram filtradas
   - Timers internos

---

## 🎨 Uso de Emojis

### Quando Usar

Emojis facilitam **scanning visual** rápido do console. Use apenas para logs importantes:

| Emoji | Significado | Exemplo |
|-------|-------------|---------|
| ✅ | Sucesso | `✅ Connected` |
| ❌ | Erro | `❌ Connection failed: timeout` |
| 🚨 | Alerta crítico | `🚨 Alert: Armed robbery nearby` |
| 👥 | Usuários/Avatares | `👥 5 nearby users` |
| 🗺️ | Atualização do mapa | `🗺️ 5 nearby users` |
| 🔌 | Conexão | `🔌 Disconnected` |
| 📍 | Localização | `📍 Location update sent` |
| 🔐 | Autenticação | `🔐 User logged in` |
| 🔔 | Notificação | `🔔 Push notification received` |

### Quando NÃO Usar

- ❌ Logs de debug técnico
- ❌ Logs muito frequentes (>1/segundo)
- ❌ Logs internos de bibliotecas

---

## 📝 Formato Padrão

### Template
```dart
log('emoji Mensagem concisa', name: 'NomeDoServiço');
```

### Exemplos Corretos ✅

```dart
// Sucesso
log('✅ Connected', name: 'AlertWebSocketService');
log('✅ 5 avatars', name: 'UserAvatarsNotifier');

// Erro
log('❌ Connection failed: $error', name: 'AlertWebSocketService');
log('❌ Error parsing nearby users: $e', name: 'AlertWebSocketService');

// Informação
log('👥 Received 5 nearby users', name: 'AlertWebSocketService');
log('🗺️ 5 nearby users', name: 'MapView');
log('🚨 Alert: ${alert['message']}', name: 'AnonymousUserManager');
```

### Exemplos Incorretos ❌

```dart
// ❌ Muito verboso
log('📩 [WebSocket] Raw message received: $message', name: 'AlertWebSocketService');
log('📨 [WebSocket] Message event: $event, type: $type', name: 'AlertWebSocketService');
log('📍 [WebSocket] Received nearby_users event', name: 'AlertWebSocketService');

// ❌ Redundante
log('👤 First user: ${users.first.userId} at (${users.first.latitude}, ${users.first.longitude})');
log('➕ New user: ${user.userId} at (${user.latitude}, ${user.longitude})');

// ❌ Intermediário desnecessário
log('📥 Received ${newUsers.length} nearby users', name: 'UserAvatarsNotifier');
log('👥 Processing ${limitedUsers.length} users', name: 'UserAvatarsNotifier');
log('⏱️ Throttled - skipping update', name: 'UserAvatarsNotifier');
```

---

## 🔧 Implementação por Componente

### AlertWebSocketService

**O que logar:**
```dart
// Conexão
log('✅ Connected successfully!', name: 'AlertWebSocketService');
log('🔌 Connection closed', name: 'AlertWebSocketService');
log('❌ Connection error: $error', name: 'AlertWebSocketService');

// Dados recebidos
log('👥 Received ${users.length} nearby users', name: 'AlertWebSocketService');
log('🚨 Alert received: ${alertData['message']}', name: 'AlertWebSocketService');

// Erros
log('❌ Error parsing nearby users: $e', name: 'AlertWebSocketService');
```

**O que NÃO logar:**
- ❌ Raw JSON messages
- ❌ Detalhes de cada usuário
- ❌ Event types intermediários

### AnonymousUserManager

**O que logar:**
```dart
// Conexão
log('✅ Connected', name: 'AnonymousUserManager');
log('🔌 Disconnected', name: 'AnonymousUserManager');

// Eventos
log('👥 ${users.length} nearby users', name: 'AnonymousUserManager');
log('🚨 Alert: ${alert['message']}', name: 'AnonymousUserManager');

// Erros
log('❌ WebSocket error: $error', name: 'AnonymousUserManager');
```

**O que NÃO logar:**
- ❌ Envio de localização (muito frequente)
- ❌ Detalhes dos usuários
- ❌ Timers internos

### MapView

**O que logar:**
```dart
// Atualização do mapa (apenas contagem)
log('🗺️ ${users.length} nearby users', name: 'MapView');
```

**O que NÃO logar:**
- ❌ "Received from WebSocket"
- ❌ "Updating UserAvatarsNotifier"
- ❌ "Widget not mounted"
- ❌ Detalhes de usuários individuais

### UserAvatarsNotifier

**O que logar:**
```dart
// Apenas resultado final
log('✅ ${updatedUsers.length} avatars', name: 'UserAvatarsNotifier');
```

**O que NÃO logar:**
- ❌ "Received X nearby users"
- ❌ "Processing X users"
- ❌ "New user added"
- ❌ "Removed X inactive users"
- ❌ "Throttled"
- ❌ "No changes detected"

### LocationController

**O que logar:**
```dart
// Apenas mudanças significativas ou erros
log('📍 Location permission granted', name: 'LocationController');
log('❌ Location permission denied', name: 'LocationController');
```

**O que NÃO logar:**
- ❌ Cada atualização de posição (muito frequente)
- ❌ "Location sent to WebSocket"
- ❌ Coordenadas detalhadas

---

## 📊 Resultado Esperado

### Console Limpo

```
[AlertWebSocketService] ✅ Connected successfully!
[AlertWebSocketService] 👥 Received 5 nearby users
[AnonymousUserManager] 👥 5 nearby users
[MapView] 🗺️ 5 nearby users
[UserAvatarsNotifier] ✅ 5 avatars
```

### Console Poluído (Evitar)

```
[AlertWebSocketService] 📩 Raw message received: {"event":"nearby_users"...}
[AlertWebSocketService] 📨 Message event: nearby_users, type: null
[AlertWebSocketService] 📍 Received nearby_users event
[AlertWebSocketService] 📍 Raw data: {users: [...], radius: 5000, total_count: 5}
[AlertWebSocketService] 👥 Parsed 5 nearby users
[AlertWebSocketService] 👤 First user: neter_xxx at (38.790, -9.177)
[AlertWebSocketService] ✅ Calling onNearbyUsersReceived callback
[AnonymousUserManager] 👥 Received 5 nearby users
[AnonymousUserManager] 👤 First user: neter_xxx at (38.790, -9.177)
[MapView] 🗺️ Received 5 nearby users from WebSocket
[MapView] 👤 First user: neter_xxx at (38.790, -9.177)
[MapView] ✅ Updating UserAvatarsNotifier
[UserAvatarsNotifier] 📥 Received 5 nearby users
[UserAvatarsNotifier] 👥 Processing 5 users
[UserAvatarsNotifier] ➕ New user: neter_xxx
[UserAvatarsNotifier] ✅ State updated: 5 total users
```

---

## 🎯 Benefícios

1. **Console Limpo** - Fácil de ler e entender
2. **Performance** - Menos overhead de logging
3. **Debugging Eficiente** - Apenas logs relevantes
4. **Produção Ready** - Logs úteis sem verbosidade
5. **Quick Scanning** - Emojis facilitam identificação visual

---

## 🔍 Debug Detalhado

### Quando Preciso?

Para debugging específico, adicione logs temporários com prefixo `[DEBUG]`:

```dart
log('[DEBUG] Raw data: $data', name: 'AlertWebSocketService');
log('[DEBUG] Processing user: ${user.userId}', name: 'UserAvatarsNotifier');
```

**IMPORTANTE:** Remova logs `[DEBUG]` antes de commit!

---

## 📚 Referências

- [Dart Logging Best Practices](https://dart.dev/guides/language/effective-dart/usage#do-use-rethrow-to-rethrow-a-caught-exception)
- [Flutter Logging](https://flutter.dev/docs/testing/errors)
- [Clean Code - Logging](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

---

**Última Revisão:** 23 de Novembro de 2025  
**Mantenedor:** Risk Place Angola Team
