import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/domain/usecases/get_nearby_reports_usecase.dart';

// ============================================================================
// NEARBY REPORTS STATE NOTIFIER
// ============================================================================
// Manages the state of nearby reports with WebSocket support
// Combines initial API load with real-time WebSocket updates
// Uses Riverpod 3.0+ Notifier pattern
// ============================================================================

/// State for nearby reports
class NearbyReportsState {
  final List<NearbyReportDTO> reports;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  NearbyReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  NearbyReportsState copyWith({
    List<NearbyReportDTO>? reports,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return NearbyReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if we have reports
  bool get hasReports => reports.isNotEmpty;

  /// Check if we have an error
  bool get hasError => errorMessage != null;
}

// ============================================================================
// NOTIFIER IMPLEMENTATION (Riverpod 3.0+)
// ============================================================================

/// Notifier to manage nearby reports
class NearbyReportsNotifier extends Notifier<NearbyReportsState> {
  @override
  NearbyReportsState build() {
    return NearbyReportsState();
  }

  GetNearbyReportsUseCase get _getNearbyReportsUseCase =>
      ref.read(getNearbyReportsUseCaseProvider);

  /// Load reports from backend API
  Future<void> loadReports({
    required double latitude,
    required double longitude,
    int radius = 10000,
  }) async {
    log('Loading reports...', name: 'NearbyReportsNotifier');
    
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Create params
    final params = GetNearbyReportsParams(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    // Execute use case
    final result = await _getNearbyReportsUseCase.execute(params);

    // Handle result
    if (result is GetNearbyReportsSuccess) {
      log('Successfully loaded ${result.reports.length} reports', 
          name: 'NearbyReportsNotifier');
      
      state = state.copyWith(
        reports: result.reports,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } else if (result is GetNearbyReportsFailure) {
      log('Failed to load reports: ${result.error.message}', 
          name: 'NearbyReportsNotifier');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error.message,
      );
    }
  }

  /// Add a new report from WebSocket (real-time update)
  void addReportFromWebSocket(NearbyReportDTO newReport) {
    log('Adding new report from WebSocket: ${newReport.id}', 
        name: 'NearbyReportsNotifier');

    // Check if report already exists
    final existingIndex = state.reports.indexWhere((r) => r.id == newReport.id);
    
    if (existingIndex >= 0) {
      // Update existing report
      final updatedReports = List<NearbyReportDTO>.from(state.reports);
      updatedReports[existingIndex] = newReport;
      
      state = state.copyWith(
        reports: updatedReports,
        lastUpdated: DateTime.now(),
      );
      
      log('Updated existing report: ${newReport.id}', name: 'NearbyReportsNotifier');
    } else {
      // Add new report
      state = state.copyWith(
        reports: [...state.reports, newReport],
        lastUpdated: DateTime.now(),
      );
      
      log('Added new report: ${newReport.id}', name: 'NearbyReportsNotifier');
    }
  }

  /// Update an existing report from WebSocket
  void updateReportFromWebSocket(NearbyReportDTO updatedReport) {
    log('Updating report from WebSocket: ${updatedReport.id}', 
        name: 'NearbyReportsNotifier');

    final updatedReports = state.reports.map((report) {
      if (report.id == updatedReport.id) {
        return updatedReport;
      }
      return report;
    }).toList();

    state = state.copyWith(
      reports: updatedReports,
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove a report (e.g., when resolved)
  void removeReport(String reportId) {
    log('Removing report: $reportId', name: 'NearbyReportsNotifier');

    final updatedReports = state.reports.where((r) => r.id != reportId).toList();
    
    state = state.copyWith(
      reports: updatedReports,
      lastUpdated: DateTime.now(),
    );
  }

  /// Clear all reports
  void clearReports() {
    log('Clearing all reports', name: 'NearbyReportsNotifier');
    state = NearbyReportsState();
  }

  /// Refresh reports (pull-to-refresh)
  Future<void> refresh({
    required double latitude,
    required double longitude,
    int radius = 10000,
  }) async {
    log('Refreshing reports...', name: 'NearbyReportsNotifier');
    await loadReports(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}

// ============================================================================
// RIVERPOD PROVIDERS (Riverpod 3.0+)
// ============================================================================

/// Provider for NearbyReportsNotifier
final nearbyReportsNotifierProvider =
    NotifierProvider<NearbyReportsNotifier, NearbyReportsState>(() {
  return NearbyReportsNotifier();
});

/// Convenience provider to get just the reports list
final nearbyReportsListProvider = Provider<List<NearbyReportDTO>>((ref) {
  return ref.watch(nearbyReportsNotifierProvider).reports;
});

/// Convenience provider to check if loading
final nearbyReportsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(nearbyReportsNotifierProvider).isLoading;
});

/// Convenience provider to get error message
final nearbyReportsErrorProvider = Provider<String?>((ref) {
  return ref.watch(nearbyReportsNotifierProvider).errorMessage;
});
