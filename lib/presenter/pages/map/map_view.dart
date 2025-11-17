import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:rpa/data/mock/mock_map_data.dart';
import 'package:rpa/data/models/websocket/alert_model.dart';
import 'package:rpa/data/models/websocket/report_model.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/controllers/home_panel.controller.dart';
import 'package:rpa/presenter/controllers/menu.controller.dart' as menu_ctrl;
import 'package:rpa/presenter/pages/map/providers/map_markers_notifier.dart';
import 'package:rpa/presenter/pages/map/widgets/marker_details_sheet.dart';
import 'package:rpa/presenter/pages/map/widgets/report_button.dart';
import 'package:rpa/presenter/pages/map/widgets/location_button.dart';
import 'package:rpa/presenter/pages/map/widgets/report_selection_bottom_sheet_v2.dart';
import 'package:rpa/presenter/pages/map/widgets/report_location_editor.dart';
import 'package:rpa/data/models/risk_type.dart';
import 'package:rpa/data/models/enums/risk_type.dart' as enums;
import 'package:rpa/presenter/pages/home_page/widgets/home_panel.widget.dart';
import 'package:rpa/presenter/providers/nearby_reports_notifier.dart';
import 'package:rpa/presenter/pages/home_page/widgets/floating_profile_button.widget.dart';
import 'package:rpa/presenter/pages/menu/widgets/hamburger_button.widget.dart';
import 'package:rpa/presenter/pages/menu/slide_out_menu.dart';
import 'package:rpa/presenter/pages/profile/profile.view.dart';
// import 'package:rpa/presenter/pages/map/search/map_search_screen.dart'; // Commented while search is disabled
import 'package:rpa/data/models/place_search_result.dart';
import 'package:rpa/domain/usecases/create_report_usecase.dart';
import 'package:rpa/domain/usecases/update_report_location_usecase.dart';
import 'package:rpa/data/providers/user_provider.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController controller = MapController();
  PlaceSearchResult? _selectedSearchResult;

  @override
  void initState() {
    super.initState();
    // Start location updates when map is initialized
    // Note: Permission is requested in HomePage, so we just start updates here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider).startLocationUpdates();

      // ========================================================================
      // BACKEND INTEGRATION - Load nearby reports from API
      // ========================================================================
      _loadNearbyReportsFromBackend();

      // ========================================================================
      // MOCK DATA - TEMPORARY FOR TESTING
      // ========================================================================
      // Load mock data for testing alerts and reports on map
      // TODO: Replace with real WebSocket data when backend is connected
      // This will be removed once WebSocket integration is complete
      // ========================================================================
      _loadMockData();
    });
  }

  // ============================================================================
  // BACKEND INTEGRATION - Load reports from API
  // ============================================================================

  /// Load nearby reports from backend API
  Future<void> _loadNearbyReportsFromBackend() async {
    try {
      final locationController = ref.read(locationControllerProvider);
      final currentPosition = locationController.currentPosition;

      if (currentPosition != null) {
        log('Loading nearby reports from backend...', name: 'MapView');

        await ref.read(nearbyReportsNotifierProvider.notifier).loadReports(
              latitude: currentPosition.latitude,
              longitude: currentPosition.longitude,
              radius: 10000, // 10km radius
            );

        final reports = ref.read(nearbyReportsListProvider);

        log('Loaded ${reports.length} reports from backend', name: 'MapView');

        // Add reports to map markers
        final mapMarkersNotifier = ref.read(mapMarkersProvider.notifier);
        for (final reportDTO in reports) {
          // Convert DTO to ReportModel for the map
          final reportModel = ReportModel(
            reportId: reportDTO.id,
            message: reportDTO.description,
            latitude: reportDTO.latitude,
            longitude: reportDTO.longitude,
            riskType: enums.RiskType.fromString(reportDTO.riskType.name),
            status: _mapReportStatusFromString(reportDTO.status),
            createdAt: reportDTO.createdAt,
          );

          mapMarkersNotifier.addReport(reportModel);
        }

        log('Added ${reports.length} reports to map', name: 'MapView');
      } else {
        log('No current location available, skipping reports load',
            name: 'MapView');
      }
    } catch (e) {
      log('Error loading nearby reports: $e', name: 'MapView');
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

  // MOCK used for testing - Load mock alerts and reports into map markers
  /// Load mock data for testing markers (TEMPORARY - will be replaced by WebSocket)
  void _loadMockData() {
    final notifier = ref.read(mapMarkersProvider.notifier);
    MockMapData.loadMockData(
      notifier.addAlert,
      notifier.addReport,
    );
    log('Loaded mock alerts and reports (TEMPORARY)', name: 'MapView');

    // Load mock recent items for home panel
    _loadMockRecentItems();
  }

  // MOCK used for testing - Load mock recent items for home panel
  /// Load mock recent items for demonstration (TEMPORARY)
  void _loadMockRecentItems() {
    final panelController = ref.read(homePanelControllerProvider);

    // Set home and work addresses
    panelController.setHomeAddress('Home');
    panelController.setWorkAddress('Work');

    // Add mock recent items
    panelController.addRecentItem(RecentItem(
      id: '1',
      title: 'Talatona',
      subtitle: 'Luanda, Angola',
      icon: Icons.location_city,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: RecentItemType.neighborhood,
    ));

    panelController.addRecentItem(RecentItem(
      id: '2',
      title: 'Armed Robbery',
      subtitle: 'Reported 3 hours ago near Kilamba',
      icon: Icons.warning_amber_rounded,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: RecentItemType.incident,
    ));

    panelController.addRecentItem(RecentItem(
      id: '3',
      title: 'Safe Route to Miramar',
      subtitle: 'Via Avenida 4 de Fevereiro',
      icon: Icons.route,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: RecentItemType.safeRoute,
    ));

    panelController.addRecentItem(RecentItem(
      id: '4',
      title: 'Shopping Belas',
      subtitle: 'Belas, Luanda',
      icon: Icons.shopping_bag,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: RecentItemType.location,
    ));

    log('Loaded mock recent items', name: 'MapView');
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

  // TODO: Fix search functionality - Screen freezes when navigating to search result
  // Issue: When moving map to search result location, the screen becomes unresponsive
  // Possible causes: map controller state, navigation timing, or widget lifecycle issues
  void _handleSearchTap() async {
    // TEMPORARILY DISABLED - Screen freezing issue needs to be resolved
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search feature temporarily disabled'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
    return;

    /* COMMENTED OUT UNTIL FREEZE ISSUE IS FIXED
    final currentPosition = ref.read(locationControllerProvider).currentPosition;
    final initialCenter = currentPosition != null
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : null;

    final result = await Navigator.push<PlaceSearchResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSearchScreen(
          initialCenter: initialCenter,
          onPlaceSelected: (place) {
            // Will be handled after navigation returns
          },
        ),
      ),
    );

    // Check if widget is still mounted before using context or ref
    if (result != null && mounted) {
      _handlePlaceSelected(result);
    }
    */
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
    // TODO: Implement voice search
    print('Voice search tapped');
  }

  void _handleProfileTap() {
    // Navigate to profile view
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

    // If user cancelled, return
    if (selectedLocation == null) {
      return;
    }

    // ============================================================================
    // BACKEND INTEGRATION - Update Report Location
    // ============================================================================
    // Using Clean Architecture with Use Case pattern
    // Updates backend first, then updates local state on success
    // ============================================================================

    // Show loading dialog
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

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result is UpdateReportLocationSuccess) {
        // Update local state only after backend confirms
        final updatedReport = report.copyWith(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
        );

        // Remove old report and add updated one
        ref.read(mapMarkersProvider.notifier).removeReport(report.reportId);
        ref.read(mapMarkersProvider.notifier).addReport(updatedReport);

        // Show success message
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
        // Show error message
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
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show unexpected error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleLocationButtonTap() {
    final currentPosition =
        ref.read(locationControllerProvider).currentPosition;

    if (currentPosition != null) {
      final location = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      controller.move(location, 16.0);
    } else {
      _showErrorSnackBar('Localização não disponível. Por favor, ative o GPS.');
    }
  }

  void _handleReportButtonTap() async {
    // Check if user is logged in
    final userAsync = ref.read(currentUserProvider);
    
    // If still loading, wait for it to complete
    if (userAsync is AsyncLoading) {
      try {
        final user = await ref.read(currentUserProvider.future);
        if (user == null || user.id == null || user.id!.isEmpty) {
          _showLoginRequiredDialog();
          return;
        }
        _proceedWithReport();
      } catch (e) {
        _showLoginRequiredDialog();
      }
      return;
    }
    
    // If already loaded, check the data
    userAsync.when(
      data: (user) {
        if (user == null || user.id == null || user.id!.isEmpty) {
          _showLoginRequiredDialog();
          return;
        }
        _proceedWithReport();
      },
      loading: () {
        // This shouldn't happen since we checked above, but just in case
        _showLoginRequiredDialog();
      },
      error: (_, __) {
        _showLoginRequiredDialog();
      },
    );
  }

  void _proceedWithReport() {
    // Hide the home panel when showing report sheet
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
      // Show panel again when report sheet is closed
      ref.read(homePanelControllerProvider).showPanel();
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.lock_outline,
              color: Color(0xFFF39C12),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Login Necessário',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Você precisa fazer login para criar uma ocorrência. Deseja fazer login agora?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39C12),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Fazer Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
            reportTypeLabel: topic.name,
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

      // Prepare parameters
      final params = CreateReportParams(
        riskTypeId: riskType.id,
        riskTopicId: topic.id,
        description: '${topic.name}: ${topic.description}',
        latitude: reportLocation.latitude,
        longitude: reportLocation.longitude,
        address: '', // TODO: Get from reverse geocoding
        municipality: '', // TODO: Get from reverse geocoding
        neighborhood: '', // TODO: Get from reverse geocoding
        province: '', // TODO: Get from reverse geocoding
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
          message: '${topic.name}: ${topic.description}',
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

        _showSuccessSnackBar('${topic.name} reportado com sucesso!');
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
            // User location marker - highly visible and precise
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
                        // Outer pulsing circle
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
                        // Middle circle
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
                        // Inner precise point
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
            // Risk markers (alerts and reports)
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

        // Layer 5: Location Button (Right side, above report button)
        if (!menuController.isOpen)
          LocationButton(
            onTap: _handleLocationButtonTap,
          ),

        // Layer 6: Report Button (Right side)
        if (!menuController.isOpen)
          ReportButton(
            onTap: _handleReportButtonTap,
          ),

        // Layer 7: Home Panel (Draggable Bottom Sheet)
        if (!menuController.isOpen)
          RiskPlaceHomePanel(
            onSearchTap: _handleSearchTap,
            onVoiceSearchTap: _handleVoiceSearchTap,
          ),
      ],
    );
  }
}
