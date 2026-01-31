import 'package:photomall_studio_manager/controllers/transporter_controller.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart';

import '../../objectbox.g.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../../routes/1.constants/common_constants.dart';
import '../object_box_model/object_box_models.dart';

// class TransporterDao {
//   AppDb database = AppDb();
//
//   Future<List<TransportDataData>?>
//       getEventTransporterWhereDataAvailable() async {
//     return await (database.select(database.transportData)
//           ..where((tbl) {
//             return tbl.data.isNotNull();
//           }))
//         .get();
//   }
//
//   Future<void> insertAllNewTransporter(
//       List<TransportDataCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.transportData, entity);
//     });
//     TransporterController transporterController = TransporterController();
//     int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
//     showLog('studioIndex transporter call is $studioIndex');
//     await transporterController.callTransporterApi(studioIndex);
//   }
//
//   Future<List<TransportDataData>>
//       getEventTransporterWhereUpdateRequiredOne() async {
//     return await (database.select(database.transportData)
//           ..where((tbl) {
//             return tbl.updateRequired.equals(1);
//           }))
//         .get();
//   }
//
//   Future<void> deleteTransporterWhereCode(String code) async {
//     await (database.delete(database.transportData)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
//
//   Future<void> deleteTransporter() async {
//     await (database.delete(database.transportData)).go();
//   }
// }
class TransporterDao {
final Box<TransportData>box;
TransporterDao(Store store):box=store.box<TransportData>();

Future<List<TransportData>> getEventTransporterWhereDataAvailable() async {
  return box.query(TransportData_.data.notNull()).build().find();
}
  Future<void> insertAllNewTransporter(
      List<TransportData> entities) async {
    List<TransportData> toPut = [];

    for (final entity in entities) {
      // Check if object with same code exists
      final existing = box.query(TransportData_.code.equals(entity.code)).build().findFirst();

      if (existing != null) {
        // Update existing object's fields except id
        existing.tag = entity.tag;
        existing.lastUpdatedAt = entity.lastUpdatedAt;
        existing.updateRequired = entity.updateRequired;
        existing.data = entity.data;
        existing.role = entity.role;
        toPut.add(existing);
      } else {
        // New object, add as is (id should be 0 or not set)
        toPut.add(entity);
      }
    }

    // Now insert/update merged list
    box.putMany(toPut);
    TransporterController transporterController = TransporterController();
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex transporter call is $studioIndex');
    await transporterController.callTransporterApi(studioIndex);
  }

Future<List<TransportData>> getEventTransporterWhereUpdateRequiredOne() async {
  return box.query(TransportData_.updateRequired.equals(1)).build().find();
}
Future<void> deleteTransporterWhereCode(String code) async {
  final query = box.query(TransportData_.code.equals(code)).build();
  final itemsToDelete = query.find();
  box.removeMany(itemsToDelete.map((e) => e.id).toList());
  query.close();
}

Future<void> deleteTransporter() async {
  box.removeAll();
}
}
