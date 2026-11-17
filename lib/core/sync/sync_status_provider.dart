import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../injection/dependency_injection.dart';
import '../network/network_info.dart';

enum SyncStatus {
  synced,
  syncing,
  pendingOffline,
  offline,
}

class SyncStatusData {
  const SyncStatusData({
    required this.isOnline,
    required this.pendingCount,
    this.isSyncing = false,
  });

  final bool isOnline;
  final int pendingCount;
  final bool isSyncing;

  SyncStatus get status {
    if (!isOnline) {
      return pendingCount > 0 ? SyncStatus.pendingOffline : SyncStatus.offline;
    }
    if (isSyncing) {
      return SyncStatus.syncing;
    }
    return pendingCount > 0 ? SyncStatus.pendingOffline : SyncStatus.synced;
  }

  String get label {
    switch (status) {
      case SyncStatus.synced:
        return 'Tersinkron';
      case SyncStatus.syncing:
        return 'Menyinkronkan…';
      case SyncStatus.pendingOffline:
        return '$pendingCount Menunggu koneksi';
      case SyncStatus.offline:
        return 'Mode Offline';
    }
  }
}

final syncStatusProvider = StreamProvider<SyncStatusData>((ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  final syncQueue = ref.watch(syncQueueProvider);

  bool isOnline = await networkInfo.isConnected;
  int pending = await syncQueue.pendingCount;

  yield SyncStatusData(isOnline: isOnline, pendingCount: pending);

  await for (final online in networkInfo.onConnectivityChanged) {
    isOnline = online;
    pending = await syncQueue.pendingCount;
    yield SyncStatusData(isOnline: isOnline, pendingCount: pending);
  }
});
