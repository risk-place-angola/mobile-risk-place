import 'package:flutter/material.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/l10n/app_localizations.dart';

class AddEmergencyContactDialog extends StatefulWidget {
  final EmergencyContact? contact;

  const AddEmergencyContactDialog({super.key, this.contact});

  @override
  State<AddEmergencyContactDialog> createState() =>
      _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<AddEmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late ContactRelation _selectedRelation;
  late bool _isPriority;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneController = TextEditingController(text: widget.contact?.phone);
    _selectedRelation = widget.contact?.relation ?? ContactRelation.family;
    _isPriority = widget.contact?.isPriority ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.contact != null;

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
                  isEditing ? (l10n?.editContact ?? 'Editar Contato') : (l10n?.addContact ?? 'Adicionar Contato'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.configureEmergencyContact ?? 'Configure um contato de emergência para ser notificado em situações críticas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${l10n?.name ?? 'Nome'} *',
                    hintText: l10n?.exampleName ?? 'Ex: Maria Silva',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.nameRequired ?? 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '${l10n?.phone ?? 'Telefone'} *',
                    hintText: l10n?.examplePhone ?? '+244 923 456 789',
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n?.phoneRequired ?? 'Telefone é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ContactRelation>(
                  value: _selectedRelation,
                  decoration: InputDecoration(
                    labelText: l10n?.relation ?? 'Relação',
                    prefixIcon: const Icon(Icons.people),
                    border: const OutlineInputBorder(),
                  ),
                  items: ContactRelation.values.map((relation) {
                    return DropdownMenuItem(
                      value: relation,
                      child: Text(getLocalizedRelationName(relation, l10n)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRelation = value;
                      });
                    }
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
                          'Contatos prioritários receberão alertas de emergência (máximo 5)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _isPriority,
                  onChanged: (value) {
                    setState(() {
                      _isPriority = value ?? false;
                    });
                  },
                  title: Text(l10n?.priorityContact ?? 'Marcar como prioritário'),
                  subtitle: Text(l10n?.willReceiveEmergencyAlerts ?? 'Receberá alertas de emergência automáticos'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n?.cancel ?? 'Cancelar'),
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
                      child: Text(isEditing ? (l10n?.save ?? 'Salvar') : (l10n?.add ?? 'Adicionar')),
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'relation': _selectedRelation,
        'isPriority': _isPriority,
        if (widget.contact != null) 'id': widget.contact!.id,
      };
      Navigator.of(context).pop(result);
    }
  }
}
