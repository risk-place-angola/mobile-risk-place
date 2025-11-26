import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/providers/api_providers.dart';
import 'package:rpa/data/dtos/list_reports_response_dto.dart';
import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';
import 'package:rpa/presenter/widgets/report_verification_badge.dart';
import 'package:intl/intl.dart';

/// Tela de administração/listagem global de reports
/// Usa GET /reports com paginação
class AllReportsScreen extends ConsumerStatefulWidget {
  const AllReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends ConsumerState<AllReportsScreen> {
  int _currentPage = 1;
  String? _selectedStatus;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMore();
    }
  }

  void _loadMore() {
    final currentData = ref.read(
      allReportsProvider(ReportsQueryParams(
        page: _currentPage,
        status: _selectedStatus,
      )),
    );

    currentData.whenData((data) {
      if (data.pagination.hasMore) {
        setState(() {
          _currentPage++;
        });
      }
    });
  }

  void _refreshData() {
    setState(() {
      _currentPage = 1;
    });
    ref.invalidate(allReportsProvider);
  }

  void _changeStatusFilter(String? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    ref.invalidate(allReportsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reportsAsync = ref.watch(
      allReportsProvider(ReportsQueryParams(
        page: _currentPage,
        status: _selectedStatus,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.allReportsTitle ?? 'All Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: l10n?.refresh ?? 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: reportsAsync.when(
        data: (data) => _buildReportsList(data),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildFilterBar() {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              l10n?.filterBy ?? 'Filter by:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            _buildFilterChip(l10n?.all ?? 'All', null),
            const SizedBox(width: 8),
            _buildFilterChip(l10n?.pending ?? 'Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip(l10n?.verified ?? 'Verified', 'verified'),
            const SizedBox(width: 8),
            _buildFilterChip(l10n?.resolved ?? 'Resolved', 'resolved'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _changeStatusFilter(value),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Widget _buildReportsList(ListReportsResponseDTO data) {
    final l10n = AppLocalizations.of(context);
    if (data.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.noReportsFound ?? 'No reports found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pagination info
        Container(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 360 ? 8 : 12,
          ),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n?.totalReports(data.pagination.total) ?? 'Total: ${data.pagination.total} reports',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width < 360 ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n?.pageOf(data.pagination.page, data.pagination.totalPages) ?? 'Page ${data.pagination.page} of ${data.pagination.totalPages}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: MediaQuery.of(context).size.width < 360 ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        // Reports list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: data.data.length + (data.pagination.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == data.data.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildReportCard(data.data[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(NearbyReportDTO report) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isSmallScreen ? 10.0 : 12.0;
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isSmallScreen ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(report.status),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buildReportTitle(report),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.neighborhood}, ${report.municipality}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isSmallScreen ? 12 : 14,
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _formatDate(report.createdAt),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReportVerificationBadge(
                    report: report,
                    showVoteButtons: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width < 360 ? 18.0 : 20.0;
    final avatarRadius = size.width < 360 ? 16.0 : 20.0;
    
    switch (status.toLowerCase()) {
      case 'verified':
        return CircleAvatar(
          backgroundColor: Colors.green,
          radius: avatarRadius,
          child: Icon(Icons.verified, color: Colors.white, size: iconSize),
        );
      case 'resolved':
        return CircleAvatar(
          backgroundColor: Colors.blue,
          radius: avatarRadius,
          child: Icon(Icons.check_circle, color: Colors.white, size: iconSize),
        );
      case 'pending':
      default:
        return CircleAvatar(
          backgroundColor: Colors.orange,
          radius: avatarRadius,
          child: Icon(Icons.pending, color: Colors.white, size: iconSize),
        );
    }
  }

  String _getStatusText(String status) {
    final l10n = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'verified':
        return l10n?.verified ?? 'Verified';
      case 'resolved':
        return l10n?.resolved ?? 'Resolved';
      case 'pending':
        return l10n?.pending ?? 'Pending';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return l10n?.minutesAgo(difference.inMinutes) ?? '${difference.inMinutes} min ago';
      }
      return l10n?.hoursAgo(difference.inHours) ?? '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return l10n?.daysAgo(difference.inDays) ?? '${difference.inDays}d ago';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              l10n?.loadingReports ?? 'Loading reports...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.loadingRiskTypesMessage ?? 
                'Loading available risk categories, please wait a moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final l10n = AppLocalizations.of(context);
    final isTimeout = error.toString().contains('timeout') || 
                      error.toString().contains('TimeoutException');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTimeout ? Icons.timer_off : Icons.error,
              size: 64,
              color: isTimeout ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              isTimeout 
                ? (l10n?.timeoutError ?? 'Request Timeout')
                : (l10n?.errorLoadingReports ?? 'Error loading reports'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTimeout
                ? (l10n?.timeoutErrorMessage ?? 'The server is taking too long to respond. This may be due to slow API or poor internet connection.')
                : error.toString(),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.tryAgainButton ?? 'Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            if (isTimeout) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.timeoutTip ?? 'Tip: Check your internet connection or try again in a few moments.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReportDetails(NearbyReportDTO report) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        final l10n = AppLocalizations.of(modalContext);
        return DraggableScrollableSheet(
          initialChildSize: isSmallScreen ? 0.7 : 0.6,
          minChildSize: isSmallScreen ? 0.5 : 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Status badge
                Row(
                  children: [
                    _buildStatusIcon(report.status),
                    const SizedBox(width: 12),
                    Text(
                      _getStatusText(report.status),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // User Description (without topic prefix)
                if (_getUserDescription(report).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      _getUserDescription(report),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                // Details
                if (report.riskTypeName != null && report.riskTypeName!.isNotEmpty)
                  _buildDetailRow(
                      l10n?.riskType ?? 'Risk Type', 
                      _translateRiskType(report.riskTypeName)),
                if (report.riskTopicName != null && report.riskTopicName!.isNotEmpty)
                  _buildDetailRow(
                      l10n?.riskTopic ?? 'Topic', 
                      _translateTopic(report.riskTopicName)),
                if (report.neighborhood.isNotEmpty || report.municipality.isNotEmpty)
                  _buildDetailRow(
                      l10n?.location ?? 'Local', 
                      '${report.neighborhood}${report.neighborhood.isNotEmpty && report.municipality.isNotEmpty ? ", " : ""}${report.municipality}'),
                if (report.address.isNotEmpty)
                  _buildDetailRow(
                      l10n?.address ?? 'Endereço', 
                      report.address),
                if (report.province.isNotEmpty)
                  _buildDetailRow(
                      l10n?.province ?? 'Província', 
                      report.province),
                _buildDetailRow(
                    l10n?.reportedAt ?? 'Reportado em',
                    DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)),
                if (report.updatedAt.difference(report.createdAt).inMinutes > 1)
                  _buildDetailRow(
                      l10n?.lastUpdate ?? 'Última Atualização',
                      DateFormat('dd/MM/yyyy HH:mm').format(report.updatedAt)),
                if (report.expiresAt != null)
                  _buildDetailRow(
                      l10n?.expiresAt ?? 'Expira em',
                      DateFormat('dd/MM/yyyy HH:mm').format(report.expiresAt!)),
                _buildDetailRow(
                    l10n?.coordinates ?? 'Coordenadas',
                    '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}'),
                if (report.verificationCount > 0 || report.rejectionCount > 0) ...[
                  _buildDetailRow(l10n?.verifications ?? 'Verifications',
                      '${report.verificationCount}'),
                  _buildDetailRow(l10n?.rejections ?? 'Rejections',
                      '${report.rejectionCount}'),
                  _buildDetailRow(l10n?.netScore ?? 'Net Score',
                      '${report.verificationCount - report.rejectionCount}'),
                ],
                // Image if available
                if (report.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      report.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isSmallScreen ? 80 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build report title with translated risk type and topic
  String _buildReportTitle(NearbyReportDTO report) {
    // Check if description contains the concatenated format "topic: description"
    if (report.description.contains(':')) {
      final parts = report.description.split(':');
      if (parts.length >= 2) {
        final topicKey = parts[0].trim();
        final description = parts.sublist(1).join(':').trim();
        
        // Translate the topic key
        final translatedTopic = _translateTopicKey(topicKey);
        return '$translatedTopic: $description';
      }
    }
    
    // Fallback: use riskTypeName and riskTopicName if available
    final translatedType = _translateRiskType(report.riskTypeName);
    final translatedTopic = _translateTopic(report.riskTopicName);
    
    if (translatedTopic.isNotEmpty) {
      return '$translatedType: $translatedTopic';
    }
    return translatedType.isNotEmpty ? translatedType : report.description;
  }
  
  /// Get user description (without the topic prefix)
  String _getUserDescription(NearbyReportDTO report) {
    if (report.description.contains(':')) {
      final parts = report.description.split(':');
      if (parts.length >= 2) {
        return parts.sublist(1).join(':').trim();
      }
    }
    return report.description;
  }

  /// Translate risk type name from backend to localized string
  String _translateRiskType(String? riskTypeName) {
    if (riskTypeName == null || riskTypeName.isEmpty) return '';
    final l10n = AppLocalizations.of(context);
    
    final normalized = riskTypeName.toLowerCase().trim();
    
    switch (normalized) {
      case 'crime':
      case 'assalto':
        return l10n?.crime ?? 'Crime';
      case 'accident':
      case 'acidente':
      case 'acidente_trabalho':
      case 'acidente de trânsito':
        return l10n?.accident ?? 'Accident';
      case 'natural disaster':
      case 'desastre natural':
      case 'natural_disaster':
        return l10n?.naturalDisaster ?? 'Natural Disaster';
      case 'fire':
      case 'incêndio':
      case 'fogo':
        return l10n?.fire ?? 'Fire';
      case 'health':
      case 'saúde':
        return l10n?.health ?? 'Health';
      case 'infrastructure':
      case 'infraestrutura':
        return l10n?.infrastructure ?? 'Infrastructure';
      case 'environment':
      case 'ambiente':
      case 'meio ambiente':
      case 'vazamento_quimico':
        return l10n?.environment ?? 'Environment';
      case 'violence':
      case 'violência':
        return l10n?.violence ?? 'Violence';
      case 'public safety':
      case 'segurança pública':
      case 'public_safety':
        return l10n?.publicSafety ?? 'Public Safety';
      case 'traffic':
      case 'trânsito':
        return l10n?.traffic ?? 'Traffic';
      case 'urban issue':
      case 'problema urbano':
      case 'urban_issue':
        return l10n?.urbanIssue ?? 'Urban Issue';
      default:
        // Return original if no translation found
        return riskTypeName;
    }
  }

  /// Translate risk topic name from backend to localized string
  String _translateTopic(String? topicName) {
    if (topicName == null || topicName.isEmpty) return '';
    
    // For topics, since they are dynamic from backend, 
    // we'll format them nicely but keep the original name
    // Replace underscores and capitalize
    return topicName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
  /// Translate topic key that comes in description (e.g., "vazamento_quimico")
  String _translateTopicKey(String topicKey) {
    final l10n = AppLocalizations.of(context);
    final normalized = topicKey.toLowerCase().trim().replaceAll(' ', '_');
    
    // Map common topic keys to their risk types
    switch (normalized) {
      case 'vazamento_quimico':
      case 'chemical_spill':
        return l10n?.environment ?? 'Environment';
      case 'assalto':
      case 'roubo':
      case 'theft':
      case 'robbery':
        return l10n?.crime ?? 'Crime';
      case 'acidente_trabalho':
      case 'work_accident':
        return l10n?.accident ?? 'Accident';
      case 'incendio':
      case 'fire':
        return l10n?.fire ?? 'Fire';
      default:
        // Try to match with risk type translations first
        final riskTypeTranslation = _translateRiskType(topicKey);
        if (riskTypeTranslation.isNotEmpty) {
          return riskTypeTranslation;
        }
        // Format the key nicely
        return _translateTopic(topicKey);
    }
  }
}
