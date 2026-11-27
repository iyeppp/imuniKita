import 'package:hive_ce/hive_ce.dart';

part 'sync_outbox_model.g.dart';

/// Operasi mutasi yang diantrekan saat offline untuk dikirim ke Firestore saat online.
@HiveType(typeId: 6)
class SyncOperationModel extends HiveObject {
  @HiveField(0)
  late String id;

  /// Jenis operasi: 'upsert' atau 'delete'.
  @HiveField(1)
  late String op;

  /// Path dokumen Firestore (mis. `users/{uid}/babies/{babyId}/growthRecords`).
  @HiveField(2)
  late String path;

  /// ID entitas target (`recordId`, `babyId`, `journalId`, `scheduleId`, dll.).
  @HiveField(3)
  late String entityId;

  /// Payload JSON (Map ter-encode JSON).
  @HiveField(4)
  late String payloadJson;

  /// Jumlah percobaan pengiriman.
  @HiveField(5)
  late int attempts;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  DateTime? lastAttemptAt;

  @HiveField(8)
  String? lastError;

  SyncOperationModel({
    required this.id,
    required this.op,
    required this.path,
    required this.entityId,
    required this.payloadJson,
    this.attempts = 0,
    required this.createdAt,
    this.lastAttemptAt,
    this.lastError,
  });

  SyncOperationModel copyWith({
    int? attempts,
    DateTime? lastAttemptAt,
    String? lastError,
  }) {
    return SyncOperationModel(
      id: id,
      op: op,
      path: path,
      entityId: entityId,
      payloadJson: payloadJson,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }
}
