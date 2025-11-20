class VoteException implements Exception {
  final String message;
  const VoteException(this.message);
  
  @override
  String toString() => message;
}

class ReportVoteRequestDTO {
  final String voteType;

  const ReportVoteRequestDTO({
    required this.voteType,
  });

  Map<String, dynamic> toJson() => {
        'vote_type': voteType,
      };
}

class ReportVoteResponseDTO {
  final String reportId;
  final int upvotes;
  final int downvotes;
  final int netVotes;
  final String? userVote;
  final bool verified;
  final DateTime? verifiedAt;

  const ReportVoteResponseDTO({
    required this.reportId,
    required this.upvotes,
    required this.downvotes,
    required this.netVotes,
    this.userVote,
    required this.verified,
    this.verifiedAt,
  });

  factory ReportVoteResponseDTO.fromJson(Map<String, dynamic> json) {
    if (json['success'] == false) {
      final error = json['error'] as Map<String, dynamic>?;
      final message = error?['message'] ?? 'Failed to vote';
      throw VoteException(message);
    }

    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return ReportVoteResponseDTO(
      reportId: data['report_id'] as String,
      upvotes: data['upvotes'] as int? ?? 0,
      downvotes: data['downvotes'] as int? ?? 0,
      netVotes: data['net_votes'] as int? ?? 0,
      userVote: data['user_vote'] as String?,
      verified: data['verified'] as bool? ?? false,
      verifiedAt: data['verified_at'] != null
          ? DateTime.tryParse(data['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'upvotes': upvotes,
        'downvotes': downvotes,
        'net_votes': netVotes,
        'user_vote': userVote,
        'verified': verified,
        'verified_at': verifiedAt?.toIso8601String(),
      };
}
