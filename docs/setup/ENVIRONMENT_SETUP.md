# ⚙️ Environment Setup Guide
**Risk Place Mobile**

## 📋 Índice

1. [Requisitos](#requisitos)
2. [Setup Inicial](#setup-inicial)
3. [Variáveis de Ambiente](#variáveis-de-ambiente)
4. [Firebase Configuration](#firebase-configuration)
5. [Running the App](#running-the-app)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Requisitos

### Software

- **Flutter SDK**: 3.0.0 ou superior
- **Dart SDK**: 3.0.0 ou superior
- **Android Studio** (para Android)
- **Xcode** (para iOS, apenas macOS)
- **VS Code** (opcional, recomendado)

### Verificar Instalação

```bash
flutter --version
dart --version
flutter doctor
```

---

## 🚀 Setup Inicial

### 1. Clonar Repositório

```bash
git clone https://github.com/risk-place-angola/mobile-risk-place.git
cd mobile-risk-place
```

### 2. Instalar Dependências

```bash
flutter pub get
```

### 3. Verificar Configuração

```bash
flutter doctor -v
```

---

## 🔐 Variáveis de Ambiente

### 1. Criar Arquivo .env

```bash
cp .env.example .env
```

### 2. Configurar Variáveis

Edite o arquivo `.env` com seus valores:

```env
# API Configuration
BASE_URL=http://localhost:8080/api/v1

# Firebase Android
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_ANDROID_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_ANDROID_PROJECT_ID=your_project_id
FIREBASE_ANDROID_STORAGE_BUCKET=your_bucket
FIREBASE_ANDROID_DATABASE_URL=your_database_url

# Firebase iOS
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_IOS_PROJECT_ID=your_project_id
FIREBASE_IOS_STORAGE_BUCKET=your_bucket
FIREBASE_IOS_BUNDLE_ID=ao.riskplace.mobile
FIREBASE_IOS_DATABASE_URL=your_database_url

# Firebase Web
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_WEB_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_WEB_PROJECT_ID=your_project_id
FIREBASE_WEB_AUTH_DOMAIN=your_auth_domain
FIREBASE_WEB_STORAGE_BUCKET=your_bucket
FIREBASE_WEB_MEASUREMENT_ID=your_measurement_id
FIREBASE_WEB_DATABASE_URL=your_database_url

# Maps
OSM_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

### 3. Ambientes Diferentes

Para diferentes ambientes (dev, staging, prod), crie arquivos separados:

```bash
.env.development
.env.staging
.env.production
```

E carregue o apropriado no `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Carregar arquivo baseado no ambiente
  await dotenv.load(fileName: '.env.development');
  
  runApp(MyApp());
}
```

---

## 🔥 Firebase Configuration

### Android

1. **Baixar `google-services.json`**
   - Ir para [Firebase Console](https://console.firebase.google.com/)
   - Selecionar seu projeto
   - Ir em Project Settings > Add Android app
   - Baixar `google-services.json`

2. **Colocar no projeto:**
   ```
   android/app/google-services.json
   ```

3. **Verificar `build.gradle`:**
   ```gradle
   // android/build.gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   
   // android/app/build.gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS

1. **Baixar `GoogleService-Info.plist`**
   - Ir para [Firebase Console](https://console.firebase.google.com/)
   - Selecionar seu projeto
   - Ir em Project Settings > Add iOS app
   - Baixar `GoogleService-Info.plist`

2. **Colocar no projeto:**
   ```
   ios/Runner/GoogleService-Info.plist
   ```

3. **Abrir no Xcode e adicionar ao target Runner**

### Web

Firebase Web é configurado automaticamente via `.env` no arquivo `lib/firebase_options.dart`.

---

## 🏃 Running the App

### Android

```bash
# Listar devices
flutter devices

# Run no emulador/device
flutter run

# Build APK
flutter build apk

# Build App Bundle (para Play Store)
flutter build appbundle
```

### iOS

```bash
# Run no simulador/device
flutter run

# Build IPA (requer certificado)
flutter build ios
```

### Web

```bash
# Run no navegador
flutter run -d chrome

# Build para produção
flutter build web
```

---

## 🔧 Comandos Úteis

### Clean Build

```bash
flutter clean
flutter pub get
```

### Upgrade Dependências

```bash
flutter pub upgrade
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
flutter format .
```

### Tests

```bash
flutter test
```

---

## 🐛 Troubleshooting

### Erro: "BASE_URL not found"

**Problema:** Variável de ambiente não carregada.

**Solução:**
1. Verificar se arquivo `.env` existe na raiz
2. Verificar se está listado em `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. Fazer clean build:
   ```bash
   flutter clean
   flutter pub get
   ```

---

### Erro: "Firebase not initialized"

**Problema:** Configuração Firebase incompleta.

**Solução:**
1. Verificar se `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS) está no lugar correto
2. Verificar se plugins Firebase estão instalados:
   ```bash
   flutter pub get
   ```
3. Rebuild:
   ```bash
   flutter clean
   flutter run
   ```

---

### Erro: "CocoaPods not installed" (iOS)

**Problema:** CocoaPods não instalado no macOS.

**Solução:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

---

### Erro: "Android SDK not found"

**Problema:** Android SDK não configurado.

**Solução:**
1. Baixar Android Studio
2. Instalar Android SDK via SDK Manager
3. Configurar `ANDROID_HOME`:
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```

---

### Erro: "Unable to connect to backend"

**Problema:** BASE_URL incorreta ou backend não rodando.

**Solução:**
1. Verificar se backend está rodando: `http://localhost:8080/health`
2. Se estiver no emulador Android, usar: `http://10.0.2.2:8080/api/v1`
3. Se estiver no device físico, usar IP da máquina: `http://192.168.x.x:8080/api/v1`

---

## 📚 Próximos Passos

Após setup completo:

1. **API Integration**: `/docs/api/API_COMPLETE_GUIDE.md`
2. **WebSocket**: `/docs/websocket/WEBSOCKET_GUIDE.md`
3. **UI/UX**: `/docs/ui-ux/WAZE_PANEL_GUIDE.md`
4. **HTTP Client**: `/docs/architecture/HTTP_CLIENT_GUIDE.md`

---

## ⚠️ Segurança

**IMPORTANTE:**

- ✅ Arquivo `.env` está no `.gitignore`
- ❌ **NUNCA** faça commit de `.env` com credenciais reais
- ✅ Use `.env.example` apenas com valores de exemplo
- ✅ Em produção, use variáveis de ambiente do CI/CD

---

**Última Atualização:** 17 de Novembro de 2025
