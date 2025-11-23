import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/models/risk_type.dart';
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/data/dtos/risk_type_response_dto.dart';
import 'package:rpa/data/dtos/risk_topic_response_dto.dart';
import 'package:rpa/core/services/risk_topic_translation_service.dart';
import 'package:rpa/core/services/risk_type_translation_service.dart';
import 'package:rpa/core/services/icon_resolver_service.dart';

// ============================================================================
// BACKEND INTEGRATION
// ============================================================================
// This bottom sheet now loads Risk Types and Topics from the backend API
// Previously used hardcoded data - now using real data from /risks/types and /risks/topics
// See: /docs/api/API_COMPLETE_GUIDE.md
// ============================================================================

/// Bottom sheet para seleção de tipo de relatório
/// Integrado com a API - busca tipos e tópicos do backend
class ReportSelectionBottomSheet extends ConsumerStatefulWidget {
  final Function(RiskTypeModel riskType, RiskTopicModel topic,
      {bool editLocation}) onReportSelected;

  const ReportSelectionBottomSheet({
    super.key,
    required this.onReportSelected,
  });

  @override
  ConsumerState<ReportSelectionBottomSheet> createState() =>
      _ReportSelectionBottomSheetState();
}

class _ReportSelectionBottomSheetState
    extends ConsumerState<ReportSelectionBottomSheet> {
  RiskTypeResponseDTO? _selectedRiskType;

  @override
  Widget build(BuildContext context) {
    // Load risk types from backend API
    final riskTypesAsync = ref.watch(riskTypesProvider);
    // Load all risk topics from backend API
    final riskTopicsAsync = ref.watch(riskTopicsProvider);
    
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // 85% da altura da tela

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: 300,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedRiskType != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _selectedRiskType = null;
                        });
                      },
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      _selectedRiskType == null
                          ? (AppLocalizations.of(context)?.whatDoYouSee ?? 'What do you see?')
                          : (AppLocalizations.of(context)?.selectSpecificType ?? 'Select specific type'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Conteúdo baseado nos dados da API
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    riskTypesAsync.when(
                      data: (riskTypes) {
                        return riskTopicsAsync.when(
                          data: (riskTopics) {
                            log('Loaded ${riskTypes.length} risk types and ${riskTopics.length} topics from backend',
                                name: 'ReportSelection');

                            if (_selectedRiskType == null) {
                              return _buildRiskTypesGrid(riskTypes);
                            } else {
                              // Filter topics for selected type
                              final filteredTopics = riskTopics
                                  .where((topic) =>
                                      topic.riskTypeId == _selectedRiskType!.id)
                                  .toList();
                              return _buildTopicsGrid(
                                  _selectedRiskType!, filteredTopics);
                            }
                          },
                          loading: () => Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)?.loading ?? 'Loading...'),
                              ],
                            ),
                          ),
                          error: (error, stack) =>
                              _buildErrorWidget(AppLocalizations.of(context)?.error ?? 'Error', error),
                        );
                      },
                      loading: () => Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(AppLocalizations.of(context)?.loading ?? 'Loading...'),
                          ],
                        ),
                      ),
                      error: (error, stack) =>
                          _buildErrorWidget(AppLocalizations.of(context)?.error ?? 'Error', error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build error widget
  Widget _buildErrorWidget(String title, Object error) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(riskTypesProvider);
              ref.invalidate(riskTopicsProvider);
            },
            child: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTypesGrid(List<RiskTypeResponseDTO> riskTypes) {
    log('Exibindo ${riskTypes.length} tipos de risco da API backend',
        name: 'ReportSelection');

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final crossAxisCount = isSmallScreen ? 2 : 3;
    final childAspectRatio = isSmallScreen ? 0.85 : 0.9;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: isSmallScreen ? 12 : 16,
          crossAxisSpacing: isSmallScreen ? 12 : 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: riskTypes.length,
        itemBuilder: (context, index) {
          final riskType = riskTypes[index];
          return _RiskTypeCardFromAPI(
            riskType: riskType,
            onTap: () {
              log('Selecionado tipo: ${riskType.name}',
                  name: 'ReportSelection');
              setState(() {
                _selectedRiskType = riskType;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicsGrid(
      RiskTypeResponseDTO riskType, List<RiskTopicResponseDTO> topics) {
    log('Exibindo ${topics.length} tópicos para ${riskType.name} da API backend',
        name: 'ReportSelection');

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final childAspectRatio = isSmallScreen ? 1.1 : 1.2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: isSmallScreen ? 10 : 12,
          crossAxisSpacing: isSmallScreen ? 10 : 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return _TopicCardFromAPI(
            topic: topic,
            color: _getColorForRiskType(riskType.name),
            onTap: () {
              log('Selecionado tópico: ${topic.name}', name: 'ReportSelection');
              _showReportOptions(riskType, topic);
            },
          );
        },
      ),
    );
  }

  // Helper to get color based on risk type name
  Color _getColorForRiskType(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('crime') || lowerName.contains('criminal')) {
      return const Color(0xFFE74C3C);
    } else if (lowerName.contains('acidente') ||
        lowerName.contains('accident')) {
      return const Color(0xFFE67E22);
    } else if (lowerName.contains('desastre') ||
        lowerName.contains('disaster')) {
      return const Color(0xFF9B59B6);
    } else if (lowerName.contains('incêndio') ||
        lowerName.contains('fogo') ||
        lowerName.contains('fire')) {
      return const Color(0xFFD35400);
    } else if (lowerName.contains('saúde') || lowerName.contains('health')) {
      return const Color(0xFF27AE60);
    } else if (lowerName.contains('infraestrutura') ||
        lowerName.contains('infrastructure')) {
      return const Color(0xFF95A5A6);
    } else if (lowerName.contains('ambiente') ||
        lowerName.contains('environment')) {
      return const Color(0xFF16A085);
    } else {
      return const Color(0xFF3498DB); // Default blue
    }
  }

  // Helper to get icon based on risk type name
  IconData _getIconForRiskType(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('crime') || lowerName.contains('criminal')) {
      return Icons.warning_amber_rounded;
    } else if (lowerName.contains('acidente') ||
        lowerName.contains('accident')) {
      return Icons.car_crash;
    } else if (lowerName.contains('desastre') ||
        lowerName.contains('disaster')) {
      return Icons.thunderstorm;
    } else if (lowerName.contains('incêndio') ||
        lowerName.contains('fogo') ||
        lowerName.contains('fire')) {
      return Icons.local_fire_department;
    } else if (lowerName.contains('saúde') || lowerName.contains('health')) {
      return Icons.medical_services;
    } else if (lowerName.contains('infraestrutura') ||
        lowerName.contains('infrastructure')) {
      return Icons.construction;
    } else if (lowerName.contains('ambiente') ||
        lowerName.contains('environment')) {
      return Icons.eco;
    } else {
      return Icons.report_problem; // Default icon
    }
  }

  void _showReportOptions(
      RiskTypeResponseDTO riskType, RiskTopicResponseDTO topic) {
    Navigator.pop(context);

    // Convert DTOs to Models for backward compatibility
    final riskTypeModel = RiskTypeModel(
      id: riskType.id,
      name: riskType.name,
      description: riskType.description,
      defaultRadius: riskType.defaultRadius,
      color: _getColorForRiskType(riskType.name),
      icon: _getIconForRiskType(riskType.name),
    );

    final topicModel = RiskTopicModel(
      id: topic.id,
      riskTypeId: topic.riskTypeId,
      name: topic.name,
      description: topic.description,
      icon: _getIconForTopic(topic.name),
    );

    // Mostrar opções: Reportar Agora ou Editar Localização
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      topicModel.icon,
                      size: 44,
                      color: riskTypeModel.color,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      topicModel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topicModel.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[200]),

              // Opções
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading:
                    const Icon(Icons.my_location, color: Color(0xFFF39C12), size: 28),
                title: Text(
                  AppLocalizations.of(context)?.reportAtMyLocation ?? 'Report at my location',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)?.useCurrentGpsLocation ?? 'Use current GPS location',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReportSelected(riskTypeModel, topicModel,
                      editLocation: false);
                },
              ),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading:
                    const Icon(Icons.edit_location, color: Color(0xFF3498DB), size: 28),
                title: Text(
                  AppLocalizations.of(context)?.chooseLocationOnMap ?? 'Choose location on map',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)?.adjustManuallyOnMap ?? 'Adjust manually on map',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReportSelected(riskTypeModel, topicModel,
                      editLocation: true);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get icon based on topic name
  IconData _getIconForTopic(String topicName) {
    final lowerName = topicName.toLowerCase();

    // Crime topics
    if (lowerName.contains('roubo') || lowerName.contains('robbery')) {
      return Icons.house_siding;
    } else if (lowerName.contains('assalto') || lowerName.contains('assault')) {
      return Icons.person_remove;
    } else if (lowerName.contains('furto') || lowerName.contains('theft')) {
      return Icons.phone_android;
    } else if (lowerName.contains('vandalismo') ||
        lowerName.contains('vandalism')) {
      return Icons.broken_image;
    }

    // Accident topics
    else if (lowerName.contains('trânsito') || lowerName.contains('traffic')) {
      return Icons.car_crash;
    } else if (lowerName.contains('trabalho') || lowerName.contains('work')) {
      return Icons.engineering;
    } else if (lowerName.contains('queda') || lowerName.contains('fall')) {
      return Icons.person_off;
    }

    // Natural disaster topics
    else if (lowerName.contains('enchente') ||
        lowerName.contains('flood') ||
        lowerName.contains('inundação')) {
      return Icons.water;
    } else if (lowerName.contains('deslizamento') ||
        lowerName.contains('landslide')) {
      return Icons.landslide;
    } else if (lowerName.contains('tempestade') ||
        lowerName.contains('storm')) {
      return Icons.thunderstorm;
    }

    // Fire topics
    else if (lowerName.contains('florestal') || lowerName.contains('forest')) {
      return Icons.forest;
    }

    // Health topics
    else if (lowerName.contains('infecciosa') ||
        lowerName.contains('infectious')) {
      return Icons.sick;
    } else if (lowerName.contains('emergência') ||
        lowerName.contains('emergency')) {
      return Icons.emergency;
    }

    // Infrastructure topics
    else if (lowerName.contains('ponte') || lowerName.contains('bridge')) {
      return Icons.warning;
    } else if (lowerName.contains('energia') || lowerName.contains('power')) {
      return Icons.power_off;
    }

    // Environment topics
    else if (lowerName.contains('poluição') ||
        lowerName.contains('pollution')) {
      return Icons.air;
    } else if (lowerName.contains('vazamento') ||
        lowerName.contains('leak') ||
        lowerName.contains('químico')) {
      return Icons.science;
    }

    // Default
    else {
      return Icons.info_outline;
    }
  }
}

