import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/report.service.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';

// ============================================================================
// GET NEARBY REPORTS USE CASE
// ============================================================================
// Clean Architecture - Domain Layer
// Fetches reports near a given location from the backend API
// Follows Single Responsibility Principle and separates business logic
// ============================================================================

/// Parameters for fetching nearby reports
class GetNearbyReportsParams {
  final double latitude;
  final double longitude;
  final int radius; // in meters

  GetNearbyReportsParams({
    required this.latitude,
    required this.longitude,
    this.radius = 10000, // Default 10km radius
  });

  /// Validate parameters
  ValidationError? validate() {
    if (latitude < -90 || latitude > 90) {
      return ValidationError(message: 'Latitude inválida');
    }
    if (longitude < -180 || longitude > 180) {
      return ValidationError(message: 'Longitude inválida');
    }
    if (radius < 100 || radius > 50000) {
      return ValidationError(message: 'Raio deve estar entre 100m e 50km');
    }
    return null;
  }
}

/// Base result type for Get Nearby Reports
abstract class GetNearbyReportsResult {}

/// Success result with list of reports
class GetNearbyReportsSuccess extends GetNearbyReportsResult {
  final List<NearbyReportDTO> reports;
  GetNearbyReportsSuccess(this.reports);
}

/// Failure result with error details
class GetNearbyReportsFailure extends GetNearbyReportsResult {
  final ReportError error;
  GetNearbyReportsFailure(this.error);
}

/// Error types for report fetching
abstract class ReportError {
  final String message;
  ReportError(this.message);
}

class NetworkError extends ReportError {
  NetworkError() : super('Sem conexão com a internet');
}

class ServerError extends ReportError {
  ServerError({String? message}) 
      : super(message ?? 'Erro no servidor. Tente novamente.');
}

class ValidationError extends ReportError {
  ValidationError({required String message}) : super(message);
}

class UnknownError extends ReportError {
  UnknownError() : super('Erro desconhecido. Tente novamente.');
}

// ============================================================================
// USE CASE IMPLEMENTATION
// ============================================================================

/// Use Case to fetch nearby reports following Clean Architecture
class GetNearbyReportsUseCase {
  final ReportService _reportService;

  GetNearbyReportsUseCase({
    required ReportService reportService,
  }) : _reportService = reportService;

  /// Execute the use case
  Future<GetNearbyReportsResult> execute(GetNearbyReportsParams params) async {
    log('Executing GetNearbyReportsUseCase', name: 'GetNearbyReportsUseCase');
    log('Location: (${params.latitude}, ${params.longitude}), Radius: ${params.radius}m', 
        name: 'GetNearbyReportsUseCase');

    // Step 1: Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      log('Validation failed: ${validationError.message}',
          name: 'GetNearbyReportsUseCase');
      return GetNearbyReportsFailure(validationError);
    }

    // Step 2: Fetch reports from backend
    try {
      final reports = await _reportService.listNearbyReports(
        latitude: params.latitude,
        longitude: params.longitude,
        radius: params.radius,
      );

      log('Successfully fetched ${reports.length} reports', 
          name: 'GetNearbyReportsUseCase');
      
      return GetNearbyReportsSuccess(reports);
      
    } on NetworkException catch (e) {
      log('Network error: ${e.message}', name: 'GetNearbyReportsUseCase');
      return GetNearbyReportsFailure(NetworkError());
      
    } on ServerException catch (e) {
      log('Server error: ${e.message}', name: 'GetNearbyReportsUseCase');
      return GetNearbyReportsFailure(ServerError(message: e.message));
      
    } on UnauthorizedException catch (e) {
      log('Unauthorized: ${e.message}', name: 'GetNearbyReportsUseCase');
      return GetNearbyReportsFailure(ServerError(message: 'Sessão expirada. Faça login novamente.'));
      
    } catch (e) {
      log('Unknown error fetching reports: $e', name: 'GetNearbyReportsUseCase');
      return GetNearbyReportsFailure(UnknownError());
    }
  }
}

// ============================================================================
// RIVERPOD PROVIDER
// ============================================================================

/// Provider for GetNearbyReportsUseCase
final getNearbyReportsUseCaseProvider = Provider<GetNearbyReportsUseCase>((ref) {
  final reportService = ref.watch(reportServiceProvider);

  return GetNearbyReportsUseCase(
    reportService: reportService,
  );
});
