# 🚨 MakaNetu - Mobile App

> **MakaNetu** (Kimbundu: "Resolver problemas juntos" - maka = problema, netu = nosso)  
> Aplicativo mobile para reportar e receber alertas de incidentes de segurança em tempo real.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)

---

## 📋 Índice

1. [Sobre o Projeto](#sobre-o-projeto)
2. [Funcionalidades](#funcionalidades)
3. [Setup Rápido](#setup-rápido)
4. [Documentação](#documentação)
5. [Arquitetura](#arquitetura)
6. [Tecnologias](#tecnologias)
7. [Contribuindo](#contribuindo)

---

## 🎯 Sobre o Projeto

**MakaNetu** (conhecido como **Maka**) é um aplicativo mobile que permite aos cidadãos:
- **Reportar incidentes** de segurança em tempo real
- **Receber alertas** de perigos próximos (estilo Waze)
- **Visualizar no mapa** relatórios e alertas da comunidade
- **Rotas seguras** baseadas em dados reais

---

## ✨ Funcionalidades

### ✅ Implementadas

- 🔐 **Autenticação completa** (Login, Signup, Reset Password)
- 📡 **API Integration** com backend REST
- 🔌 **WebSocket** para alertas em tempo real
- 🗺️ **Mapa interativo** com markers e círculos de raio
- 📍 **Relatórios georreferenciados**
- 🚨 **Sistema de alertas** para autoridades
- 🎨 **Painel estilo Waze** (draggable bottom sheet)
- 🔔 **Notificações push** (em desenvolvimento)
- 🔧 **HTTP Client robusto** com tratamento de erros
- 📊 **Gestão de estado** com Riverpod

### 🚧 Em Desenvolvimento

- 🛣️ **Rotas seguras** com algoritmo de pathfinding
- 👥 **Sistema de comunidade**
- 📈 **Analytics e estatísticas**
- 🌐 **Multi-idioma** (Português, Inglês)

---

## 🚀 Setup Rápido

### 1. Clone o Repositório

```bash
git clone https://github.com/risk-place-angola/mobile-risk-place.git
cd mobile-risk-place
```

### 2. Instale Dependências

```bash
flutter pub get
```

### 3. Configure Variáveis de Ambiente

```bash
cp .env.example .env
# Edite .env com suas credenciais
```

### 4. Execute o App

```bash
flutter run
```

📚 **Setup Completo**: [`/docs/setup/ENVIRONMENT_SETUP.md`](/docs/setup/ENVIRONMENT_SETUP.md)

---

## 📖 Documentação

### 🎓 Getting Started

| Documento | Descrição |
|-----------|-----------|
| [⚙️ Environment Setup](/docs/setup/ENVIRONMENT_SETUP.md) | Configuração inicial, Firebase, variáveis de ambiente |
| [⚡ Quick Reference](/docs/QUICK_REFERENCE.md) | Cheat sheet com snippets prontos para usar |

### 🔧 Architecture & Development

| Documento | Descrição |
|-----------|-----------|
| [🔧 HTTP Client Guide](/docs/architecture/HTTP_CLIENT_GUIDE.md) | Sistema HTTP refatorado, interceptors, exceções |

### 📡 API & Backend Integration

| Documento | Descrição |
|-----------|-----------|
| [📡 API Complete Guide](/docs/api/API_COMPLETE_GUIDE.md) | Todos os endpoints, exemplos de código, troubleshooting |

### 🔌 Real-Time Features

| Documento | Descrição |
|-----------|-----------|
| [🔌 WebSocket Guide](/docs/websocket/WEBSOCKET_GUIDE.md) | Alertas em tempo real, atualização de localização |
| [📍 Location Tracking](/docs/features/LOCATION_TRACKING.md) | Rastreamento GPS automático, updates via WebSocket |

### 👤 Features

| Documento | Descrição |
|-----------|-----------|
| [👻 Anonymous Users](/docs/features/ANONYMOUS_USERS.md) | Sistema Waze-style para usuários sem cadastro |
| [📱 FCM iOS Setup](/docs/setup/FCM_IOS_SETUP.md) | Configuração de Push Notifications para iOS |

### 🎨 UI/UX

| Documento | Descrição |
|-----------|-----------|
| [🎨 Waze Panel Guide](/docs/ui-ux/WAZE_PANEL_GUIDE.md) | Painel deslizante, quick actions, animações |

---

## 🏗️ Arquitetura

### Estrutura do Projeto

```
lib/
├── core/                           # Camada core (infraestrutura)
│   ├── http_client/                # Cliente HTTP + interceptors
│   │   ├── dio_http_client.dart
│   │   ├── interceptors/
│   │   └── exceptions/
│   └── services/                   # Serviços globais
│       └── notification_service.dart
├── data/                           # Camada de dados
│   ├── dtos/                       # Data Transfer Objects
│   ├── services/                   # Serviços de API
│   │   ├── auth.service.dart
│   │   ├── risk_types.service.dart
│   │   ├── report.service.dart
│   │   ├── alert.service.dart
│   │   └── alert_websocket_service.dart
│   └── providers/                  # Riverpod Providers
│       ├── api_providers.dart
│       └── websocket_notifications_provider.dart
└── presenter/                      # Camada de apresentação
    ├── controllers/                # Controllers (Riverpod)
    ├── pages/                      # Telas
    └── widgets/                    # Componentes reutilizáveis
```

### Fluxo de Dados

```
UI (Widget)
    ↓
Provider (Riverpod)
    ↓
Service (Business Logic)
    ↓
HTTP Client (Dio + Interceptors)
    ↓
Backend API
```

### Tecnologias de Arquitetura

- **Clean Architecture** (Core, Data, Presenter)
- **SOLID Principles**
- **Dependency Injection** via Riverpod
- **Interface Segregation** (IHttpClient)
- **Repository Pattern** (Services)

---

## 🛠️ Tecnologias

### Core

- **Flutter** 3.0+ - Framework UI
- **Dart** 3.0+ - Linguagem
- **Riverpod** 2.0+ - State Management

### Network

- **Dio** 5.0+ - HTTP Client
- **WebSocket Channel** 2.4+ - Real-time communication

### Maps

- **Flutter Map** - OpenStreetMap integration
- **Geolocator** 10.0+ - Geolocation

### Firebase

- **Firebase Core** - Base SDK
- **Firebase Auth** - Autenticação
- **Firebase Storage** - Armazenamento de imagens
- **Firebase Database** - Realtime Database

### Utils

- **Flutter Dotenv** - Environment variables
- **Unicons Line** - Ícones

---

## 🤝 Contribuindo

### Branch Strategy

- `main` - Produção
- `develop` - Desenvolvimento
- `feature/*` - Novas features
- `bugfix/*` - Correções

### Workflow

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. **Crie** uma branch: `git checkout -b feature/minha-feature`
4. **Commit** suas mudanças: `git commit -m 'Add: minha feature'`
5. **Push** para a branch: `git push origin feature/minha-feature`
6. **Abra** um Pull Request

### Code Style

- Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Executar `flutter format .` antes de commit
- Executar `flutter analyze` para verificar erros

---

## 📝 License

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👥 Team

**Risk Place Angola Team**

- Backend Developer: [Nome]
- Mobile Developer: [Nome]
- UI/UX Designer: [Nome]

---

## 📞 Suporte

- **Documentação**: [`/docs`](/docs)
- **Issues**: [GitHub Issues](https://github.com/risk-place-angola/mobile-risk-place/issues)
- **Email**: suporte@riskplace.ao

---

## 🗺️ Roadmap

### Q1 2025
- [ ] Sistema de rotas seguras
- [ ] Notificações push completas
- [ ] Multi-idioma (PT/EN)

### Q2 2025
- [ ] Analytics dashboard
- [ ] Sistema de comunidade
- [ ] Gamificação

### Q3 2025
- [ ] App iOS release
- [ ] Integração com autoridades
- [ ] API pública

---

**Última Atualização:** 17 de Novembro de 2025  
**Versão:** 1.0.0

