import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/faskes_mock_datasource.dart';
import '../../data/models/faskes_model.dart';

// ── Datasource ────────────────────────────────────────────────────────────

/// Akses datasource faskes. Fase UAS: ganti isi provider ini dengan
/// implementasi API tanpa menyentuh screen.
final faskesDatasourceProvider = Provider<FaskesMockDatasource>(
  (ref) => const FaskesMockDatasource(),
);

// ── Filter ────────────────────────────────────────────────────────────────

/// Tipe faskes yang sedang aktif di chip filter.
/// Default: [FaskesTipe.semua] (tampilkan semua tipe).
final faskesTipeProvider = StateProvider<String>((ref) => FaskesTipe.semua);

// ── List (filtered by tipe) ───────────────────────────────────────────────

/// Daftar faskes yang sudah difilter berdasarkan [faskesTipeProvider].
///
/// Filter teks pencarian (search query) ditangani di level widget karena
/// bersifat local UI state, bukan shared state.
final faskesListProvider = Provider<List<FaskesModel>>((ref) {
  final tipe = ref.watch(faskesTipeProvider);
  return ref.watch(faskesDatasourceProvider).getByTipe(tipe);
});
