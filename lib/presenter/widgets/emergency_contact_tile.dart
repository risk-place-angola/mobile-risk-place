import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              contact.isPriority ? Colors.red.shade100 : Colors.grey.shade200,
          child: Icon(
            _getRelationIcon(),
            color:
                contact.isPriority ? Colors.red.shade700 : Colors.grey.shade700,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (contact.isPriority)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Prioritário',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
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
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contact.relation.displayName,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
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
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, size: 20),
                  SizedBox(width: 12),
                  Text('Ligar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sms',
              child: Row(
                children: [
                  Icon(Icons.message, size: 20),
                  SizedBox(width: 12),
                  Text('Enviar SMS'),
                ],
              ),
            ),
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
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Remover', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
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
