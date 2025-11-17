import 'package:flutter/material.dart';

/// Tipos de risco conforme backend Risk Place Angola
class RiskTypeModel {
  final String id;
  final String name;
  final String description;
  final int defaultRadius; // raio padrão em metros
  final Color color;
  final IconData icon;

  const RiskTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultRadius,
    required this.color,
    required this.icon,
  });
}

/// Risk Topics (subtópicos de cada tipo de risco)
class RiskTopicModel {
  final String id;
  final String riskTypeId;
  final String name;
  final String description;
  final IconData icon;

  const RiskTopicModel({
    required this.id,
    required this.riskTypeId,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Tipos de risco disponíveis
class RiskTypes {
  // Crime - 1000m raio
  static const crime = RiskTypeModel(
    id: 'crime',
    name: 'Crime',
    description: 'Ocorrências criminais em geral',
    defaultRadius: 1000,
    color: Color(0xFFE74C3C),
    icon: Icons.warning_amber_rounded,
  );

  // Acidentes - 500m raio
  static const accident = RiskTypeModel(
    id: 'accident',
    name: 'Acidente',
    description: 'Acidentes de trânsito ou trabalho',
    defaultRadius: 500,
    color: Color(0xFFE67E22),
    icon: Icons.car_crash,
  );

  // Desastres Naturais - 2000m raio
  static const naturalDisaster = RiskTypeModel(
    id: 'natural_disaster',
    name: 'Desastre Natural',
    description: 'Desastres naturais como enchentes, deslizamentos, tempestades',
    defaultRadius: 2000,
    color: Color(0xFF9B59B6),
    icon: Icons.thunderstorm,
  );

  // Incêndios - 1500m raio
  static const fire = RiskTypeModel(
    id: 'fire',
    name: 'Incêndio',
    description: 'Incêndios residenciais, comerciais ou florestais',
    defaultRadius: 1500,
    color: Color(0xFFD35400),
    icon: Icons.local_fire_department,
  );

  // Saúde - 1000m raio
  static const health = RiskTypeModel(
    id: 'health',
    name: 'Saúde',
    description: 'Emergências médicas ou surtos de doenças',
    defaultRadius: 1000,
    color: Color(0xFF27AE60),
    icon: Icons.medical_services,
  );

  // Infraestrutura - 1000m raio
  static const infrastructure = RiskTypeModel(
    id: 'infrastructure',
    name: 'Infraestrutura',
    description: 'Falhas ou problemas em infraestrutura pública',
    defaultRadius: 1000,
    color: Color(0xFF95A5A6),
    icon: Icons.construction,
  );

  // Meio Ambiente - 1000m raio
  static const environment = RiskTypeModel(
    id: 'environment',
    name: 'Meio Ambiente',
    description: 'Riscos ambientais, poluição ou vazamento químico',
    defaultRadius: 1000,
    color: Color(0xFF16A085),
    icon: Icons.eco,
  );

  static const List<RiskTypeModel> all = [
    crime,
    accident,
    naturalDisaster,
    fire,
    health,
    infrastructure,
    environment,
  ];
}

/// Topics de Crime
class CrimeTopics {
  static const roubo = RiskTopicModel(
    id: 'roubo',
    riskTypeId: 'crime',
    name: 'Roubo',
    description: 'Roubo em residências, comércio ou público',
    icon: Icons.house_siding,
  );

  static const assalto = RiskTopicModel(
    id: 'assalto',
    riskTypeId: 'crime',
    name: 'Assalto',
    description: 'Assalto com violência, sequestro ou agressão',
    icon: Icons.person_remove,
  );

  static const furtos = RiskTopicModel(
    id: 'furtos',
    riskTypeId: 'crime',
    name: 'Furtos',
    description: 'Furtos sem violência, como bolsas ou celulares',
    icon: Icons.phone_android,
  );

  static const vandalismo = RiskTopicModel(
    id: 'vandalismo',
    riskTypeId: 'crime',
    name: 'Vandalismo',
    description: 'Destruição de propriedade pública ou privada',
    icon: Icons.broken_image,
  );

  static const List<RiskTopicModel> all = [roubo, assalto, furtos, vandalismo];
}

/// Topics de Acidentes
class AccidentTopics {
  static const acidenteTransito = RiskTopicModel(
    id: 'acidente_transito',
    riskTypeId: 'accident',
    name: 'Acidente de Trânsito',
    description: 'Acidente de trânsito envolvendo veículos ou pedestres',
    icon: Icons.car_crash,
  );

  static const acidenteTrabalho = RiskTopicModel(
    id: 'acidente_trabalho',
    riskTypeId: 'accident',
    name: 'Acidente de Trabalho',
    description: 'Acidente em ambiente de trabalho ou obra',
    icon: Icons.engineering,
  );

  static const queda = RiskTopicModel(
    id: 'queda',
    riskTypeId: 'accident',
    name: 'Queda',
    description: 'Quedas de pessoas em locais públicos ou privados',
    icon: Icons.person_off,
  );

  static const List<RiskTopicModel> all = [acidenteTransito, acidenteTrabalho, queda];
}

/// Topics de Desastres Naturais
class NaturalDisasterTopics {
  static const enchente = RiskTopicModel(
    id: 'enchente',
    riskTypeId: 'natural_disaster',
    name: 'Enchente',
    description: 'Inundações e enchentes urbanas ou rurais',
    icon: Icons.water,
  );

  static const deslizamento = RiskTopicModel(
    id: 'deslizamento',
    riskTypeId: 'natural_disaster',
    name: 'Deslizamento',
    description: 'Deslizamentos de terra ou barrancos',
    icon: Icons.landslide,
  );

  static const tempestade = RiskTopicModel(
    id: 'tempestade',
    riskTypeId: 'natural_disaster',
    name: 'Tempestade',
    description: 'Tempestades fortes, ventos e raios',
    icon: Icons.thunderstorm,
  );

  static const List<RiskTopicModel> all = [enchente, deslizamento, tempestade];
}

/// Topics de Incêndio
class FireTopics {
  static const incendioFlorestal = RiskTopicModel(
    id: 'incendio_florestal',
    riskTypeId: 'fire',
    name: 'Incêndio Florestal',
    description: 'Incêndios em áreas florestais ou savanas',
    icon: Icons.forest,
  );

  static const List<RiskTopicModel> all = [incendioFlorestal];
}

/// Topics de Saúde
class HealthTopics {
  static const doencaInfecciosa = RiskTopicModel(
    id: 'doenca_infecciosa',
    riskTypeId: 'health',
    name: 'Doença Infecciosa',
    description: 'Surtos de doenças transmissíveis',
    icon: Icons.sick,
  );

  static const emergenciaMedica = RiskTopicModel(
    id: 'emergencia_medica',
    riskTypeId: 'health',
    name: 'Emergência Médica',
    description: 'Situações médicas graves como parada cardíaca',
    icon: Icons.emergency,
  );

  static const List<RiskTopicModel> all = [doencaInfecciosa, emergenciaMedica];
}

/// Topics de Infraestrutura
class InfrastructureTopics {
  static const quedaPonte = RiskTopicModel(
    id: 'queda_ponte',
    riskTypeId: 'infrastructure',
    name: 'Problema em Ponte',
    description: 'Desabamento ou problemas em pontes e viadutos',
    icon: Icons.warning,
  );

  static const quedaEnergia = RiskTopicModel(
    id: 'queda_energia',
    riskTypeId: 'infrastructure',
    name: 'Queda de Energia',
    description: 'Falhas ou interrupção de fornecimento elétrico',
    icon: Icons.power_off,
  );

  static const List<RiskTopicModel> all = [quedaPonte, quedaEnergia];
}

/// Topics de Meio Ambiente
class EnvironmentTopics {
  static const poluicao = RiskTopicModel(
    id: 'poluicao',
    riskTypeId: 'environment',
    name: 'Poluição',
    description: 'Poluição do ar, água ou solo',
    icon: Icons.air,
  );

  static const vazamentoQuimico = RiskTopicModel(
    id: 'vazamento_quimico',
    riskTypeId: 'environment',
    name: 'Vazamento Químico',
    description: 'Vazamento de produtos químicos ou tóxicos',
    icon: Icons.science,
  );

  static const List<RiskTopicModel> all = [poluicao, vazamentoQuimico];
}

/// Helper para obter todos os topics de um risk type
class RiskTopicHelper {
  static List<RiskTopicModel> getTopicsForType(String riskTypeId) {
    switch (riskTypeId) {
      case 'crime':
        return CrimeTopics.all;
      case 'accident':
        return AccidentTopics.all;
      case 'natural_disaster':
        return NaturalDisasterTopics.all;
      case 'fire':
        return FireTopics.all;
      case 'health':
        return HealthTopics.all;
      case 'infrastructure':
        return InfrastructureTopics.all;
      case 'environment':
        return EnvironmentTopics.all;
      default:
        return [];
    }
  }

  static List<RiskTopicModel> getAllTopics() {
    return [
      ...CrimeTopics.all,
      ...AccidentTopics.all,
      ...NaturalDisasterTopics.all,
      ...FireTopics.all,
      ...HealthTopics.all,
      ...InfrastructureTopics.all,
      ...EnvironmentTopics.all,
    ];
  }
}
