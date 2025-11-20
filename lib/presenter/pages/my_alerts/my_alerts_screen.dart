import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/services/alert.service.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/presenter/widgets/user_alert_tile.dart';
import 'package:rpa/presenter/widgets/edit_alert_dialog.dart';
import 'package:rpa/core/error/error_handler.dart';

class MyAlertsScreen extends ConsumerStatefulWidget {
  const MyAlertsScreen({super.key});

  @override
  ConsumerState<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends ConsumerState<MyAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingCreated = false;
  bool _isLoadingSubscribed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myAlerts ?? 'My Alerts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n?.createdByMe ?? 'Created by Me'),
            Tab(text: l10n?.subscribed ?? 'Subscribed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreatedAlertsTab(),
          _buildSubscribedAlertsTab(),
        ],
      ),
    );
  }

  Widget _buildCreatedAlertsTab() {
    final alertService = ref.watch(alertServiceProvider);

    return FutureBuilder<List<UserAlert>>(
      future: alertService.getMyAlerts(forceRefresh: _isLoadingCreated),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isLoadingCreated) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(
            message: 'Erro ao carregar alertas criados',
            onRetry: () => _refreshCreatedAlerts(),
          );
        }

        final alerts = snapshot.data ?? [];

        if (alerts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.add_alert,
            message: 'Você ainda não criou nenhum alerta',
            description: 'Toque no mapa para criar seu primeiro alerta',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshCreatedAlerts,
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return UserAlertTile(
                alert: alert,
                isCreatedByMe: true,
                onEdit: () => _handleEditAlert(alert),
                onDelete: () => _handleDeleteAlert(alert),
                onViewOnMap: () => _handleViewOnMap(alert),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubscribedAlertsTab() {
    final alertService = ref.watch(alertServiceProvider);

    return FutureBuilder<List<UserAlert>>(
      future:
          alertService.getSubscribedAlerts(forceRefresh: _isLoadingSubscribed),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isLoadingSubscribed) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(
            message: 'Erro ao carregar alertas inscritos',
            onRetry: () => _refreshSubscribedAlerts(),
          );
        }

        final alerts = snapshot.data ?? [];

        if (alerts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.notifications_none,
            message: 'Você não está inscrito em nenhum alerta',
            description:
                'Inscreva-se em alertas no mapa para receber notificações',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshSubscribedAlerts,
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return UserAlertTile(
                alert: alert,
                isCreatedByMe: false,
                onSubscribe:
                    alert.isSubscribed ? null : () => _handleSubscribe(alert),
                onUnsubscribe:
                    alert.isSubscribed ? () => _handleUnsubscribe(alert) : null,
                onViewOnMap: () => _handleViewOnMap(alert),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshCreatedAlerts() async {
    setState(() => _isLoadingCreated = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoadingCreated = false);
  }

  Future<void> _refreshSubscribedAlerts() async {
    setState(() => _isLoadingSubscribed = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoadingSubscribed = false);
  }

  Future<void> _handleEditAlert(UserAlert alert) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditAlertDialog(alert: alert),
    );

    if (result != null && mounted) {
      try {
        final alertService = ref.read(alertServiceProvider);
        await alertService.updateAlert(
          alertId: alert.id,
          message: result['message'] as String,
          severity: result['severity'] as AlertSeverity,
          radiusMeters: result['radiusMeters'] as int,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta atualizado com sucesso')),
          );
          _refreshCreatedAlerts();
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _handleDeleteAlert(UserAlert alert) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmDeletion ?? 'Confirm Deletion'),
        content: Text(l10n?.areYouSureDelete ??
            'Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final alertService = ref.read(alertServiceProvider);
        await alertService.deleteAlert(alert.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta excluído com sucesso')),
          );
          _refreshCreatedAlerts();
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _handleSubscribe(UserAlert alert) async {
    try {
      final alertService = ref.read(alertServiceProvider);
      await alertService.subscribeToAlert(alert.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscrito no alerta com sucesso')),
        );
        _refreshSubscribedAlerts();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _handleUnsubscribe(UserAlert alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelamento'),
        content: const Text(
          'Tem certeza que deseja cancelar a inscrição neste alerta? '
          'Você não receberá mais notificações sobre ele.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final alertService = ref.read(alertServiceProvider);
        await alertService.unsubscribeFromAlert(alert.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscrição cancelada com sucesso')),
          );
          _refreshSubscribedAlerts();
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  void _handleViewOnMap(UserAlert alert) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando para alerta: ${alert.riskTopicName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
