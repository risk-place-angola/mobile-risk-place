import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/create_report_request_dto.dart';
import 'package:rpa/data/services/report.service.dart';
import 'package:rpa/data/providers/user_provider.dart';

abstract class CreateReportResult {}

class CreateReportSuccess implements CreateReportResult {
  final ReportResponseDTO report;
  const CreateReportSuccess(this.report);
}

class CreateReportFailure implements CreateReportResult {
  final CreateReportError error;
  const CreateReportFailure(this.error);
}

abstract class CreateReportError {
  String get message;
}

class UserNotAuthenticatedError implements CreateReportError {
  @override
  String get message => 'Você precisa estar logado para criar um relatório';
}

class LocationNotAvailableError implements CreateReportError {
  @override
  String get message => 'Localização não disponível. Por favor, ative o GPS.';
}

class NetworkError implements CreateReportError {
  @override
  String get message => 'Sem conexão com a internet. Tente novamente.';
}

class ServerError implements CreateReportError {
  final String details;
  const ServerError(this.details);

  @override
  String get message => 'Erro no servidor: $details';
}

class ValidationError implements CreateReportError {
  final String field;
  const ValidationError(this.field);

  @override
  String get message => 'Campo inválido: $field';
}

class UnknownError implements CreateReportError {
  final String details;
  const UnknownError(this.details);

  @override
  String get message => 'Erro inesperado: $details';
}

/// Input parameters for creating a report
class CreateReportParams {
  final String riskTypeId;
  final String riskTopicId;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? municipality;
  final String? neighborhood;
  final String? province;
  final String? imageUrl;

  const CreateReportParams({
    required this.riskTypeId,
    required this.riskTopicId,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.municipality,
    this.neighborhood,
    this.province,
    this.imageUrl,
  });

  /// Validates parameters
  CreateReportError? validate() {
    if (riskTypeId.isEmpty) return const ValidationError('riskTypeId');
    if (riskTopicId.isEmpty) return const ValidationError('riskTopicId');
    if (description.isEmpty) return const ValidationError('description');
    if (latitude < -90 || latitude > 90) {
      return const ValidationError('latitude');
    }
    if (longitude < -180 || longitude > 180) {
      return const ValidationError('longitude');
    }
    return null;
  }
}

/// Use Case for creating a report
/// Follows Single Responsibility Principle - only handles report creation logic
class CreateReportUseCase {
  final ReportService _reportService;
  final String? _currentUserId;

  CreateReportUseCase({
    required ReportService reportService,
    required String? currentUserId,
  })  : _reportService = reportService,
        _currentUserId = currentUserId;

  /// Execute the use case
  Future<CreateReportResult> execute(CreateReportParams params) async {
    log('Executing CreateReportUseCase', name: 'CreateReportUseCase');

    // Step 1: Validate user authentication
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      log('User not authenticated', name: 'CreateReportUseCase');
      return CreateReportFailure(UserNotAuthenticatedError());
    }

    final userId = _currentUserId!;
    log('Creating report with user_id: $userId', name: 'CreateReportUseCase');

    // Step 2: Validate parameters
    final validationError = params.validate();
    if (validationError != null) {
      log('Validation failed: ${validationError.message}',
          name: 'CreateReportUseCase');
      return CreateReportFailure(validationError);
    }

    // Step 3: Prepare request DTO
    final requestDto = CreateReportRequestDTO(
      userId: userId,
      riskTypeId: params.riskTypeId,
      riskTopicId: params.riskTopicId,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      address: params.address ?? '',
      municipality: params.municipality ?? '',
      neighborhood: params.neighborhood ?? '',
      province: params.province ?? '',
      imageUrl: params.imageUrl ?? '',
    );

    // Step 4: Call service
    try {
      log('Calling report service...', name: 'CreateReportUseCase');
      final report = await _reportService.createReport(reportData: requestDto);
      log('Report created successfully: ${report.id}',
          name: 'CreateReportUseCase');
      return CreateReportSuccess(report);
    } on NetworkException catch (e) {
      log('Network error: ${e.message}', name: 'CreateReportUseCase');
      return CreateReportFailure(NetworkError());
    } on ServerException catch (e) {
      log('Server error: ${e.message}', name: 'CreateReportUseCase');
      return CreateReportFailure(ServerError(e.message));
    } on HttpException catch (e) {
      log('HTTP error: ${e.message}', name: 'CreateReportUseCase');
      return CreateReportFailure(ServerError(e.message));
    } catch (e) {
      log('Unknown error: $e', name: 'CreateReportUseCase');
      return CreateReportFailure(UnknownError(e.toString()));
    }
  }
}

/// Provider for CreateReportUseCase
final createReportUseCaseProvider =
    FutureProvider<CreateReportUseCase>((ref) async {
  final reportService = ref.watch(reportServiceProvider);

  // Wait for user to be loaded from storage
  final user = await ref.watch(currentUserProvider.future);
  final currentUserId = user?.id;

  return CreateReportUseCase(
    reportService: reportService,
    currentUserId: currentUserId,
  );
});
