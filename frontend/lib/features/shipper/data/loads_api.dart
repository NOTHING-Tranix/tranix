import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/interceptors.dart';
import '../../../core/providers.dart';
import '../../../shared/models/models.dart';

/// Contract §6 (shipper side).
class LoadsApi {
  LoadsApi(this._dio);

  final Dio _dio;

  Future<LoadEstimate> estimate({required GeoPoint pickup, required GeoPoint drop, required DateTime start}) async {
    final res = await guardApi(() => _dio.post<Map<String, dynamic>>('/loads/estimate', data: {
          'pickup': pickup.toJson(),
          'drop': drop.toJson(),
          'pickupWindowStart': start.toUtc().toIso8601String(),
        }));
    return LoadEstimate.fromJson(res.data!);
  }

  Future<LoadDetail> create(LoadCreate load) async =>
      LoadDetail.fromJson((await guardApi(() => _dio.post<Map<String, dynamic>>('/loads', data: load.toJson()))).data!);

  Future<LoadDetail> update(String id, LoadCreate load) async =>
      LoadDetail.fromJson((await guardApi(() => _dio.put<Map<String, dynamic>>('/loads/$id', data: load.toJson()))).data!);

  Future<Paged<LoadSummary>> list({required bool ongoing, String? farmerId, int page = 0}) async {
    final res = await guardApi(() => _dio.get<Map<String, dynamic>>('/loads', queryParameters: {
          'scope': ongoing ? 'ONGOING' : 'HISTORY',
          'farmerId': ?farmerId,
          'page': page,
        }));
    return Paged.fromJson(res.data!, LoadSummary.fromJson);
  }

  Future<LoadDetail> detail(String id) async =>
      LoadDetail.fromJson((await guardApi(() => _dio.get<Map<String, dynamic>>('/loads/$id'))).data!);

  Future<LoadDetail> cancel(String id, String reason, String? note) async => LoadDetail.fromJson(
        (await guardApi(() => _dio.post<Map<String, dynamic>>('/loads/$id/cancel', data: {'reason': reason, 'note': ?note})))
            .data!,
      );

  Future<LoadDetail> repost(String id) async =>
      LoadDetail.fromJson((await guardApi(() => _dio.post<Map<String, dynamic>>('/loads/$id/repost'))).data!);
}

final loadsApiProvider = Provider<LoadsApi>((ref) => LoadsApi(ref.watch(dioProvider)));

final loadListProvider = FutureProvider.autoDispose.family<Paged<LoadSummary>, bool>(
  (ref, ongoing) => ref.watch(loadsApiProvider).list(ongoing: ongoing),
);

final loadDetailProvider = FutureProvider.autoDispose.family<LoadDetail, String>(
  (ref, id) => ref.watch(loadsApiProvider).detail(id),
);
