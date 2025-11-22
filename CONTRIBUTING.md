# 🤝 Contribuindo para o MakaNetu

Obrigado por querer contribuir! Este guia vai te ajudar a fazer sua primeira contribuição.

---

## 🚀 Começando

### 1. Leia o Setup
Antes de tudo, configure seu ambiente: [`/docs/DEVELOPER_SETUP.md`](/docs/DEVELOPER_SETUP.md)

### 2. Encontre uma Issue
- Veja as [issues abertas](https://github.com/risk-place-angola/mobile-risk-place/issues)
- Issues marcadas com `good first issue` são ideais para iniciantes
- Issues marcadas com `help wanted` precisam de ajuda

### 3. Pergunte
Não entendeu algo? **Pergunte na issue!** Estamos aqui para ajudar.

---

## 🔀 Workflow

### 1️⃣ Fork e Clone
```bash
# Fork no GitHub (botão "Fork")
# Clone seu fork
git clone https://github.com/SEU-USUARIO/mobile-risk-place.git
cd mobile-risk-place
```

### 2️⃣ Crie uma Branch
```bash
# Sempre baseado em develop
git checkout develop
git pull origin develop

# Crie sua branch
git checkout -b feature/nome-descritivo
```

**Nomenclatura de branches:**
- `feature/` - Nova funcionalidade
- `fix/` - Correção de bug
- `docs/` - Apenas documentação
- `refactor/` - Refatoração de código
- `test/` - Adição de testes

### 3️⃣ Desenvolva
```bash
# Faça suas alterações
# Teste localmente
flutter run
flutter test

# Verifique o código
flutter analyze
dart format .
```

### 4️⃣ Commit
```bash
git add .
git commit -m "feat: adiciona feature X"
```

**Padrão de commits** (Conventional Commits):
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Formatação, ponto e vírgula, etc
- `refactor:` Refatoração de código
- `test:` Adição ou modificação de testes
- `chore:` Manutenção, dependências, etc

**Exemplos:**
```bash
git commit -m "feat: adiciona tela de perfil do usuário"
git commit -m "fix: corrige crash ao abrir mapa"
git commit -m "docs: atualiza README com setup iOS"
```

### 5️⃣ Push
```bash
git push origin feature/nome-descritivo
```

### 6️⃣ Pull Request
1. Abra um Pull Request no GitHub
2. **Base**: `develop` (não `main`!)
3. Preencha a descrição:
   - O que você fez?
   - Por que?
   - Como testar?
4. Aguarde review dos maintainers

---

## ✅ Checklist Antes do PR

Antes de abrir o Pull Request, verifique:

- [ ] Código compila sem erros (`flutter run`)
- [ ] Testes passam (`flutter test`)
- [ ] Sem warnings do analyzer (`flutter analyze`)
- [ ] Código formatado (`dart format .`)
- [ ] Commits seguem o padrão
- [ ] Branch baseada em `develop`
- [ ] Descrição clara do que foi feito
- [ ] Screenshots/GIFs se for UI

---

## 📝 Guia de Estilo

### Dart/Flutter
- Siga o [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` para formatar
- Evite comentários óbvios
- Documente funções públicas

### Commits
- Mensagens em português ou inglês (consistente)
- Primeira linha: máximo 50 caracteres
- Use presente: "adiciona" não "adicionou"

### Pull Requests
- Título claro e descritivo
- Descreva o problema/feature
- Inclua screenshots se UI
- Referencie issues: "Closes #123"

---

## 🧪 Testes

### Rodando Testes
```bash
# Todos os testes
flutter test

# Teste específico
flutter test test/nome_test.dart

# Com coverage
flutter test --coverage
```

### Escrevendo Testes
- Todo novo código deve ter testes
- Testes unitários em `test/`
- Testes de widget quando aplicável
- Mocks para serviços externos

---

## 🐛 Reportando Bugs

### Antes de Reportar
1. Procure se já existe issue similar
2. Teste na versão mais recente
3. Verifique se é reproduzível

### Informações Necessárias
- **Título claro**: "Crash ao abrir mapa"
- **Descrição**: O que aconteceu?
- **Passos para reproduzir**: Como replicar?
- **Esperado vs Atual**: O que deveria acontecer?
- **Ambiente**: 
  - OS: iOS 17.2 / Android 14
  - Device: iPhone 15 / Samsung S23
  - App version: 1.0.0
- **Logs/Screenshots**: Se possível

---

## 💡 Sugerindo Features

### Template de Feature Request

**Problema**: Qual problema isso resolve?  
**Solução proposta**: Como você imagina que funcione?  
**Alternativas**: Outras formas de resolver?  
**Contexto adicional**: Screenshots, mockups, etc.

---

## 🔍 Code Review

### O que os Maintainers Verificam

- ✅ Código funciona e está testado
- ✅ Segue padrões do projeto
- ✅ Sem código duplicado
- ✅ Performance adequada
- ✅ Acessibilidade (quando aplicável)
- ✅ Documentação atualizada

### Recebendo Feedback

- Seja receptivo a sugestões
- Faça perguntas se não entender
- Resolva os comentários
- Faça as alterações solicitadas
- Marque conversas como resolvidas

---

## 📚 Recursos

### Documentação do Projeto
- [Developer Setup](/docs/DEVELOPER_SETUP.md)
- [Firebase Setup](/docs/setup/FIREBASE_SETUP.md)
- [Architecture Guide](/docs/architecture/)

### Flutter/Dart
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

### Ferramentas
- [Riverpod](https://riverpod.dev/) - State Management
- [Firebase](https://firebase.flutter.dev/) - Backend
- [Hive](https://docs.hivedb.dev/) - Local Storage

---

## 🆘 Precisa de Ajuda?

### Onde Perguntar

1. **Issues do GitHub**: Para bugs e features
2. **Discussions**: Para perguntas gerais
3. **Pull Requests**: Para dúvidas sobre seu código
4. **Email**: tech@riskplace.ao (maintainers)

### Boas Práticas

- ✅ Seja respeitoso e paciente
- ✅ Forneça contexto suficiente
- ✅ Mostre o que você já tentou
- ✅ Compartilhe código e logs
- ❌ Não faça spam
- ❌ Não abra issues duplicadas

---

## 🎉 Primeira Contribuição?

Nunca contribuiu para open source? Sem problema!

1. Comece com algo pequeno (docs, typos, etc)
2. Issues marcadas `good first issue` são perfeitas
3. Não tenha medo de perguntar
4. Leia o código existente para aprender
5. Aprenda fazendo!

**Todo mundo foi iniciante um dia. Bem-vindo(a)!** 🚀

---

## 📜 Código de Conduta

Ao contribuir, você concorda em:

- Ser respeitoso com todos
- Aceitar feedback construtivo
- Focar no melhor para o projeto
- Seguir as guidelines do projeto

Comportamento inadequado não será tolerado.

---

## 🏆 Reconhecimento

Todos os contribuidores serão:
- Listados no README (Contributors)
- Mencionados nos release notes
- Parte da história do MakaNetu!

**Obrigado por contribuir!** ❤️

---

**Última atualização**: Novembro 2025  
**Maintainers**: [@risk-place-angola](https://github.com/risk-place-angola)
