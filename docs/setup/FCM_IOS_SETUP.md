# Configuração do Firebase Cloud Messaging (FCM) para iOS

## ✅ Configurações já aplicadas no projeto

### 1. AppDelegate.swift
- ✅ FirebaseApp.configure() no launch
- ✅ Registro de notificações remotas
- ✅ APNS token configurado: `Messaging.messaging().apnsToken = deviceToken`

### 2. Info.plist
- ✅ UIBackgroundModes com `remote-notification` e `location`
- ✅ Permissões de localização configuradas

### 3. Podfile
- ✅ Deployment target atualizado para iOS 15.0
- ✅ firebase_messaging: ^16.0.4 instalado

### 4. GoogleService-info.plist
- ✅ Arquivo presente em `ios/Runner/GoogleService-info.plist`

## 📋 Passos que você precisa fazer no Apple Developer Console

### 1. Criar APNs Key (se não tiver)

1. Acesse: https://developer.apple.com/account/resources/authkeys/list
2. Click em **+** para criar uma nova key
3. Marque **Apple Push Notifications service (APNs)**
4. Baixe o arquivo `.p8` (você só pode baixar uma vez!)
5. Anote:
   - **Key ID** (ex: ABC123XYZ)
   - **Team ID** (ex: DEF456UVW)

### 2. Upload da APNs Key no Firebase Console

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Vá em **Project Settings** (⚙️)
4. Aba **Cloud Messaging**
5. Na seção **Apple app configuration**:
   - Click em **Upload** em APNs Authentication Key
   - Selecione o arquivo `.p8`
   - Insira o **Key ID**
   - Insira o **Team ID**
6. Click em **Upload**

### 3. Habilitar Push Notifications no Xcode

1. Abra o projeto no Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Selecione o target **Runner**

3. Vá na aba **Signing & Capabilities**

4. Click em **+ Capability**

5. Adicione:
   - **Push Notifications**
   - **Background Modes** (se não estiver)
     - Marque: `Remote notifications`
     - Marque: `Location updates`

6. Salve e feche o Xcode

## 🧪 Testando FCM

### 1. Verificar token FCM

Ao rodar o app, você deve ver nos logs:
```
✅ FCM token obtained: <token>
```

Se aparecer o erro do APNS token, é normal na primeira execução. O código agora tem retry automático.

### 2. Testar notificação via Firebase Console

1. Acesse: https://console.firebase.google.com
2. Vá em **Messaging** no menu lateral
3. Click em **New campaign** → **Firebase Notification messages**
4. Preencha:
   - **Notification title**: "Teste"
   - **Notification text**: "Testando FCM"
5. Click em **Next**
6. Selecione seu app iOS
7. Click em **Next** → **Review** → **Publish**

### 3. Testar via código

O sistema já está configurado para:
- ✅ Receber notificações em foreground
- ✅ Receber notificações em background
- ✅ Mostrar alertas via WebSocket
- ✅ Atualizar localização automaticamente (30s)

## 🐛 Resolução de problemas

### Erro: "APNS token has not been received"

**Causa**: iPhone ainda não registrou o APNS token

**Solução**: 
1. Certifique-se de estar usando um **dispositivo físico** (não funciona em simulador)
2. Certifique-se de ter uma **conexão com internet ativa**
3. O código agora tem retry automático (aguarda até 5 segundos)
4. Reinicie o app se necessário

### Notificações não aparecem

Verifique:
1. ✅ APNs key foi enviada para Firebase Console
2. ✅ Push Notifications capability está habilitada no Xcode
3. ✅ App está instalado num **dispositivo físico** (não simulador)
4. ✅ Permissões de notificação foram aceitas pelo usuário

## 📱 Fluxo completo do app

```
App Start
  ↓
AnonymousUserManager.initialize()
  ↓
1. Gera Device ID (UUID)
  ↓
2. Solicita permissão de localização
  ↓
3. Obtém FCM token (com retry)
  ↓
4. Registra device no backend (/api/v1/devices/register)
  ↓
5. Conecta WebSocket com device_id (X-Device-ID header)
  ↓
6. Inicia tracking de localização (30s intervals)
  ↓
Usuário recebe alertas em tempo real! 🚨
  ↓
[Opcional] Login
  ↓
WebSocket reconecta com JWT (Authorization: Bearer)
```

## 📚 Referências

- [Firebase iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notifications](https://developer.apple.com/documentation/usernotifications)
- [Background Modes](https://developer.apple.com/documentation/xcode/configuring-background-execution-modes)
