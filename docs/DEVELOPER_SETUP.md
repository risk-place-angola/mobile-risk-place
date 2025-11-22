# 🚀 Setup para Desenvolvedores

Guia rápido para começar a desenvolver.

## ✅ Pré-requisitos

- Flutter 3.x
- Git
- VS Code ou Android Studio

## 📦 Setup (5 minutos)

```bash
# Clone
git clone https://github.com/risk-place-angola/mobile-risk-place.git
cd mobile-risk-place

# Instale dependências
flutter pub get

# Execute
flutter run
```

## 🔥 Firebase

Já está configurado! Não precisa fazer nada.

## 🔧 Comandos Básicos

```bash
# Rodar
flutter run

# Testes
flutter test

# Análise
flutter analyze
dart format .

# Limpar (se tiver problemas)
flutter clean && flutter pub get
```

## 🔀 Workflow

```bash
# 1. Criar branch
git checkout develop
git pull
git checkout -b feature/nome

# 2. Desenvolver e testar
flutter run
flutter test

# 3. Commit
git add .
git commit -m "feat: descrição"

# 4. Push e PR
git push origin feature/nome
```

Padrão de commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

## 🐛 Problemas Comuns

**iOS: Pod install failed**
```bash
cd ios && pod deintegrate && pod install && cd ..
```

**Android: Gradle failed**
```bash
cd android && ./gradlew clean && cd .. && flutter clean
```
