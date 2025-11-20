import 'package:flutter/material.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:intl/intl.dart';
import 'package:rpa/core/services/risk_topic_translation_service.dart';
import 'package:rpa/core/utils/risk_icons.dart';

class UserAlertTile extends StatelessWidget {
  final UserAlert alert;
  final bool isCreatedByMe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubscribe;
  final VoidCallback? onUnsubscribe;
  final VoidCallback? onViewOnMap;

  const UserAlertTile({
    super.key,
    required this.alert,
    required this.isCreatedByMe,
    this.onEdit,
    this.onDelete,
    this.onSubscribe,
    this.onUnsubscribe,
    this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSeverityColor().withOpacity(0.2),
              child: ClipOval(
                child: Image.asset(
                  RiskIcons.getLocalIconForRiskTopic(alert.riskTopicName),
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _getSeverityIcon(),
                      color: _getSeverityColor(),
                    );
                  },
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    RiskTopicTranslationService.translateTopic(
                      context,
                      alert.riskTopicName,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  alert.riskTypeName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _buildSeverityChip(),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => _buildMenuItems(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildLocationInfo(),
                const SizedBox(height: 8),
                _buildMetadata(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (alert.status) {
      case AlertStatus.active:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Ativo';
        break;
      case AlertStatus.resolved:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        label = 'Resolvido';
        break;
      case AlertStatus.expired:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        label = 'Expirado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSeverityChip() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getSeverityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: _getSeverityColor(),
          ),
          const SizedBox(width: 4),
          Text(
            alert.severity.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getSeverityColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${alert.neighborhood ?? alert.municipality}, ${alert.province}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          '${(alert.radiusMeters / 1000).toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          dateFormat.format(alert.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        if (alert.subscribers != null) ...[
          const SizedBox(width: 16),
          Icon(Icons.people, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            '${alert.subscribers} inscritos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    if (onViewOnMap != null) {
      items.add(
        const PopupMenuItem(
          value: 'view_map',
          child: Row(
            children: [
              Icon(Icons.map, size: 20),
              SizedBox(width: 12),
              Text('Ver no Mapa'),
            ],
          ),
        ),
      );
    }

    if (isCreatedByMe) {
      if (onEdit != null) {
        items.add(
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 12),
                Text('Editar'),
              ],
            ),
          ),
        );
      }
      if (onDelete != null) {
        items.add(
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Text('Deletar', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      }
    } else {
      if (alert.isSubscribed && onUnsubscribe != null) {
        items.add(
          const PopupMenuItem(
            value: 'unsubscribe',
            child: Row(
              children: [
                Icon(Icons.notifications_off, size: 20),
                SizedBox(width: 12),
                Text('Cancelar Inscrição'),
              ],
            ),
          ),
        );
      } else if (!alert.isSubscribed && onSubscribe != null) {
        items.add(
          const PopupMenuItem(
            value: 'subscribe',
            child: Row(
              children: [
                Icon(Icons.notifications_active, size: 20),
                SizedBox(width: 12),
                Text('Inscrever'),
              ],
            ),
          ),
        );
      }
    }

    return items;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_map':
        onViewOnMap?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
      case 'subscribe':
        onSubscribe?.call();
        break;
      case 'unsubscribe':
        onUnsubscribe?.call();
        break;
    }
  }

  Color _getSeverityColor() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.deepOrange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return Icons.info;
      case AlertSeverity.medium:
        return Icons.warning_amber;
      case AlertSeverity.high:
        return Icons.warning;
      case AlertSeverity.critical:
        return Icons.dangerous;
    }
  }
}
