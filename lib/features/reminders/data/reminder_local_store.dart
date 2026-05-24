import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:luminous/core/local_storage/app_database.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:sqflite/sqflite.dart';

/// 用药提醒本地缓存仓库。
///
/// 统一负责：
/// - `reminders` 表的读写；
/// - 页面层 / 会话同步层的缓存口径一致；
/// - 远端全量结果覆盖本地时不残留旧数据。
class ReminderLocalStore {
  /// 私有构造函数。
  ReminderLocalStore._();

  /// 全局单例入口。
  static final ReminderLocalStore instance = ReminderLocalStore._();

  /// Web 端本地缓存兜底（避免依赖 SQLite 工厂初始化）。
  final Map<String, List<ReminderPlan>> _webCache =
      <String, List<ReminderPlan>>{};

  /// 读取指定用户的本地提醒缓存。
  Future<List<ReminderPlan>> loadForUser(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return const [];
    }

    if (kIsWeb) {
      return List<ReminderPlan>.from(_webCache[uid] ?? const <ReminderPlan>[])
        ..sort((a, b) => a.time.compareTo(b.time));
    }

    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'reminders',
      where: 'userId = ?',
      whereArgs: [uid],
      orderBy: 'time ASC',
    );
    return rows.map(rowToPlan).toList();
  }

  /// 用完整结果覆盖指定用户的本地提醒缓存。
  ///
  /// 这样可以确保：
  /// - 远端删除的提醒不会继续残留在本地；
  /// - 页面离线回退时看到的是最后一次同步后的真实结果。
  Future<void> replaceForUser(String userId, List<ReminderPlan> items) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return;
    }

    if (kIsWeb) {
      _webCache[uid] = List<ReminderPlan>.from(items)
        ..sort((a, b) => a.time.compareTo(b.time));
      return;
    }

    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete('reminders', where: 'userId = ?', whereArgs: [uid]);
      for (final item in items) {
        if (item.id.trim().isEmpty) {
          continue;
        }
        await txn.insert(
          'reminders',
          toLocalRow(uid, item, updatedAt: now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 把数据库行转换为提醒计划对象。
  ReminderPlan rowToPlan(Map<String, dynamic> row) {
    final medicines = _decodeMedicines(
      row['medicinesJson'],
      fallbackDrugCode: (row['drugCode'] ?? '').toString(),
      fallbackApprovalNo: (row['approvalNo'] ?? '').toString(),
      fallbackProductName: (row['productName'] ?? '').toString(),
    );

    return ReminderPlan(
      id: (row['remoteId'] ?? '').toString(),
      userId: (row['userId'] ?? '').toString(),
      time: (row['time'] ?? '').toString(),
      drugCode: (row['drugCode'] ?? '').toString(),
      approvalNo: (row['approvalNo'] ?? '').toString(),
      productName: (row['productName'] ?? '').toString(),
      medicines: medicines,
      dosage: (row['dosage'] ?? '').toString(),
      subtitle: (row['subtitle'] ?? '').toString(),
      enabled: (row['enabled'] ?? 1) == 1,
      repeatRule: (row['repeatRule'] ?? 'daily').toString(),
      method: (row['method'] ?? 'notification').toString(),
      startDate: (row['startDate'] ?? '').toString(),
      endDate: (row['endDate'] ?? '').toString(),
    );
  }

  /// 把提醒计划对象转换为 `reminders` 表写入数据。
  Map<String, dynamic> toLocalRow(
    String userId,
    ReminderPlan item, {
    required int updatedAt,
  }) {
    return {
      'remoteId': item.id,
      'userId': userId.trim(),
      'time': item.time,
      'drugCode': item.drugCode,
      'approvalNo': item.approvalNo,
      'productName': item.productName,
      'medicinesJson': jsonEncode(
        item.medicines.map((medicine) => medicine.toJson()).toList(),
      ),
      'dosage': item.dosage,
      'subtitle': item.subtitle,
      'enabled': item.enabled ? 1 : 0,
      'repeatRule': item.repeatRule,
      'method': item.method,
      'startDate': item.startDate,
      'endDate': item.endDate,
      'updatedAt': updatedAt,
    };
  }

  List<ReminderMedicineRef> _decodeMedicines(
    dynamic raw, {
    required String fallbackDrugCode,
    required String fallbackApprovalNo,
    required String fallbackProductName,
  }) {
    final medicines = <ReminderMedicineRef>[];
    final text = (raw ?? '').toString().trim();
    if (text.isNotEmpty) {
      try {
        final parsed = jsonDecode(text);
        if (parsed is List) {
          for (final item in parsed) {
            if (item is! Map) {
              continue;
            }
            final medicine = ReminderMedicineRef.fromJson(
              item.cast<String, dynamic>(),
            );
            if (medicine.productName.trim().isEmpty) {
              continue;
            }
            medicines.add(medicine);
          }
        }
      } catch (_) {}
    }

    if (medicines.isNotEmpty) {
      return medicines;
    }

    final fallbackName = fallbackProductName.trim();
    if (fallbackName.isEmpty) {
      return const [];
    }
    return <ReminderMedicineRef>[
      ReminderMedicineRef(
        drugCode: fallbackDrugCode.trim(),
        approvalNo: fallbackApprovalNo.trim(),
        productName: fallbackName,
      ),
    ];
  }
}

/// 对外暴露的全局提醒本地缓存仓库实例。
final reminderLocalStore = ReminderLocalStore.instance;
