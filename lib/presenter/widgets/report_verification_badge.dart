import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/data/dtos/report_vote_dto.dart';
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'dart:io';

class ReportVerificationBadge extends ConsumerWidget {
  final NearbyReportDTO report;
  final bool showVoteButtons;

  const ReportVerificationBadge({
    super.key,
    required this.report,
    this.showVoteButtons = true,
  });

  Color _getVerificationColor() {
    if (report.verified) return const Color(0xFF00C853);
    if (report.netVotes >= 3) return const Color(0xFF64DD17);
    if (report.netVotes >= 1) return const Color(0xFFFFAB00);
    if (report.netVotes <= -3) return const Color(0xFFFF3D00);
    return const Color(0xFF9E9E9E);
  }

  IconData _getVerificationIcon() {
    if (report.verified) return Icons.verified;
    if (report.netVotes >= 3) return Icons.check_circle;
    if (report.netVotes >= 1) return Icons.thumbs_up_down;
    if (report.netVotes <= -3) return Icons.report_problem;
    return Icons.help_outline;
  }

  String _getVerificationText() {
    if (report.verified) return 'Verified';
    if (report.netVotes >= 3) return '${report.netVotes} confirm';
    if (report.netVotes >= 1) return '${report.netVotes}';
    if (report.netVotes <= -3) return 'Unreliable';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getVerificationColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getVerificationIcon(), size: 16, color: color),
          if (_getVerificationText().isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              _getVerificationText(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
          if (showVoteButtons) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(width: 6),
            _VoteButtons(report: report),
          ],
        ],
      ),
    );
  }
}

class _VoteButtons extends ConsumerStatefulWidget {
  final NearbyReportDTO report;

  const _VoteButtons({required this.report});

  @override
  ConsumerState<_VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends ConsumerState<_VoteButtons> {
  bool _isVoting = false;

  Future<void> _vote(String voteType) async {
    if (_isVoting) return;

    setState(() => _isVoting = true);

    try {
      final service = ref.read(reportVoteServiceProvider);
      await service.voteOnReport(
        reportId: widget.report.id,
        voteType: voteType,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  voteType == 'upvote' ? Icons.check_circle : Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  voteType == 'upvote'
                      ? (l10n?.voteConfirmed ?? 'Thanks for confirming!')
                      : (l10n?.voteFeedbackReceived ?? 'Feedback received'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: voteType == 'upvote'
                ? const Color(0xFF00C853)
                : const Color(0xFFFFAB00),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _handleVoteError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isVoting = false);
      }
    }
  }

  void _handleVoteError(dynamic error) {
    final l10n = AppLocalizations.of(context);
    
    String title = l10n?.voteErrorTitle ?? 'Unable to vote';
    String message = l10n?.voteErrorMessage ?? 'We couldn\'t process your vote. Please try again.';
    
    if (error is VoteException) {
      message = error.message;
    } else if (error is SocketException) {
      message = l10n?.voteErrorNetwork ?? 'Connection error. Check your internet and try again.';
    } else if (error.toString().contains('500')) {
      message = l10n?.voteErrorServer ?? 'Server error. Please try again later.';
    } else if (error.toString().contains('401') || error.toString().contains('403')) {
      message = l10n?.voteErrorUnauthorized ?? 'You must be logged in to vote.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVote = widget.report.userVote;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isVoting ? null : () => _vote('upvote'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: userVote == 'upvote'
                    ? const Color(0xFF00C853).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    userVote == 'upvote'
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 14,
                    color: userVote == 'upvote'
                        ? const Color(0xFF00C853)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.report.upvotes}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: userVote == 'upvote'
                          ? const Color(0xFF00C853)
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isVoting ? null : () => _vote('downvote'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: userVote == 'downvote'
                    ? const Color(0xFFFF3D00).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    userVote == 'downvote'
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    size: 14,
                    color: userVote == 'downvote'
                        ? const Color(0xFFFF3D00)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.report.downvotes}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: userVote == 'downvote'
                          ? const Color(0xFFFF3D00)
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReportTrustIndicator extends StatelessWidget {
  final int netVotes;
  final bool verified;
  final bool compact;

  const ReportTrustIndicator({
    super.key,
    required this.netVotes,
    required this.verified,
    this.compact = false,
  });

  Color _getTrustColor() {
    if (verified) return const Color(0xFF00C853);
    if (netVotes >= 3) return const Color(0xFF64DD17);
    if (netVotes >= 1) return const Color(0xFFFFAB00);
    if (netVotes <= -3) return const Color(0xFFFF3D00);
    return const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTrustColor();

    if (verified) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: compact ? 14 : 16, color: color),
            if (!compact) ...[
              const SizedBox(width: 4),
              Text(
                'Verified',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            netVotes >= 1 ? Icons.thumb_up : Icons.help_outline,
            size: compact ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '$netVotes',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactVerificationBadge extends StatelessWidget {
  final NearbyReportDTO report;

  const CompactVerificationBadge({
    super.key,
    required this.report,
  });

  Color _getColor() {
    if (report.verified) return const Color(0xFF00C853);
    if (report.netVotes >= 3) return const Color(0xFF64DD17);
    if (report.netVotes >= 1) return const Color(0xFFFFAB00);
    if (report.netVotes <= -3) return const Color(0xFFFF3D00);
    return const Color(0xFF9E9E9E);
  }

  IconData _getIcon() {
    if (report.verified) return Icons.verified;
    if (report.netVotes >= 1) return Icons.check_circle;
    if (report.netVotes <= -3) return Icons.warning_amber_rounded;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Icon(_getIcon(), size: 12, color: color),
    );
  }
}
