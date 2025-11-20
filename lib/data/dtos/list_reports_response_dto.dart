import 'package:rpa/data/dtos/list_nearby_reports_response_dto.dart';

/// DTO para parâmetros de query do GET /reports
class ReportsQueryParams {
  final int page;
  final int limit;
  final String? status;
  final String sort;
  final String order;

  const ReportsQueryParams({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.sort = 'created_at',
    this.order = 'desc',
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (status != null && status!.isNotEmpty) 'status': status,
      'sort': sort,
      'order': order,
    };
  }

  ReportsQueryParams copyWith({
    int? page,
    int? limit,
    String? status,
    String? sort,
    String? order,
  }) {
    return ReportsQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportsQueryParams &&
        other.page == page &&
        other.limit == limit &&
        other.status == status &&
        other.sort == sort &&
        other.order == order;
  }

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      status.hashCode ^
      sort.hashCode ^
      order.hashCode;
}

/// DTO para metadata de paginação na resposta
class PaginationDTO {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;
  final bool hasPrevious;

  const PaginationDTO({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
    required this.hasPrevious,
  });

  factory PaginationDTO.fromJson(Map<String, dynamic> json) {
    return PaginationDTO(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      hasMore: json['has_more'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'total_pages': totalPages,
        'has_more': hasMore,
        'has_previous': hasPrevious,
      };
}

/// DTO para resposta do GET /reports com paginação
class ListReportsResponseDTO {
  final List<NearbyReportDTO> data;
  final PaginationDTO pagination;

  const ListReportsResponseDTO({
    required this.data,
    required this.pagination,
  });

  factory ListReportsResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ListReportsResponseDTO(
      data: dataList
          .map((item) => NearbyReportDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationDTO.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
}
