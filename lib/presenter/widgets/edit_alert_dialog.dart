import 'package:flutter/material.dart';
import 'package:rpa/domain/entities/user_alert.dart';

class EditAlertDialog extends StatefulWidget {
  final UserAlert alert;

  const EditAlertDialog({super.key, required this.alert});

  @override
  State<EditAlertDialog> createState() => _EditAlertDialogState();
}

class _EditAlertDialogState extends State<EditAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _messageController;
  late TextEditingController _radiusController;
  late AlertSeverity _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.alert.message);
    _radiusController = TextEditingController(
      text: widget.alert.radiusMeters.toString(),
    );
    _selectedSeverity = widget.alert.severity;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Alerta',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atualize a mensagem, gravidade ou raio do alerta.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mensagem *',
                    hintText: 'Descreva o alerta',
                    prefixIcon: Icon(Icons.message),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mensagem é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AlertSeverity>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Gravidade',
                    prefixIcon: Icon(Icons.warning),
                    border: OutlineInputBorder(),
                  ),
                  items: AlertSeverity.values.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getSeverityColor(severity),
                          ),
                          const SizedBox(width: 8),
                          Text(severity.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSeverity = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Raio (metros) *',
                    hintText: '100 - 10000',
                    prefixIcon: Icon(Icons.radio_button_unchecked),
                    border: OutlineInputBorder(),
                    suffixText: 'm',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Raio é obrigatório';
                    }
                    final radius = int.tryParse(value);
                    if (radius == null) {
                      return 'Valor inválido';
                    }
                    if (radius < 100 || radius > 10000) {
                      return 'Raio deve estar entre 100 e 10.000m';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'As alterações serão aplicadas imediatamente e os inscritos serão notificados.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'message': _messageController.text.trim(),
        'severity': _selectedSeverity,
        'radiusMeters': int.parse(_radiusController.text.trim()),
      };
      Navigator.of(context).pop(result);
    }
  }
}
