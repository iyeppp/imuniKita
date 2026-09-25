import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../widgets/app_bottom_nav_bar.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/status_badge.dart';
import '../../data/datasources/faskes_mock_datasource.dart';
import '../../data/models/faskes_model.dart';
import '../providers/faskes_provider.dart';

// ── Konstanta tampilan ────────────────────────────────────────────────────

final _kJakartaCenter = LatLng(-6.2088, 106.8456);
const _kInitialZoom = 11.0;

// ── Entry Point ───────────────────────────────────────────────────────────

class FaskesScreen extends ConsumerStatefulWidget {
  const FaskesScreen({super.key});

  @override
  ConsumerState<FaskesScreen> createState() => _FaskesScreenState();
}

class _FaskesScreenState extends ConsumerState<FaskesScreen> {
  bool _showMap = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  List<FaskesModel> _applySearch(List<FaskesModel> all) {
    if (_searchQuery.isEmpty) return all;
    return all.where((f) {
      return f.nama.toLowerCase().contains(_searchQuery) ||
          f.kota.toLowerCase().contains(_searchQuery) ||
          f.alamat.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _openTel(String nomor) async {
    await _launch(
      Uri.parse('tel:$nomor'),
      gagal: 'Tidak dapat membuka aplikasi telepon.',
    );
  }

  Future<void> _openMaps(FaskesModel f) async {
    final geoUri = Uri.parse(
      'geo:${f.lat},${f.lng}?q=${Uri.encodeComponent(f.nama)}',
    );
    if (await _launch(geoUri, gagal: '')) return;

    // Fallback ke Google Maps web bila aplikasi peta tidak tersedia/terjangkau.
    await _launch(
      Uri.parse('https://maps.google.com/?q=${f.lat},${f.lng}'),
      gagal: 'Tidak dapat membuka tautan peta.',
      external: true,
    );
  }

  /// Buka [uri] lewat aplikasi eksternal.
  ///
  /// Mengembalikan `true` bila berhasil. `launchUrl` mengembalikan `false`
  /// (atau melempar `PlatformException`) bila tidak ada aplikasi yang bisa
  /// menangani URI — kegagalan itu kini dilaporkan lewat snackbar, tidak lagi
  /// senyap seperti pemakaian `canLaunchUrl` sebelumnya.
  Future<bool> _launch(
    Uri uri, {
    required String gagal,
    bool external = true,
  }) async {
    try {
      if (await launchUrl(
        uri,
        mode: external
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      )) {
        return true;
      }
    } catch (_) {
      // dilanjutkan ke pesan gagal di bawah
    }

    if (gagal.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(gagal)));
    }
    return false;
  }

  void _showDetail(FaskesModel faskes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FaskesDetailSheet(
        faskes: faskes,
        onTelTap: () => _openTel(faskes.telepon),
        onMapsTap: () => _openMaps(faskes),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Direktori Faskes',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.darkText,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _showMap ? 'Tampilan Daftar' : 'Tampilan Peta',
            icon: Icon(
              _showMap ? Icons.list_rounded : Icons.map_rounded,
              color: AppColors.teal,
            ),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: _showMap ? _buildMapView() : _buildListView(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  // ── Tab Daftar ────────────────────────────────────────────────────────

  Widget _buildListView() {
    final filtered = _applySearch(ref.watch(faskesListProvider));
    final activeTipe = ref.watch(faskesTipeProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText),
            decoration: InputDecoration(
              hintText: 'Cari nama faskes atau kota...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grey),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
              ),
            ),
          ),
        ),
        // Chip filter tipe
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: FaskesTipe.filter.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tipe = FaskesTipe.filter[index];
              final aktif = tipe == activeTipe;
              return FilterChip(
                label: Text(tipe),
                selected: aktif,
                onSelected: (_) =>
                    ref.read(faskesTipeProvider.notifier).state = tipe,
                selectedColor: AppColors.teal,
                checkmarkColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: aktif ? Colors.white : AppColors.darkText,
                  fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: aktif ? AppColors.teal : AppColors.divider,
                ),
                backgroundColor: AppColors.surface,
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // List kartu atau empty state
        Expanded(
          child: filtered.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'Tidak ada faskes ditemukan',
                  message: 'Coba ubah kata kunci atau pilih tipe yang lain.',
                  actionLabel: 'Reset Filter',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () {
                    ref.read(faskesTipeProvider.notifier).state =
                        FaskesTipe.semua;
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _FaskesCard(
                    faskes: filtered[index],
                    onTap: () => _showDetail(filtered[index]),
                    onTelTap: () => _openTel(filtered[index].telepon),
                    onMapsTap: () => _openMaps(filtered[index]),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Tab Peta ──────────────────────────────────────────────────────────

  Widget _buildMapView() {
    final allFaskes = ref.watch(faskesListProvider);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _kJakartaCenter,
        initialZoom: _kInitialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.imunikita.app',
        ),
        MarkerLayer(
          markers: allFaskes.map((f) {
            return Marker(
              point: LatLng(f.lat, f.lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDetail(f),
                child: Icon(
                  Icons.location_pin,
                  size: 36,
                  color: _markerColor(f.tipe),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _markerColor(String tipe) {
    switch (tipe) {
      case FaskesTipe.rs:
        return AppColors.teal;
      case FaskesTipe.puskesmas:
        return AppColors.green;
      case FaskesTipe.klinik:
        return AppColors.coral;
      case FaskesTipe.apotek:
        return AppColors.yellow;
      default:
        return AppColors.grey;
    }
  }
}

// ── Kartu Faskes ─────────────────────────────────────────────────────────

class _FaskesCard extends StatelessWidget {
  const _FaskesCard({
    required this.faskes,
    required this.onTap,
    required this.onTelTap,
    required this.onMapsTap,
  });

  final FaskesModel faskes;
  final VoidCallback onTap;
  final VoidCallback onTelTap;
  final VoidCallback onMapsTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.teal.withValues(alpha: 0.12),
              child: Icon(
                _ikonTipe(faskes.tipe),
                color: AppColors.teal,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + badge tipe
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          faskes.nama,
                          style: GoogleFonts.baloo2(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TipeBadge(tipe: faskes.tipe),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Alamat & kota
                  Text(
                    '${faskes.alamat}, ${faskes.kota}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Telepon
                  GestureDetector(
                    onTap: onTelTap,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          faskes.telepon,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.teal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tombol navigasi
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: onMapsTap,
                      icon: const Text('🗺️', style: TextStyle(fontSize: 13)),
                      label: Text(
                        'Navigasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: AppColors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _ikonTipe(String tipe) {
    switch (tipe) {
      case FaskesTipe.rs:
        return Icons.local_hospital_rounded;
      case FaskesTipe.puskesmas:
        return Icons.health_and_safety_rounded;
      case FaskesTipe.klinik:
        return Icons.medical_services_rounded;
      case FaskesTipe.apotek:
        return Icons.medication_rounded;
      default:
        return Icons.business_rounded;
    }
  }
}

// ── Badge tipe ───────────────────────────────────────────────────────────

class _TipeBadge extends StatelessWidget {
  const _TipeBadge({required this.tipe});

  final String tipe;

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor(tipe);
    return StatusBadge(
      label: tipe,
      color: color,
      compact: true,
      style: StatusBadgeStyle.soft,
    );
  }

  Color _badgeColor(String tipe) {
    switch (tipe) {
      case FaskesTipe.rs:
        return AppColors.teal;
      case FaskesTipe.puskesmas:
        return AppColors.green;
      case FaskesTipe.klinik:
        return AppColors.coral;
      case FaskesTipe.apotek:
        return AppColors.yellow;
      default:
        return AppColors.grey;
    }
  }
}

// ── Bottom Sheet Detail ───────────────────────────────────────────────────

class _FaskesDetailSheet extends StatelessWidget {
  const _FaskesDetailSheet({
    required this.faskes,
    required this.onTelTap,
    required this.onMapsTap,
  });

  final FaskesModel faskes;
  final VoidCallback onTelTap;
  final VoidCallback onMapsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nama + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    faskes.nama,
                    style: GoogleFonts.baloo2(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _TipeBadge(tipe: faskes.tipe),
              ],
            ),
            const SizedBox(height: 14),
            // Alamat
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: '${faskes.alamat}, ${faskes.kota}',
            ),
            const SizedBox(height: 10),
            // Telepon
            GestureDetector(
              onTap: onTelTap,
              child: _InfoRow(
                icon: Icons.phone_outlined,
                text: faskes.telepon,
                textColor: AppColors.teal,
                underline: true,
              ),
            ),
            const SizedBox(height: 10),
            // Jam operasional
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: faskes.jamOperasional,
            ),
            const SizedBox(height: 20),
            // Tombol buka maps
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onMapsTap,
                icon: const Text('🗺️', style: TextStyle(fontSize: 16)),
                label: Text(
                  'Buka di Maps',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.textColor,
    this.underline = false,
  });

  final IconData icon;
  final String text;
  final Color? textColor;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textColor ?? AppColors.textSecondary,
              decoration: underline ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────

// Empty state Faskes kini memakai `EmptyStateWidget` global (lib/widgets).
