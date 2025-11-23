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
    final reportsAsync = ref.watch(
      allReportsProvider(ReportsQueryParams(
        page: _currentPage,
        status: _selectedStatus,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: reportsAsync.when(
        data: (data) => _buildReportsList(data),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filtrar por:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            _buildFilterChip('Todos', null),
            const SizedBox(width: 8),
            _buildFilterChip('Pendente', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Verificado', 'verified'),
            const SizedBox(width: 8),
            _buildFilterChip('Resolvido', 'resolved'),
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
              'Nenhum relatório encontrado',
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
          padding: const EdgeInsets.all(12),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${data.pagination.total} relatórios',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Página ${data.pagination.page} de ${data.pagination.totalPages}',
                style: TextStyle(color: Colors.grey[700]),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(report.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
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
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
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
    switch (status.toLowerCase()) {
      case 'verified':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.verified, color: Colors.white),
        );
      case 'resolved':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.check_circle, color: Colors.white),
        );
      case 'pending':
      default:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.pending, color: Colors.white),
        );
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verificado';
      case 'resolved':
        return 'Resolvido';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  Widget _buildErrorState(Object error) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(l10n?.errorLoadingReports ?? 'Erro ao carregar relatórios'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text(l10n?.tryAgainButton ?? 'Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(NearbyReportDTO report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
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
                // Description
                Text(
                  report.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Details
                _buildDetailRow(
                    'Local', '${report.neighborhood}, ${report.municipality}'),
                _buildDetailRow('Endereço', report.address),
                _buildDetailRow('Província', report.province),
                _buildDetailRow('Data',
                    DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)),
                _buildDetailRow('Coordenadas',
                    '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}'),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
