import 'package:flutter/foundation.dart';

import '../../../../networking/api_service.dart';
import '../../../../networking/routes/booking_routes.dart';
import '../../../pillbox/domain/entities/paginated_response.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/available_slots.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  @override
  Future<PaginatedResponse<Doctor>> listDoctors({
    String? specialty,
    String? city,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (specialty != null && specialty.isNotEmpty) params['specialty'] = specialty;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await ApiService.authGet(
      BookingRoutes.doctors(),
      params: params,
    );
    if (kDebugMode) {
      final keys = response is Map<String, dynamic> ? response.keys.join(', ') : '';
      debugPrint('Booking doctors response type=${response.runtimeType} keys=[$keys]');
      debugPrint('Booking doctors raw response: $response');
    }

    final payload = response is Map<String, dynamic> ? _extractCollectionPayload(response) : null;
    final rawItems = _extractItemsDeep(payload ?? response);
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Doctor.fromJson)
        .toList();

    return PaginatedResponse(
      items: items,
      page: _readIntDeep(payload ?? response, const ['page']) ?? page,
      limit: _readIntDeep(payload ?? response, const ['limit']) ?? limit,
      total: _readIntDeep(
            payload ?? response,
            const ['total', 'count', 'totalCount', 'totalItems'],
          ) ??
          items.length,
    );
  }

  @override
  Future<AvailableSlots> getAvailableSlots({
    required String doctorId,
    required String date,
  }) async {
    final response = await ApiService.authGet(
      BookingRoutes.availableSlots(doctorId),
      params: {'date': date},
    );
    return AvailableSlots.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? reason,
  }) async {
    final payload = <String, dynamic>{
      'doctorId': doctorId,
      'date': date,
      'time': time,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };
    final response = await ApiService.authPost(BookingRoutes.appointments(), payload);
    return Appointment.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PaginatedResponse<Appointment>> listMyAppointments({
    String? status,
    String? from,
    String? to,
    int page = 1,
    int limit = 20,
    String sort = 'dateDesc',
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;

    final response = await ApiService.authGet(
      BookingRoutes.appointments(),
      params: params,
    );
    if (kDebugMode) {
      final keys = response is Map<String, dynamic> ? response.keys.join(', ') : '';
      debugPrint('Booking appointments response type=${response.runtimeType} keys=[$keys]');
    }

    final payload = response is Map<String, dynamic> ? _extractCollectionPayload(response) : null;
    final rawItems = _extractItemsDeep(payload ?? response);
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Appointment.fromJson)
        .toList();

    return PaginatedResponse(
      items: items,
      page: _readIntDeep(payload ?? response, const ['page']) ?? page,
      limit: _readIntDeep(payload ?? response, const ['limit']) ?? limit,
      total: _readIntDeep(
            payload ?? response,
            const ['total', 'count', 'totalCount', 'totalItems'],
          ) ??
          items.length,
    );
  }

  @override
  Future<Appointment> getAppointmentDetail(String id) async {
    final response = await ApiService.authGet(BookingRoutes.appointmentById(id));
    return Appointment.fromJson(response as Map<String, dynamic>);
  }

  Map<String, dynamic> _extractCollectionPayload(Map<String, dynamic> response) {
    // Supports:
    // 1) { items, page, limit, total }
    // 2) { data: { items, page, limit, total } }
    // 3) { data: [...], meta: {...} }
    final nested = response['data'];
    if (nested is Map<String, dynamic> && nested['items'] is List) {
      return nested;
    }
    if (nested is List) {
      return {
        ...response,
        'items': nested,
      };
    }
    return response;
  }

  List<dynamic> _extractItemsDeep(dynamic node, [int depth = 0]) {
    if (depth > 6 || node == null) return const [];
    if (node is List) return node;
    if (node is! Map<String, dynamic>) return const [];

    const preferred = [
      'items',
      'doctors',
      'appointments',
      'results',
      'rows',
      'list',
      'data',
    ];

    for (final key in preferred) {
      final value = node[key];
      if (value is List) return value;
    }

    for (final value in node.values) {
      final found = _extractItemsDeep(value, depth + 1);
      if (found.isNotEmpty) return found;
    }
    return const [];
  }

  int? _readIntDeep(dynamic source, List<String> keys, [int depth = 0]) {
    if (depth > 6 || source == null) return null;
    if (source is! Map<String, dynamic>) return null;

    for (final key in keys) {
      final value = source[key];
      final parsed = _parseInt(value);
      if (parsed != null) return parsed;
    }

    for (final value in source.values) {
      final parsed = _readIntDeep(value, keys, depth + 1);
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