// ============================================================================
// CARD WIDGETS FOR API DTOs
// ============================================================================

/// Card para Risk Type (usando DTO da API)
class _RiskTypeCardFromAPI extends StatelessWidget {
  final RiskTypeResponseDTO riskType;
  final VoidCallback onTap;

  const _RiskTypeCardFromAPI({
    required this.riskType,
    required this.onTap,
  });

  Color _getColor() {
    final lowerName = riskType.name.toLowerCase();
    if (lowerName.contains('crime') || lowerName.contains('criminal')) {
      return const Color(0xFFE74C3C);
    } else if (lowerName.contains('acidente') ||
        lowerName.contains('accident')) {
      return const Color(0xFFE67E22);
    } else if (lowerName.contains('desastre') ||
        lowerName.contains('disaster')) {
      return const Color(0xFF9B59B6);
    } else if (lowerName.contains('incêndio') ||
        lowerName.contains('fogo') ||
        lowerName.contains('fire')) {
      return const Color(0xFFD35400);
    } else if (lowerName.contains('saúde') || lowerName.contains('health')) {
      return const Color(0xFF27AE60);
    } else if (lowerName.contains('infraestrutura') ||
        lowerName.contains('infrastructure')) {
      return const Color(0xFF95A5A6);
    } else if (lowerName.contains('ambiente') ||
        lowerName.contains('environment')) {
      return const Color(0xFF16A085);
    } else {
      return const Color(0xFF3498DB);
    }
  }

  Widget _buildIcon() {
    return IconResolverService.buildIcon(
      typeName: riskType.name,
      apiIconPath: riskType.iconUrl,
      size: 40,
      color: _getColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: _buildIcon(),
              ),
              const SizedBox(height: 8),
              Text(
                RiskTypeTranslationService.translateType(context, riskType.name),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card para Topic (usando DTO da API)
class _TopicCardFromAPI extends StatelessWidget {
  final RiskTopicResponseDTO topic;
  final Color color;
  final VoidCallback onTap;

  const _TopicCardFromAPI({
    required this.topic,
    required this.color,
    required this.onTap,
  });

  Widget _buildIcon() {
    return IconResolverService.buildIcon(
      typeName: topic.name,
      apiIconPath: topic.iconUrl,
      size: 32,
      color: Colors.grey[700],
      isTopic: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: _buildIcon(),
              ),
              const SizedBox(height: 8),
              Text(
                RiskTopicTranslationService.translateTopic(
                  context,
                  topic.name,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
