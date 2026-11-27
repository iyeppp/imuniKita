import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../injection/dependency_injection.dart';
import 'data_migration.dart';

class MigrationDialog extends ConsumerStatefulWidget {
  const MigrationDialog({
    super.key,
    required this.uid,
    required this.summary,
  });

  final String uid;
  final MigrationSummary summary;

  static Future<bool> show({
    required BuildContext context,
    required String uid,
    required MigrationSummary summary,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MigrationDialog(uid: uid, summary: summary),
    );
    return result ?? false;
  }

  @override
  ConsumerState<MigrationDialog> createState() => _MigrationDialogState();
}

class _MigrationDialogState extends ConsumerState<MigrationDialog> {
  bool _isMigrating = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startMigration();
  }

  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _errorMessage = null;
    });

    try {
      final migration = ref.read(dataMigrationProvider);
      await migration.run(widget.uid);

      if (!mounted) return;
      setState(() {
        _isMigrating = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMigrating = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isSuccess
                  ? 'Migrasi Selesai!'
                  : (_errorMessage != null
                      ? 'Gagal Menyinkronkan'
                      : 'Menyiapkan Data…'),
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isMigrating) ...[
            const LinearProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Menyinkronkan ${widget.summary.totalRecords} catatan '
              '(${widget.summary.babyCount} profil anak) ke akun cloud Anda…',
              style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
            ),
          ] else if (_isSuccess) ...[
            const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 48),
            const SizedBox(height: 12),
            Text(
              'Seluruh data anak dan rekam medis berhasil tersinkron ke akun cloud Anda.',
              style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
            ),
          ] else if (_errorMessage != null) ...[
            Text(
              'Gagal menyinkronkan data ke cloud: $_errorMessage\n\n'
              'Data lokal Anda tetap tersimpan aman di perangkat ini.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_errorMessage != null) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: _startMigration,
            child: const Text('Coba Lagi'),
          ),
        ],
      ],
    );
  }
}
