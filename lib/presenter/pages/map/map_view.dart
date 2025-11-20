import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';
import 'package:rpa/data/models/websocket/nearby_user_model.dart';
import 'package:rpa/data/providers/risk_providers.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
import 'package:rpa/presenter/controllers/menu.controller.dart' as menu_ctrl;
import 'package:rpa/presenter/pages/map/providers/map_markers_notifier.dart';
import 'package:rpa/presenter/pages/map/providers/user_avatars_notifier.dart';
import 'package:rpa/presenter/pages/map/widgets/marker_details_sheet.dart';
import 'package:rpa/presenter/pages/map/widgets/report_button.dart';
import 'package:rpa/presenter/pages/map/widgets/location_button.dart';
import 'package:rpa/presenter/pages/map/widgets/user_avatar_marker.dart';
import 'package:rpa/presenter/pages/map/widgets/report_selection_bottom_sheet_v2.dart';
import 'package:rpa/presenter/pages/map/widgets/report_location_editor.dart';
import 'package:rpa/presenter/widgets/radius_control_widget.dart';
import 'package:rpa/data/models/risk_type.dart';
import 'package:rpa/data/models/enums/risk_type.dart' as enums;
import 'package:rpa/presenter/pages/home_page/widgets/home_panel.widget.dart';
import 'package:rpa/presenter/providers/nearby_reports_notifier.dart';
import 'package:rpa/presenter/pages/home_page/widgets/floating_profile_button.widget.dart';
import 'package:rpa/presenter/pages/menu/widgets/hamburger_button.widget.dart';
import 'package:rpa/presenter/pages/menu/slide_out_menu.dart';
import 'package:rpa/presenter/pages/profile/profile.view.dart';
import 'package:rpa/data/models/place_search_result.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/domain/usecases/create_report_usecase.dart';
import 'package:rpa/domain/usecases/update_report_location_usecase.dart';
import 'package:rpa/core/services/risk_topic_translation_service.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController controller = MapController();
  PlaceSearchResult? _selectedSearchResult;
  int _currentRadius = 5000; // Default 5km radius for nearby reports
  bool _isLoadingReports = false; // Prevent duplicate loads

  @override
  void initState() {
    super.initState();
    
    _setupWebSocketForAvatars();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    ref.read(allRiskTypesProvider);
    
    final locationController = ref.read(locationControllerProvider);
    if (locationController.permissionGranted) {
      locationController.startLocationUpdates();
    }

    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      _loadNearbyReportsFromBackend();
    }
  }

  void _setupWebSocketForAvatars() {
    final wsService = ref.read(alertWebSocketProvider);
    
    wsService.onNearbyUsersReceived = (users) {
      if (mounted) {
        ref.read(userAvatarsProvider.notifier).updateNearbyUsers(users);
      }
    };
  }

  // ============================================================================
  // BACKEND INTEGRATION - Load reports from API
  // ============================================================================

  /// Load nearby reports from backend API
  Future<void> _loadNearbyReportsFromBackend() async {
    // Prevent duplicate loads
    if (_isLoadingReports) {
      log('Already loading reports, skipping...', name: 'MapView');
      return;
    }

    try {
      final locationController = ref.read(locationControllerProvider);
      final currentPosition = locationController.currentPosition;

      if (currentPosition == null) {
        log('No current location available, skipping reports load',
            name: 'MapView');
        return;
      }

      _isLoadingReports = true;
      log('Loading nearby reports from backend...', name: 'MapView');

      await ref.read(nearbyReportsNotifierProvider.notifier).loadReports(
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude,
            radius: _currentRadius, // Use current radius setting
          );

      final reports = ref.read(nearbyReportsListProvider);

      log('Loaded ${reports.length} reports from backend', name: 'MapView');

      // Add reports to map markers with dynamic risk type lookup
      final mapMarkersNotifier = ref.read(mapMarkersProvider.notifier);
      for (final reportDTO in reports) {
        // Fetch risk type name from backend and map to enum
        enums.RiskType riskType = enums.RiskType.infrastructure; // Default fallback
        
        try {
          final riskTypeAsync = ref.read(riskTypeProvider(reportDTO.riskTypeId));
          await riskTypeAsync.when(
            data: (riskTypeDTO) {
              // Map backend risk type name to enum
              riskType = _mapRiskTypeNameToEnum(riskTypeDTO.name);
              log('Mapped risk type "${riskTypeDTO.name}" to ${riskType.name}', name: 'MapView');
            },
            loading: () {
              log('Loading risk type for ${reportDTO.riskTypeId}', name: 'MapView');
            },
            error: (err, _) {
              log('Error loading risk type ${reportDTO.riskTypeId}: $err', name: 'MapView');
            },
          );
        } catch (e) {
          log('Exception getting risk type for report ${reportDTO.id}: $e', name: 'MapView');
        }

        // Convert DTO to ReportModel for the map
        final reportModel = ReportModel(
          reportId: reportDTO.id,
          message: reportDTO.description,
          latitude: reportDTO.latitude,
          longitude: reportDTO.longitude,
          riskType: riskType,
          status: _mapReportStatusFromString(reportDTO.status),
          createdAt: reportDTO.createdAt,
        );

        mapMarkersNotifier.addReport(reportModel);
      }

      log('Added ${reports.length} reports to map', name: 'MapView');
    } catch (e) {
      log('Error loading nearby reports: $e', name: 'MapView');
    } finally {
      _isLoadingReports = false;
    }
  }

  /// Map report status string from backend to ReportStatus enum
  ReportStatus _mapReportStatusFromString(String? statusStr) {
    if (statusStr == null) return ReportStatus.pending;

    switch (statusStr.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'verified':
        return ReportStatus.verified;
      case 'resolved':
        return ReportStatus.resolved;
      default:
        return ReportStatus.pending;
    }
  }

  /// Map risk type name from backend to RiskType enum
  /// Uses intelligent fuzzy matching to handle name variations
  enums.RiskType _mapRiskTypeNameToEnum(String riskTypeName) {
    final normalized = riskTypeName.toLowerCase().trim();

    // Direct matches
    if (normalized.contains('violence') || normalized.contains('violência')) {
      return enums.RiskType.violence;
    }
    if (normalized.contains('fire') || normalized.contains('fogo') || normalized.contains('incêndio')) {
      return enums.RiskType.fire;
    }
    if (normalized.contains('traffic') || normalized.contains('trânsito') || normalized.contains('transito')) {
      return enums.RiskType.traffic;
    }
    if (normalized.contains('infrastructure') || normalized.contains('infraestrutura')) {
      return enums.RiskType.infrastructure;
    }
    if (normalized.contains('flood') || normalized.contains('inundação') || normalized.contains('cheia') || normalized.contains('natural') || normalized.contains('disaster') || normalized.contains('desastre')) {
      return enums.RiskType.naturalDisaster;
    }
    if (normalized.contains('crime') || normalized.contains('criminal')) {
      return enums.RiskType.crime;
    }
    if (normalized.contains('accident') || normalized.contains('acidente')) {
      return enums.RiskType.accident;
    }
    if (normalized.contains('health') || normalized.contains('saúde') || normalized.contains('medical') || normalized.contains('médic')) {
      return enums.RiskType.health;
    }
    if (normalized.contains('environment') || normalized.contains('ambiente') || normalized.contains('ambiental')) {
      return enums.RiskType.environment;
    }
    if (normalized.contains('public') || normalized.contains('safety') || normalized.contains('segurança') || normalized.contains('pública')) {
      return enums.RiskType.publicSafety;
    }
    if (normalized.contains('urban') || normalized.contains('urbano')) {
      return enums.RiskType.urbanIssue;
    }

    return enums.RiskType.infrastructure;
  }

  // MOCK used for testing - DISABLED - Using real backend data now
  // /// Load mock data for testing markers (TEMPORARY - will be replaced by WebSocket)
  // void _loadMockData() {
  //   final notifier = ref.read(mapMarkersProvider.notifier);
  //   MockMapData.loadMockData(
  //     notifier.addAlert,
  //     notifier.addReport,
  //   );
  //   log('Loaded mock alerts and reports (TEMPORARY)', name: 'MapView');

  //   // Load mock recent items for home panel
  //   _loadMockRecentItems();
  // }

  // MOCK used for testing - DISABLED
  // /// Load mock recent items for demonstration (TEMPORARY)
  // void _loadMockRecentItems() {
  //   final panelController = ref.read(homePanelControllerProvider);

  //   // Set home and work addresses
  //   panelController.setHomeAddress('Home');
  //   panelController.setWorkAddress('Work');

  //   // Add mock recent items
  //   panelController.addRecentItem(RecentItem(
  //     id: '1',
  //     title: 'Talatona',
  //     subtitle: 'Luanda, Angola',
  //     icon: Icons.location_city,
  //     timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  //     type: RecentItemType.neighborhood,
  //   ));

  //   panelController.addRecentItem(RecentItem(
  //     id: '2',
  //     title: 'Armed Robbery',
  //     subtitle: 'Reported 3 hours ago near Kilamba',
  //     icon: Icons.warning_amber_rounded,
  //     timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  //     type: RecentItemType.incident,
  //   ));

  //   panelController.addRecentItem(RecentItem(
  //     id: '3',
  //     title: 'Safe Route to Miramar',
  //     subtitle: 'Via Avenida 4 de Fevereiro',
  //     icon: Icons.route,
  //     timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     type: RecentItemType.safeRoute,
  //   ));

  //   panelController.addRecentItem(RecentItem(
  //     id: '4',
  //     title: 'Shopping Belas',
  //     subtitle: 'Belas, Luanda',
  //     icon: Icons.shopping_bag,
  //     timestamp: DateTime.now().subtract(const Duration(days: 1)),
  //     type: RecentItemType.location,
  //   ));

  //   log('Loaded mock recent items', name: 'MapView');
  // }

  /// Adjust map zoom based on radius
  /// Animates the map to show the search radius area properly
  void _adjustMapZoomForRadius(int radius) {
    final locationController = ref.read(locationControllerProvider);
    final currentPosition = locationController.currentPosition;
    
    if (currentPosition == null) return;

    // Calculate appropriate zoom level based on radius
    // Formula: zoom = log2(earthCircumference / (radius * tileSize * 2))
    // Simplified mapping for common radius values:
    double zoomLevel;
    if (radius <= 500) {
      zoomLevel = 16.0; // Very close view
    } else if (radius <= 1000) {
      zoomLevel = 15.0; // Close view
    } else if (radius <= 2000) {
      zoomLevel = 14.0; // Medium-close view
    } else if (radius <= 5000) {
      zoomLevel = 13.0; // Medium view
    } else if (radius <= 10000) {
      zoomLevel = 12.0; // Far view
    } else {
      zoomLevel = 11.0; // Very far view
    }

    // Animate to new zoom level centered on current position
    controller.move(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      zoomLevel,
    );

    log('Adjusted map zoom to $zoomLevel for radius ${radius}m', name: 'MapView');
  }

  @override
  void dispose() {
    // Stop location updates when leaving the map
    ref.read(locationControllerProvider).stopLocationUpdates();
    super.dispose();
  }

  /// Show details sheet when marker is tapped
  void _showMarkerDetails(BuildContext context, dynamic markerData) {
    // Hide the home panel when showing marker details
    ref.read(homePanelControllerProvider).hidePanel();

    if (markerData is AlertModel) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AlertDetailsSheet(alert: markerData),
      ).then((_) {
        // Show panel again when details sheet is closed
        ref.read(homePanelControllerProvider).showPanel();
      });
    } else if (markerData is ReportModel) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ReportDetailsSheet(
          report: markerData,
          onEditLocation: (report) => _handleEditReportLocation(report),
        ),
      ).then((_) {
        // Show panel again when details sheet is closed
        ref.read(homePanelControllerProvider).showPanel();
      });
    }
  }

  void _handleSearchTap() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search feature temporarily disabled'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // COMMENTED OUT - Related to disabled search functionality
  /* 
  void _handlePlaceSelected(PlaceSearchResult place) {
    // Validate coordinates
    if (place.location.latitude.abs() > 90 || place.location.longitude.abs() > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid location coordinates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Store selected search result for displaying marker
    setState(() {
      _selectedSearchResult = place;
    });

    // Move map to selected location after a small delay to ensure map is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.move(place.location, 16.0);
      }
    });

    // Show bottom sheet with options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Location info section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // Location icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFE53935),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Location text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.shortAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(height: 1, color: Colors.grey[200]),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.close, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showReportOptionsForLocation(place);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF39C12),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.report_problem, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Report Risk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Clear search marker when bottom sheet is closed
      if (mounted) {
        setState(() {
          _selectedSearchResult = null;
        });
      }
    });
  }
  */

  // COMMENTED OUT - Related to disabled search functionality
  /*
  void _showReportOptionsForLocation(PlaceSearchResult place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportSelectionBottomSheet(
        onReportSelected: (reportType, {bool editLocation = false}) {
          _handleReportAtLocation(reportType, place, editLocation: editLocation);
        },
      ),
    );
  }
  */

  // COMMENTED OUT - Related to disabled search functionality
  /*
  Future<void> _handleReportAtLocation(
    ReportTypeModel reportType,
    PlaceSearchResult place, {
    bool editLocation = false,
  }) async {
    LatLng reportLocation = place.location;

    // If user wants to edit location, show the location editor
    if (editLocation) {
      final selectedLocation = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (context) => ReportLocationEditor(
            initialLocation: reportLocation,
            reportTypeLabel: reportType.label,
          ),
        ),
      );

      // If user cancelled, return
      if (selectedLocation == null) {
        return;
      }

      reportLocation = selectedLocation;
    }

    try {
      // Submit the report
      final reportController = ref.read(reportControllerProvider);
      await reportController.submitReport(
        reportType: reportType,
        latitude: reportLocation.latitude,
        longitude: reportLocation.longitude,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report "${reportType.label}" submitted at ${place.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  */

  void _handleVoiceSearchTap() {
    print('Voice search tapped');
  }

  void _handleProfileTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }

  void _handleMenuToggle() {
    ref.read(menu_ctrl.menuControllerProvider).toggleMenu();
  }

  Future<void> _handleEditReportLocation(ReportModel report) async {
    // Open location editor with current report location
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportLocationEditor(
          initialLocation: LatLng(report.latitude, report.longitude),
          reportTypeLabel: 'Edit ${report.message}',
        ),
      ),
    );

    if (selectedLocation == null) {
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Atualizando localização...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final updateUseCase = ref.read(updateReportLocationUseCaseProvider);

      final result = await updateUseCase(
        UpdateReportLocationParams(
          reportId: report.reportId,
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result is UpdateReportLocationSuccess) {
        final updatedReport = report.copyWith(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
        );

        ref.read(mapMarkersProvider.notifier).removeReport(report.reportId);
        ref.read(mapMarkersProvider.notifier).addReport(updatedReport);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Localização atualizada com sucesso'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (result is UpdateReportLocationFailure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  void _handleLocationButtonTap() {
    final currentPosition =
        ref.read(locationControllerProvider).currentPosition;

    if (currentPosition != null) {
      _adjustMapZoomForRadius(_currentRadius);
    } else {
      _showErrorSnackBar('Localização não disponível. Por favor, ative o GPS.');
    }
  }

  void _handleReportButtonTap() {
    // 🌟 WAZE-STYLE: Allow anonymous users to create reports
    // No authentication required - anonymous users can report using device_id
    _proceedWithReport();
  }

  List<Marker> _buildUserAvatarMarkers(List<NearbyUserModel> users) {
    return users.map((user) => Marker(
      width: 48.0,
      height: 48.0,
      point: LatLng(user.latitude, user.longitude),
      child: AnimatedUserAvatarMarker(
        avatarId: user.avatarId,
        color: user.color,
        size: 48,
        isMoving: user.speed != null && user.speed! > 0.5,
      ),
    )).toList();
  }

  void _proceedWithReport() {
    ref.read(homePanelControllerProvider).hidePanel();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportSelectionBottomSheet(
        onReportSelected: (riskType, topic, {bool editLocation = false}) {
          _handleReportSelected(riskType, topic, editLocation: editLocation);
        },
      ),
    ).then((_) {
      ref.read(homePanelControllerProvider).showPanel();
    });
  }

  Future<void> _handleReportSelected(
    RiskTypeModel riskType,
    RiskTopicModel topic, {
    bool editLocation = false,
  }) async {
    final currentPosition =
        ref.read(locationControllerProvider).currentPosition;

    if (currentPosition == null) {
      _showErrorSnackBar('Localização não disponível. Por favor, ative o GPS.');
      return;
    }

    LatLng reportLocation = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // Se usuário quiser editar localização, mostrar editor
    if (editLocation) {
      final selectedLocation = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (context) => ReportLocationEditor(
            initialLocation: reportLocation,
            reportTypeLabel: RiskTopicTranslationService.translateTopic(
              context,
              topic.name,
            ),
          ),
        ),
      );

      // Se usuário cancelou, retornar
      if (selectedLocation == null) {
        return;
      }

      reportLocation = selectedLocation;
    }

    // ============================================================================
    // BACKEND INTEGRATION - Create Report
    // ============================================================================
    _showLoadingDialog('Enviando relatório...');

    try {
      final createReportUseCase =
          await ref.read(createReportUseCaseProvider.future);

      final translatedTopicName = RiskTopicTranslationService.translateTopic(
        context,
        topic.name,
      );
      
      final params = CreateReportParams(
        riskTypeId: riskType.id,
        riskTopicId: topic.id,
        description: '$translatedTopicName: ${topic.description}',
        latitude: reportLocation.latitude,
        longitude: reportLocation.longitude,
        address: '',
        municipality: '',
        neighborhood: '',
        province: '',
      );

      // Execute use case
      final result = await createReportUseCase.execute(params);

      // Hide loading dialog
      if (mounted) Navigator.of(context).pop();

      // Handle result using pattern matching
      if (result is CreateReportSuccess) {
        log('Report created successfully: ${result.report.id}',
            name: 'MapView');

        // Add to local map for immediate feedback
        final report = ReportModel(
          reportId: result.report.id,
          message: '$translatedTopicName: ${topic.description}',
          latitude: reportLocation.latitude,
          longitude: reportLocation.longitude,
          riskType: enums.RiskType.values.firstWhere(
            (rt) => rt.name.toLowerCase() == riskType.name.toLowerCase(),
            orElse: () => enums.RiskType.infrastructure,
          ),
          status: ReportStatus.pending,
          createdAt: DateTime.now(),
        );

        ref.read(mapMarkersProvider.notifier).addReport(report);

        _showSuccessSnackBar('$translatedTopicName reportado com sucesso!');
      } else if (result is CreateReportFailure) {
        log('Report creation failed: ${result.error.message}', name: 'MapView');
        _showErrorSnackBar(result.error.message);
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) Navigator.of(context).pop();

      log('Unexpected error creating report: $e', name: 'MapView');
      _showErrorSnackBar('Erro inesperado ao criar relatório');
    }
  }

  /// Show loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition =
        ref.watch(locationControllerProvider).currentPosition;
    final menuController = ref.watch(menu_ctrl.menuControllerProvider);
    final alertRadiusCircles = ref.watch(alertRadiusCirclesProvider);

    // Watch state to rebuild when markers change
    ref.watch(mapMarkersProvider);

    // Create clickable markers
    final riskMarkers = ref
        .read(mapMarkersProvider.notifier)
        .getAllMarkersWithContext((data) => _showMarkerDetails(context, data));

    // Default center or use current position if available
    final center = currentPosition != null
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : LatLng(-8.852845, 13.265561);

    return Stack(
      children: [
        // Layer 1: Map (Background)
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            onMapReady: () {
              // Center map on user location when ready
              if (currentPosition != null) {
                controller.move(
                  LatLng(currentPosition.latitude, currentPosition.longitude),
                  14.0, // Adjusted zoom for better overview of alerts
                );
              }
            },
            initialCenter: center,
            initialZoom: 13.0, // Lower initial zoom to see more area
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            // Alert radius circles (drawn first, under markers)
            CircleLayer(
              circles: alertRadiusCircles,
            ),
            // User location accuracy circle
            if (currentPosition != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    radius: currentPosition.accuracy,
                    useRadiusInMeter: true,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            if (currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.5),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers: _buildUserAvatarMarkers(ref.watch(userAvatarsProvider).activeUsers),
            ),
            MarkerLayer(
              markers: riskMarkers,
            ),
            // Search result marker
            if (_selectedSearchResult != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _selectedSearchResult!.location,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 8,
                          color: const Color(0xFF27AE60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Layer 2: Slide-Out Menu (if open)
        if (menuController.isOpen)
          GestureDetector(
            onTap: _handleMenuToggle,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        if (menuController.isOpen)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: 0,
            bottom: 0,
            child: SlideOutMenu(
              onClose: _handleMenuToggle,
            ),
          ),

        // Layer 3: Hamburger Menu Button (Top-left)
        if (!menuController.isOpen)
          HamburgerMenuButton(
            onTap: _handleMenuToggle,
          ),

        // Layer 4: Floating Profile Button (Top-right)
        if (!menuController.isOpen)
          FloatingProfileButton(
            onTap: _handleProfileTap,
          ),

        // Layer 5: Radius Control (Top center)
        if (!menuController.isOpen)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 80,
            right: 80,
            child: RadiusControlWidget(
              currentRadius: _currentRadius,
              onRadiusChanged: (newRadius) {
                setState(() {
                  _currentRadius = newRadius;
                });
                // Adjust map zoom to fit the new radius
                _adjustMapZoomForRadius(newRadius);
                // Reload reports with new radius
                _loadNearbyReportsFromBackend();
              },
            ),
          ),

        // Layer 6: Location Button (Right side, above report button)
        if (!menuController.isOpen)
          LocationButton(
            onTap: _handleLocationButtonTap,
          ),

        // Layer 7: Report Button (Right side)
        if (!menuController.isOpen)
          ReportButton(
            onTap: _handleReportButtonTap,
          ),

        // Layer 8: Home Panel (Draggable Bottom Sheet)
        if (!menuController.isOpen)
          RiskPlaceHomePanel(
            onSearchTap: _handleSearchTap,
            onVoiceSearchTap: _handleVoiceSearchTap,
          ),
      ],
    );
  }
}
