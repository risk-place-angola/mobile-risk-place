import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';

class RiskTopicTranslationService {
  static String translateTopic(BuildContext context, String topicKey) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return topicKey;

    final normalized = topicKey.toLowerCase().replaceAll(' ', '_');

    try {
      switch (normalized) {
        case 'assalto_mao_armada':
          return l10n.assalto_mao_armada;
        case 'roubo_residencia':
          return l10n.roubo_residencia;
        case 'roubo_veiculo':
          return l10n.roubo_veiculo;
        case 'furto_carteira':
          return l10n.furto_carteira;
        case 'furto_telemovel':
          return l10n.furto_telemovel;
        case 'vandalismo':
          return l10n.vandalismo;
        case 'sequestro':
          return l10n.sequestro;
        case 'violencia_domestica':
          return l10n.violencia_domestica;
        case 'agressao_fisica':
          return l10n.agressao_fisica;
        case 'tiroteio':
          return l10n.tiroteio;
        case 'acidente_viacao':
          return l10n.acidente_viacao;
        case 'colisao_transito':
          return l10n.colisao_transito;
        case 'atropelamento':
          return l10n.atropelamento;
        case 'capotamento':
          return l10n.capotamento;
        case 'inundacao':
          return l10n.inundacao;
        case 'deslizamento_terra':
          return l10n.deslizamento_terra;
        case 'tempestade':
          return l10n.tempestade;
        case 'raio':
          return l10n.raio;
        case 'incendio_residencial':
          return l10n.incendio_residencial;
        case 'incendio_comercial':
          return l10n.incendio_comercial;
        case 'incendio_mercado':
          return l10n.incendio_mercado;
        case 'incendio_veiculo':
          return l10n.incendio_veiculo;
        case 'emergencia_medica':
          return l10n.emergencia_medica;
        case 'surto_doenca':
          return l10n.surto_doenca;
        case 'acidente_trabalho':
          return l10n.acidente_trabalho;
        case 'queda_energia':
          return l10n.queda_energia;
        case 'queda_agua':
          return l10n.queda_agua;
        case 'buraco_via':
          return l10n.buraco_via;
        case 'semaforo_avariado':
          return l10n.semaforo_avariado;
        case 'cabo_solto':
          return l10n.cabo_solto;
        case 'estrutura_risco':
          return l10n.estrutura_risco;
        case 'lixo_acumulado':
          return l10n.lixo_acumulado;
        case 'esgoto_aberto':
          return l10n.esgoto_aberto;
        case 'poluicao_ar':
          return l10n.poluicao_ar;
        case 'vazamento_agua':
          return l10n.vazamento_agua;
        case 'rua_escura':
          return l10n.rua_escura;
        case 'zona_assalto':
          return l10n.zona_assalto;
        case 'vigilancia_necessaria':
          return l10n.vigilancia_necessaria;
        case 'operacao_policial':
          return l10n.operacao_policial;
        case 'congestionamento':
          return l10n.congestionamento;
        case 'via_bloqueada':
          return l10n.via_bloqueada;
        case 'manifestacao':
          return l10n.manifestacao;
        case 'animal_solto':
          return l10n.animal_solto;
        case 'obra_sinalizacao':
          return l10n.obra_sinalizacao;
        case 'assalto':
          return l10n.assalto;
        case 'furtos':
          return l10n.furtos;
        case 'roubo':
          return l10n.roubo;
        case 'queda':
          return l10n.queda;
        case 'enchente':
          return l10n.enchente;
        case 'deslizamento':
          return l10n.deslizamento;
        case 'incendio_florestal':
          return l10n.incendio_florestal;
        case 'doenca_infecciosa':
          return l10n.doenca_infecciosa;
        case 'queda_ponte':
          return l10n.queda_ponte;
        case 'poluicao':
          return l10n.poluicao;
        case 'vazamento_quimico':
          return l10n.vazamento_quimico;
        case 'acidente_transito':
          return l10n.acidente_transito;
        default:
          return topicKey;
      }
    } catch (e) {
      return topicKey;
    }
  }

  static String translateRiskType(BuildContext context, String riskTypeName) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return riskTypeName;

    final normalized = riskTypeName.toLowerCase().replaceAll(' ', '_');
    final typeMap = {
      'crime': l10n.crime,
      'criminalidade': l10n.crime,
      'accident': l10n.accident,
      'acidente': l10n.accident,
      'natural_disaster': l10n.naturalDisaster,
      'desastre_natural': l10n.naturalDisaster,
      'fire': l10n.fire,
      'incendio': l10n.fire,
      'health': l10n.health,
      'saude': l10n.health,
      'infrastructure': l10n.infrastructure,
      'infraestrutura': l10n.infrastructure,
      'environment': l10n.environment,
      'meio_ambiente': l10n.environment,
      'violence': l10n.violence,
      'violencia': l10n.violence,
      'public_safety': l10n.publicSafety,
      'seguranca_publica': l10n.publicSafety,
      'traffic': l10n.traffic,
      'transito': l10n.traffic,
      'urban_issue': l10n.urbanIssue,
      'problema_urbano': l10n.urbanIssue,
    };

    return typeMap[normalized] ?? riskTypeName;
  }
}
