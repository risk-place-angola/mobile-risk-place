import 'dart:developer' show log;
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/data/dtos/report_vote_dto.dart';

class ReportVoteService {
  final IHttpClient _httpClient;

  ReportVoteService(this._httpClient);

  Future<ReportVoteResponseDTO> voteOnReport({
    required String reportId,
    required String voteType,
  }) async {
    try {
      log('Voting on report: $reportId with vote type: $voteType',
          name: 'ReportVoteService');

      final request = ReportVoteRequestDTO(voteType: voteType);
      final response = await _httpClient.post(
        '/reports/$reportId/vote',
        data: request.toJson(),
      );

      log('Vote successful for report: $reportId', name: 'ReportVoteService');
      return ReportVoteResponseDTO.fromJson(
          response.data as Map<String, dynamic>);
    } catch (e) {
      log('Failed to vote on report: $reportId - $e',
          name: 'ReportVoteService');
      rethrow;
    }
  }

  Future<void> upvoteReport(String reportId) async {
    await voteOnReport(reportId: reportId, voteType: 'upvote');
  }

  Future<void> downvoteReport(String reportId) async {
    await voteOnReport(reportId: reportId, voteType: 'downvote');
  }
}
