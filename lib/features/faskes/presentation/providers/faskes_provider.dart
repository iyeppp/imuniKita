import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/dependency_injection.dart';
import '../../data/datasources/faskes_mock_datasource.dart';
import '../../data/datasources/faskes_remote_datasource.dart';
import '../../data/models/faskes_model.dart';

// ── Datasource (REST API + Cache + Mock Fallback) ─────────────────────────

/// Akses datasource faskes (B8-6, B8-7).
final faskesDatasourceProvider = Provider<FaskesRemoteDatasource>(
  (ref) => ref.watch(faskesRemoteDatasourceProvider),
);

// ── Filter ────────────────────────────────────────────────────────────────

/// Tipe faskes yang sedang aktif di chip filter.
/// Default: [FaskesTipe.semua] (tampilkan semua tipe).
final faskesTipeProvider = StateProvider<String>((ref) => FaskesTipe.semua);

// ── List (filtered by tipe) ───────────────────────────────────────────────

final faskesListAsyncProvider = FutureProvider<List<FaskesModel>>((ref) async {
  final tipe = ref.watch(faskesTipeProvider);
  return ref.watch(faskesDatasourceProvider).getByTipe(tipe);
});

/// Daftar faskes yang sudah difilter berdasarkan [faskesTipeProvider].
final faskesListProvider = Provider<List<FaskesModel>>((ref) {
  final asyncVal = ref.watch(faskesListAsyncProvider);
  return asyncVal.asData?.value ??
      const FaskesMockDatasource().getByTipe(ref.watch(faskesTipeProvider));
});
