# 🚨 MakaNetu - Mobile App

> **MakaNetu** (Kimbundu: "Resolver problemas juntos" - maka = problema, netu = nosso)  
> Aplicativo mobile para reportar e receber alertas de incidentes de segurança em tempo real.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)

---

## 📋 Índice

- [🚨 MakaNetu - Mobile App](#-makanetu---mobile-app)
  - [📋 Índice](#-índice)
  - [🎯 Sobre o Projeto](#-sobre-o-projeto)
  - [✨ Funcionalidades](#-funcionalidades)
    - [✅ Implementadas](#-implementadas)
    - [🚧 Em Desenvolvimento](#-em-desenvolvimento)
  - [🚀 Setup Rápido (5 minutos)](#-setup-rápido-5-minutos)
  - [📖 Documentação](#-documentação)
  - [🏗️ Arquitetura](#️-arquitetura)
  - [🤝 Contribuindo](#-contribuindo)
  - [📝 License](#-license)
  - [👥 Team](#-team)
  - [📞 Suporte](#-suporte)
  - [🗺️ Roadmap](#️-roadmap)
    - [Q1 2025](#q1-2025)
    - [Q2 2025](#q2-2025)
    - [Q3 2025](#q3-2025)

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

## 🚀 Setup Rápido (5 minutos)

```bash
# 1. Clone
git clone https://github.com/risk-place-angola/mobile-risk-place.git
cd mobile-risk-place

# 2. Instale dependências
flutter pub get

# 3. Configure ambiente (opcional - valores padrão já funcionam)
cp .env.example .env

# 4. Execute!
flutter run
```

✨ **É só isso!** Firebase e backend já estão configurados.

📚 **Guia completo para desenvolvedores**: [`/docs/DEVELOPER_SETUP.md`](/docs/DEVELOPER_SETUP.md)

---

## 📖 Documentação

📚 **[Developer Setup](/docs/DEVELOPER_SETUP.md)** - Comece aqui!

**Recursos úteis:**
- [WebSocket & Location](/docs/features/LOCATION_TRACKING.md)
- [HTTP Client](/docs/architecture/HTTP_CLIENT_GUIDE.md)
- [API Guide](/docs/api/API_COMPLETE_GUIDE.md)
- [Logging Strategy](/docs/LOGGING_STRATEGY.md) - Boas práticas de logs

---

## 🏗️ Arquitetura

```
lib/
├── core/          # HTTP client, utils
├── data/          # Services, models
├── domain/        # Business logic
└── presenter/     # UI, widgets
```

**Stack:** Flutter 3.x • Riverpod • Firebase • WebSocket

---

## 🤝 Contribuindo

```bash
# 1. Fork e clone
# 2. Crie branch: feature/nome
# 3. Commit: feat: descrição
# 4. Push e abra PR para develop
```

**Code style:** `flutter analyze && dart format .`

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
- 
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

