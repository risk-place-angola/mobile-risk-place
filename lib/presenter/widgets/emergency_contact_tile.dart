import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';

class EmergencyContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback onSMS;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmergencyContactTile({
    super.key,
    required this.contact,
    required this.onCall,
    required this.onSMS,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12,
        ),
        leading: CircleAvatar(
          radius: isSmallScreen ? 18 : 20,
          backgroundColor:
              contact.isPriority ? Colors.red.shade100 : Colors.grey.shade200,
          child: Icon(
            _getRelationIcon(),
            size: isSmallScreen ? 18 : 20,
            color:
                contact.isPriority ? Colors.red.shade700 : Colors.grey.shade700,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (contact.isPriority) ...[
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  AppLocalizations.of(context)?.priority ?? 'Prioritário',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 9 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contact.phone,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              getLocalizedRelationName(
                contact.relation, 
                AppLocalizations.of(context)
              ),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'call':
                onCall();
                break;
              case 'sms':
                onSMS();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) {
            final l10n = AppLocalizations.of(context);
            return [
              PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n?.call ?? 'Ligar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sms',
                child: Row(
                  children: [
                    const Icon(Icons.message, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n?.sendSMS ?? 'Enviar SMS'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n?.edit ?? 'Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.remove ?? 'Remover',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  IconData _getRelationIcon() {
    switch (contact.relation) {
      case ContactRelation.family:
        return Icons.family_restroom;
      case ContactRelation.friend:
        return Icons.person;
      case ContactRelation.colleague:
        return Icons.work;
      case ContactRelation.neighbor:
        return Icons.home;
      case ContactRelation.other:
        return Icons.contact_phone;
    }
  }
}
