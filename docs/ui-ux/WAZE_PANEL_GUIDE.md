# 🎨 UI/UX - Waze-Inspired Panel Guide
**Risk Place Mobile**

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura 4-Layer](#arquitetura-4-layer)
3. [Componentes](#componentes)
4. [Estados do Panel](#estados-do-panel)
5. [Interações](#interações)
6. [Quick Reference](#quick-reference)

---

## 🎯 Visão Geral

Painel deslizante inspirado no Waze, implementado para fornecer acesso rápido a navegação, relatórios de incidentes e recursos de segurança.

### Características Principais

✅ **Draggable bottom sheet** com 3 estados de altura  
✅ **Gesture detection** (drag up/down)  
✅ **Auto-snap** ao estado mais próximo  
✅ **Animações suaves** (300ms, easeInOut)  
✅ **4 Quick Actions** customizáveis  
✅ **Recent Items** (últimos 5 acessos)  
✅ **More Options** (7 opções secundárias)  

---

## 📐 Arquitetura 4-Layer

### Estrutura em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                     Layer 4: Bottom Nav                      │
│         Alerts | Map | Community | Notifications            │
└─────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────┐
│                   Layer 3: Home Panel                        │
│              (Draggable bottom sheet)                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ • Search bar                                         │  │
│  │ • Quick actions                                      │  │
│  │ • Recent items                                       │  │
│  │ • More options                                       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────┐
│              Layer 2: Floating Profile Button                │
│                    (Top-right corner)                        │
└─────────────────────────────────────────────────────────────┘
                            ↑
┌─────────────────────────────────────────────────────────────┐
│                    Layer 1: Map View                         │
│                  (Flutter Map + Markers)                     │
└─────────────────────────────────────────────────────────────┘
```

### Implementação em Stack

```dart
Stack(
  children: [
    // Layer 1: Mapa
    FlutterMap(...),
    
    // Layer 2: Perfil flutuante
    Positioned(
      top: 50,
      right: 20,
      child: FloatingProfileButton(...),
    ),
    
    // Layer 3: Painel deslizante
    RiskPlaceHomePanel(
      onSearchTap: () => navigateToSearch(),
      onVoiceSearchTap: () => startVoiceSearch(),
    ),
  ],
)
// Layer 4: Bottom Nav está fora do Stack, no Scaffold
```

---

## 🧩 Componentes

### 1. State Controller

**Arquivo:** `lib/presenter/controllers/home_panel.controller.dart`

```dart
class HomePanelController extends ChangeNotifier {
  PanelState _state = PanelState.collapsed;
  List<RecentItem> _recentItems = [];
  String? _homeAddress;
  String? _workAddress;
  bool _isSearchFocused = false;

  // Estados
  PanelState get state => _state;
  
  void expandPanel() {
    _state = PanelState.expanded;
    notifyListeners();
  }
  
  void collapsePanel() {
    _state = PanelState.collapsed;
    notifyListeners();
  }
  
  void hidePanel() {
    _state = PanelState.hidden;
    notifyListeners();
  }
  
  void showPanel() {
    _state = PanelState.collapsed;
    notifyListeners();
  }
  
  // Recent Items
  void addRecentItem(RecentItem item) {
    _recentItems.insert(0, item);
    if (_recentItems.length > 10) {
      _recentItems.removeLast();
    }
    notifyListeners();
  }
  
  void clearRecentItems() {
    _recentItems.clear();
    notifyListeners();
  }
  
  // Endereços
  void setHomeAddress(String address) {
    _homeAddress = address;
    notifyListeners();
  }
  
  void setWorkAddress(String address) {
    _workAddress = address;
    notifyListeners();
  }
}

enum PanelState {
  collapsed,  // 100px
  medium,     // 240px
  expanded,   // 600px
  hidden,     // 0px
}

enum RecentItemType {
  neighborhood,  // 🏙️ Azul
  incident,      // ⚠️ Vermelho
  safeRoute,     // 🛣️ Verde
  location,      // 📍 Laranja
}
```

---

### 2. Main Panel Widget

**Arquivo:** `lib/presenter/pages/home_page/widgets/home_panel.widget.dart`

```dart
class RiskPlaceHomePanel extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceSearchTap;

  const RiskPlaceHomePanel({
    Key? key,
    this.onSearchTap,
    this.onVoiceSearchTap,
  }) : super(key: key);

  @override
  _RiskPlaceHomePanelState createState() => _RiskPlaceHomePanelState();
}

class _RiskPlaceHomePanelState extends ConsumerState<RiskPlaceHomePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  
  double _currentHeight = 100; // Collapsed inicial
  
  // Alturas dos estados
  static const double collapsedHeight = 100;
  static const double mediumHeight = 240;
  static const double expandedHeight = 600;
  static const double hiddenHeight = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(
      begin: collapsedHeight,
      end: expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onPanelDrag(DragUpdateDetails details) {
    setState(() {
      _currentHeight -= details.delta.dy;
      _currentHeight = _currentHeight.clamp(hiddenHeight, expandedHeight);
    });
  }

  void _onPanelDragEnd(DragEndDetails details) {
    // Auto-snap ao estado mais próximo
    double targetHeight;
    
    if (_currentHeight < 50) {
      targetHeight = hiddenHeight;
    } else if (_currentHeight < 170) {
      targetHeight = collapsedHeight;
    } else if (_currentHeight < 420) {
      targetHeight = mediumHeight;
    } else {
      targetHeight = expandedHeight;
    }
    
    _animateToHeight(targetHeight);
  }

  void _animateToHeight(double targetHeight) {
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: targetHeight,
    ).animate(_animationController);
    
    _animationController.forward(from: 0).then((_) {
      setState(() {
        _currentHeight = targetHeight;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _onPanelDrag,
        onVerticalDragEnd: _onPanelDragEnd,
        child: AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            final height = _heightAnimation.value;
            
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  _buildDragHandle(),
                  
                  // Conteúdo baseado na altura
                  if (height > 50) ...[
                    SearchBarWidget(
                      onSearchTap: widget.onSearchTap,
                      onVoiceSearchTap: widget.onVoiceSearchTap,
                    ),
                  ],
                  
                  if (height > 150) ...[
                    QuickActionsRow(),
                  ],
                  
                  if (height > 300) ...[
                    RecentSection(),
                    MoreOptionsSection(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

---

### 3. Search Bar

**Arquivo:** `lib/presenter/pages/home_page/widgets/search_bar.widget.dart`

```dart
class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceSearchTap;

  const SearchBarWidget({
    Key? key,
    this.onSearchTap,
    this.onVoiceSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(UniconsLine.search, size: 24, color: Colors.grey[600]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Onde você quer ir?',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onVoiceSearchTap,
                child: Icon(UniconsLine.microphone, size: 24, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 4. Quick Actions

**Arquivo:** `lib/presenter/pages/home_page/widgets/quick_action_button.widget.dart`

```dart
class QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: UniconsLine.home,
            label: 'Home',
            iconColor: Colors.blue,
            backgroundColor: Colors.blue.withOpacity(0.1),
            onTap: () => print('Navigate to Home'),
          ),
          QuickActionButton(
            icon: UniconsLine.briefcase,
            label: 'Work',
            iconColor: Colors.purple,
            backgroundColor: Colors.purple.withOpacity(0.1),
            onTap: () => print('Navigate to Work'),
          ),
          QuickActionButton(
            icon: UniconsLine.plus,
            label: 'Add Safe',
            iconColor: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.1),
            onTap: () => print('Add Safe Place'),
          ),
          QuickActionButton(
            icon: UniconsLine.exclamation_triangle,
            label: 'Report',
            iconColor: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.1),
            onTap: () => print('Report Incident'),
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const QuickActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
```

---

### 5. Recent Section

**Arquivo:** `lib/presenter/pages/home_page/widgets/recent_section.widget.dart`

```dart
class RecentSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(homePanelControllerProvider);
    final recentItems = controller.recentItems.take(5).toList();

    if (recentItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recentItems.length,
          itemBuilder: (context, index) {
            final item = recentItems[index];
            return ListTile(
              leading: Icon(
                _getIconForType(item.type),
                color: _getColorForType(item.type),
              ),
              title: Text(item.title),
              subtitle: Text(item.subtitle ?? ''),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => print('Open ${item.title}'),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForType(RecentItemType type) {
    switch (type) {
      case RecentItemType.neighborhood:
        return UniconsLine.building;
      case RecentItemType.incident:
        return UniconsLine.exclamation_triangle;
      case RecentItemType.safeRoute:
        return UniconsLine.map;
      case RecentItemType.location:
        return UniconsLine.map_marker;
    }
  }

  Color _getColorForType(RecentItemType type) {
    switch (type) {
      case RecentItemType.neighborhood:
        return Colors.blue;
      case RecentItemType.incident:
        return Colors.red;
      case RecentItemType.safeRoute:
        return Colors.green;
      case RecentItemType.location:
        return Colors.orange;
    }
  }
}
```

---

### 6. More Options

**Arquivo:** `lib/presenter/pages/home_page/widgets/more_options_section.widget.dart`

```dart
class MoreOptionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Mais Opções',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildOption(
          icon: UniconsLine.star,
          title: 'Lugares Salvos',
          onTap: () => print('Saved Places'),
        ),
        _buildOption(
          icon: UniconsLine.users_alt,
          title: 'Contatos de Emergência',
          onTap: () => print('Emergency Contacts'),
        ),
        _buildOption(
          icon: UniconsLine.share,
          title: 'Compartilhar Localização',
          onTap: () => print('Share Location'),
        ),
        _buildOption(
          icon: UniconsLine.shield_check,
          title: 'Verificar Rota Segura',
          onTap: () => print('Check Safe Route'),
        ),
        _buildOption(
          icon: UniconsLine.history,
          title: 'Histórico de Incidentes',
          onTap: () => print('Incident History'),
        ),
        _buildOption(
          icon: UniconsLine.phone,
          title: 'Serviços de Emergência',
          onTap: () => print('Call 112'),
        ),
        _buildOption(
          icon: UniconsLine.calendar_alt,
          title: 'Conectar Calendário',
          onTap: () => print('Connect Calendar'),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
```

---

## 📊 Estados do Panel

### Tabela de Estados

| Estado | Altura | Conteúdo Visível | Uso |
|--------|--------|------------------|-----|
| **Hidden** | 0px | Nada | Ao mostrar detalhes de marker |
| **Collapsed** | 100px | Search bar apenas | Estado padrão no mapa |
| **Medium** | 240px | Search + Quick actions | Acesso rápido |
| **Expanded** | 600px | Todo conteúdo | Explorar opções |

### Transições

```
Hidden (0px)
    ↕ drag up/down
Collapsed (100px)
    ↕ drag up
Medium (240px)
    ↕ drag up
Expanded (600px)
    ↕ drag down
Medium → Collapsed → Hidden
```

---

## 🎭 Interações

### Gestos

- **Drag Up:** Expandir painel
- **Drag Down:** Colapsar painel
- **Tap Search:** Navegar para tela de busca
- **Tap Voice:** Iniciar busca por voz
- **Tap Quick Action:** Executar ação rápida
- **Tap Recent Item:** Abrir item recente
- **Tap More Option:** Executar opção

### Auto-Snap

O painel automaticamente "gruda" no estado mais próximo:

```dart
if (_currentHeight < 50) {
  targetHeight = hiddenHeight;  // 0px
} else if (_currentHeight < 170) {
  targetHeight = collapsedHeight;  // 100px
} else if (_currentHeight < 420) {
  targetHeight = mediumHeight;  // 240px
} else {
  targetHeight = expandedHeight;  // 600px
}
```

---

## 🎯 Quick Reference

### Import do Panel

```dart
import 'package:rpa/presenter/pages/home_page/widgets/home_panel.widget.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
```

### Adicionar à View

```dart
Stack(
  children: [
    YourMapWidget(),
    RiskPlaceHomePanel(
      onSearchTap: () => navigateToSearch(),
      onVoiceSearchTap: () => startVoiceSearch(),
    ),
  ],
)
```

### Controlar o Panel

```dart
final controller = ref.read(homePanelControllerProvider);

// Estados
controller.expandPanel();    // Expandir
controller.collapsePanel();  // Colapsar
controller.hidePanel();      // Esconder
controller.showPanel();      // Mostrar

// Dados
controller.addRecentItem(item);       // Adicionar recente
controller.clearRecentItems();        // Limpar recentes
controller.setHomeAddress('Home');    // Definir casa
controller.setWorkAddress('Work');    // Definir trabalho
```

### Quick Actions Padrão

| Ícone | Label | Cor | Ação |
|-------|-------|-----|------|
| 🏠 | Home | Azul | Navegar para casa |
| 💼 | Work | Roxo | Navegar para trabalho |
| ➕ | Add Safe | Verde | Marcar lugar seguro |
| ⚠️ | Report | Vermelho | Reportar incidente |

### Customizar Quick Action

```dart
QuickActionButton(
  icon: UniconsLine.your_icon,
  label: 'Your Label',
  iconColor: Colors.yourColor,
  backgroundColor: Colors.yourColor.withOpacity(0.1),
  onTap: () => yourAction(),
)
```

---

## 📚 Recursos Adicionais

- **API Integration**: `/docs/api/API_COMPLETE_GUIDE.md`
- **WebSocket**: `/docs/websocket/WEBSOCKET_GUIDE.md`
- **HTTP Client**: `/docs/architecture/HTTP_CLIENT_GUIDE.md`

---

**Última Atualização:** 17 de Novembro de 2025
