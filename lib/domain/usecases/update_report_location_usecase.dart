import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/update_report_location_dto.dart';
import 'package:rpa/data/services/report.service.dart';

final updateReportLocationUseCaseProvider =
    Provider<UpdateReportLocationUseCase>((ref) {
  final reportService = ref.read(reportServiceProvider);
  return UpdateReportLocationUseCase(reportService: reportService);
});

/// Parameters for updating report location
class UpdateReportLocationParams {
  final String reportId;
  final double latitude;
  final double longitude;
  final String? address;
  final String? neighborhood;
  final String? municipality;
  final String? province;

  const UpdateReportLocationParams({
    required this.reportId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.neighborhood,
    this.municipality,
    this.province,
  });

  /// Validate parameters
  bool isValid() {
    if (reportId.isEmpty) {
      log('Validation failed: Report ID is required',
          name: 'UpdateReportLocationParams');
      return false;
    }

    if (latitude < -90 || latitude > 90) {
      log('Validation failed: Invalid latitude',
          name: 'UpdateReportLocationParams');
      return false;
    }

    if (longitude < -180 || longitude > 180) {
      log('Validation failed: Invalid longitude',
          name: 'UpdateReportLocationParams');
      return false;
    }

    return true;
  }
}

/// Result for update report location operation
abstract class UpdateReportLocationResult {
  const UpdateReportLocationResult();
}

/// Success result
class UpdateReportLocationSuccess extends UpdateReportLocationResult {
  final UpdateReportLocationResponseDTO response;

  const UpdateReportLocationSuccess(this.response);
}

/// Failure result
class UpdateReportLocationFailure extends UpdateReportLocationResult {
  final String message;
  final String? errorCode;

  const UpdateReportLocationFailure({
    required this.message,
    this.errorCode,
  });
}

/// Use Case for updating report location
class UpdateReportLocationUseCase {
  final ReportService _reportService;

  UpdateReportLocationUseCase({required ReportService reportService})
      : _reportService = reportService;

  /// Execute the use case
  Future<UpdateReportLocationResult> call(
      UpdateReportLocationParams params) async {
    try {
      // Validate parameters
      if (!params.isValid()) {
        return const UpdateReportLocationFailure(
          message: 'Parâmetros inválidos para atualizar localização',
          errorCode: 'INVALID_PARAMS',
        );
      }

      log('Executing UpdateReportLocationUseCase for report ${params.reportId}',
          name: 'UpdateReportLocationUseCase');

      // Create request DTO
      final requestDTO = UpdateReportLocationRequestDTO(
        latitude: params.latitude,
        longitude: params.longitude,
        address: params.address,
        neighborhood: params.neighborhood,
        municipality: params.municipality,
        province: params.province,
      );

      // Call service
      final response = await _reportService.updateReportLocation(
        reportId: params.reportId,
        locationData: requestDTO,
      );

      log('Report location updated successfully',
          name: 'UpdateReportLocationUseCase');

      return UpdateReportLocationSuccess(response);
    } on NetworkException catch (e) {
      log('Network error updating report location: ${e.message}',
          name: 'UpdateReportLocationUseCase');
      return UpdateReportLocationFailure(
        message: 'Erro de conexão. Verifique sua internet.',
        errorCode: 'NETWORK_ERROR',
      );
    } on UnauthorizedException catch (e) {
      log('Unauthorized error updating report location: ${e.message}',
          name: 'UpdateReportLocationUseCase');
      return const UpdateReportLocationFailure(
        message: 'Sessão expirada. Faça login novamente.',
        errorCode: 'UNAUTHORIZED',
      );
    } on ServerException catch (e) {
      log('Server error updating report location: ${e.message}',
          name: 'UpdateReportLocationUseCase');
      return UpdateReportLocationFailure(
        message: e.message,
        errorCode: 'SERVER_ERROR',
      );
    } catch (e) {
      log('Unexpected error updating report location: $e',
          name: 'UpdateReportLocationUseCase');
      return const UpdateReportLocationFailure(
        message: 'Erro inesperado ao atualizar localização',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }
}
