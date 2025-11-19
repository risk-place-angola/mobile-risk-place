class EmergencyContact {
  final String name;
  final String number;
  final String description;
  final EmergencyType type;

  const EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.type,
  });
}

enum EmergencyType {
  general,
  police,
  fire,
  medical,
  other,
}

class EmergencyContactsData {
  static const List<EmergencyContact> angolaContacts = [
    EmergencyContact(
      name: 'Emergência Geral',
      number: '112',
      description: 'Linha de emergência nacional',
      type: EmergencyType.general,
    ),
    EmergencyContact(
      name: 'Polícia Nacional',
      number: '113',
      description: 'Polícia Nacional de Angola',
      type: EmergencyType.police,
    ),
    EmergencyContact(
      name: 'Bombeiros',
      number: '115',
      description: 'Corpo de Bombeiros',
      type: EmergencyType.fire,
    ),
    EmergencyContact(
      name: 'Ambulância',
      number: '116',
      description: 'Serviço de ambulância',
      type: EmergencyType.medical,
    ),
  ];

  static String getEmergencyTypeIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.general:
        return '🆘';
      case EmergencyType.police:
        return '👮';
      case EmergencyType.fire:
        return '🚒';
      case EmergencyType.medical:
        return '🚑';
      case EmergencyType.other:
        return '📞';
    }
  }
}
