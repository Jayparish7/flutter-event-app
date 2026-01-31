import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/database/dao/order_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart';

import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class NotificationsDao {
//
//   AppDb database = AppDb();
//
//   Future<void> insertNotifications(
//       List<NotificationTableCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(
//           database.notificationTable, entity);
//     });
//   }
//
//   Future<List<NotificationTableData>?> getNotificationsData() async {
//     return await (database.select(database.notificationTable)).get();
//   }
//
//   Future<int> updateReadStatusWhereId(
//       {required id}) async {
//     return await (database.update(database.notificationTable)
//           ..where((tbl) => tbl.id.equals(id)))
//         .write(const NotificationTableCompanion(
//               readStatus: drift.Value(true)));
//   }Future<int> updateConfirmationStatusWhereId(
//       {required id}) async {
//     return await (database.update(database.notificationTable)
//           ..where((tbl) => tbl.id.equals(id)))
//         .write(const NotificationTableCompanion(
//               confirmStatus: drift.Value(false)));
//   }
//
//   Future<int> updateUploadStateWhenCompleted(
//       {required String albumName,
//       required String uploadingName,
//       required int remainingFileCount}) async {
//     return await (database.update(database.uploadState)
//           ..where((tbl) => tbl.albumName.equals(albumName)))
//         .write(UploadStateCompanion(
//             uploadingImageName: drift.Value(uploadingName),
//             remainingFilesCount: drift.Value(remainingFileCount)));
//   }
//
//   Future<void> deleteNotificationTableData() async {
//     await (database.delete(database.notificationTable)).go();
//   }
//
//   Future<void> deleteUploadStatusById(int id) async {
//     await (database.delete(database.uploadState)
//           ..where((tbl) => tbl.id.equals(id)))
//         .go();
//   }
// }
class NotificationsDao {
  final Box<Notification>box;
  NotificationsDao(Store store):box=store.box<Notification>();

  // Insert or update a list of notifications (upsert)
  Future<void> insertNotifications(List<Notification> notifications) async {
    box.putMany(notifications);
  }
  

  // Get all notifications
  Future<List<Notification>> getNotificationsData() async {
    return box.getAll();
  }

  // Update readStatus to true by ID
  Future<void> updateReadStatusWhereId({required int id}) async {
    final notification = box.get(id);
    if (notification != null) {
      notification.readStatus = true;
      box.put(notification);
    }
  }

  // Update confirmStatus to false by ID
  Future<void> updateConfirmationStatusWhereId({required int id}) async {
    final notification = box.get(id);
    if (notification != null) {
      notification.confirmStatus = false;
      box.put(notification);
    }
  }

  // Delete all notifications
  Future<void> deleteNotificationTableData() async {
    box.removeAll();
  }


}
