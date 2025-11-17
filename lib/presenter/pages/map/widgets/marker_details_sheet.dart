import 'package:flutter/material.dart';
import 'package:rpa/data/models/enums/risk_type.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';

/// Bottom sheet to show alert details
class AlertDetailsSheet extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsSheet({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final riskType = alert.riskType ?? RiskType.infrastructure;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header with icon and type
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getAlertColor(riskType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAlertIcon(riskType),
                  color: _getAlertColor(riskType),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚨 ALERTA DE EMERGÊNCIA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getAlertColor(riskType),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskTypeLabel(riskType),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alert.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details
          _buildDetailRow(
            Icons.location_on_rounded,
            'Raio de Alcance',
            '${(alert.radius / 1000).toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time_rounded,
            'Horário',
            alert.createdAt != null 
                ? _formatDateTime(alert.createdAt!)
                : 'Agora',
          ),
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Fechar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to alert details page
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.info_rounded),
                  label: const Text('Mais Detalhes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _getAlertColor(riskType),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getAlertColor(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return const Color(0xFFD32F2F);
      case RiskType.fire:
        return const Color(0xFFFF6F00);
      case RiskType.traffic:
        return const Color(0xFFFFA000);
      case RiskType.infrastructure:
        return const Color(0xFF1976D2);
      case RiskType.flood:
        return const Color(0xFF0288D1);
    }
  }

  IconData _getAlertIcon(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return Icons.warning_rounded;
      case RiskType.fire:
        return Icons.local_fire_department_rounded;
      case RiskType.traffic:
        return Icons.traffic_rounded;
      case RiskType.infrastructure:
        return Icons.construction_rounded;
      case RiskType.flood:
        return Icons.water_damage_rounded;
    }
  }

  String _getRiskTypeLabel(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return 'Violência';
      case RiskType.fire:
        return 'Incêndio';
      case RiskType.traffic:
        return 'Trânsito';
      case RiskType.infrastructure:
        return 'Infraestrutura';
      case RiskType.flood:
        return 'Inundação';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inHours < 1) {
      return 'Há ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Há ${diff.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Bottom sheet to show report details
class ReportDetailsSheet extends StatelessWidget {
  final ReportModel report;
  final Function(ReportModel)? onEditLocation;

  const ReportDetailsSheet({
    super.key,
    required this.report,
    this.onEditLocation,
  });

  @override
  Widget build(BuildContext context) {
    final riskType = report.riskType ?? RiskType.infrastructure;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header with icon and type
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getReportColor(riskType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getReportIcon(riskType),
                  color: _getReportColor(riskType),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 REPORT DA COMUNIDADE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getReportColor(riskType),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskTypeLabel(riskType),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.status == ReportStatus.verified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Verificado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (report.status == ReportStatus.resolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Resolvido',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Details
          _buildDetailRow(
            Icons.access_time_rounded,
            'Reportado',
            report.createdAt != null 
                ? _formatDateTime(report.createdAt!)
                : 'Agora',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.info_outline_rounded,
            'Status',
            _getStatusLabel(report.status),
          ),
          const SizedBox(height: 24),
          
          // Actions
          if (onEditLocation != null && report.status == ReportStatus.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEditLocation?.call(report);
                  },
                  icon: const Icon(Icons.edit_location_outlined),
                  label: const Text('Editar Localização'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Fechar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to report details page
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Ver Detalhes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _getReportColor(riskType),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getReportColor(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return const Color(0xFFE57373);
      case RiskType.fire:
        return const Color(0xFFFFB74D);
      case RiskType.traffic:
        return const Color(0xFFFFD54F);
      case RiskType.infrastructure:
        return const Color(0xFF64B5F6);
      case RiskType.flood:
        return const Color(0xFF4FC3F7);
    }
  }

  IconData _getReportIcon(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return Icons.report_problem_outlined;
      case RiskType.fire:
        return Icons.local_fire_department_outlined;
      case RiskType.traffic:
        return Icons.traffic_outlined;
      case RiskType.infrastructure:
        return Icons.construction_outlined;
      case RiskType.flood:
        return Icons.water_outlined;
    }
  }

  String _getRiskTypeLabel(RiskType type) {
    switch (type) {
      case RiskType.violence:
        return 'Violência';
      case RiskType.fire:
        return 'Incêndio';
      case RiskType.traffic:
        return 'Trânsito';
      case RiskType.infrastructure:
        return 'Infraestrutura';
      case RiskType.flood:
        return 'Inundação';
    }
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendente';
      case ReportStatus.verified:
        return 'Verificado';
      case ReportStatus.resolved:
        return 'Resolvido';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inHours < 1) {
      return 'Há ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Há ${diff.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
