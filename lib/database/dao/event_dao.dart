//import 'package:drift/drift.dart';
import 'package:photomall_studio_manager/database/dao/album_dao.dart';
import 'package:photomall_studio_manager/database/dao/photo_selection_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as app_db;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

//
// class EventModelDao {
//   AppDb database = AppDb();
//
//   Future<void> insertAllEvents(List<EventsCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.events, entity);
//     });
//   }
//
//   Future<List<Event>> getEventWhereStudioCode(String code,
//       {int offset = 0}) async {
//     int page =offset==0 ?1:(offset+10)~/10;
//     showLog("getEventWhereStudioCode page $page");
//     return await (database.select(database.events)
//           ..where((tbl) {
//             return tbl.studioCode.equals(code) & tbl.pageNumber.equals(page);
//           })
//           ..orderBy([
//             (t) =>
//                 OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
//           ])
//           ..limit(10, /*offset: offset*/))
//         .get();
//   }
//
//   Future<int> updateCreatedAtWhereEvent(
//       {required DateTime createdAt, required String eventCode,required int page}) async {
//     return (database.update(database.events)
//           ..where((tbl) {
//             return tbl.code.equals(eventCode);
//           }))
//         .write(EventsCompanion(createdAt: Value(createdAt),pageNumber: Value(page)));
//   }
//
//   Future<List<Event>> getEventBySearch({
//     required String code,
//     required String searchQuery,
//   }) async {
//     final query = database.select(database.events)
//       ..where((tbl) {
//         return ((tbl.name.like('%${searchQuery.trim()}%') &
//             tbl.studioCode.equals(code)));
//       });
//
//     return await query.get();
//   }
//
//   Future<Event?> getEventWhereCode(String code) async {
//     return await (database.select(database.events)
//           ..where((tbl) {
//             return tbl.code.equals(code);
//           })
//           ..limit(1))
//         .getSingleOrNull();
//   }
//
//   Future<void> deleteEvents() async {
//     await (database.delete(database.events)).go();
//   }
//
//   Future<void> deleteEventsWhereCode(String code) async {
//     PhotoSelectionDao photoSelectionDao = PhotoSelectionDao();
//     AlbumModelDao albumModelDao = AlbumModelDao();
//     await albumModelDao.deleteAlbum(code);
//     await photoSelectionDao.deletePhotoSelectionsWhereEventCode(code);
//
//     await (database.delete(database.events)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
// }

class EventModelDao {
  final Box<Events> box;

  EventModelDao(Store store) : box = store.box<Events>();

  // Insert or update events
  Future<void> insertAllEvents(List<Events> events,
      {PutMode mode = PutMode.put}) async {
    showLog("insertAllEvents:$events");
    box.putMany(events, mode: mode); // PutMode.put is default
  }

  Future<List<Events>> getEventWhereStudioCode(String code, {int offset = 0}) async {
    const int limit = 10; // items per page
    int page = offset == 0 ? 0 : (offset ~/ limit);

    final queryBuilder = box.query(
      Events_.studioCode.equals(code),
    )..order(Events_.createdAt, flags: Order.descending);

    final query = queryBuilder.build()
      ..limit = limit
      ..offset = page * limit;

    final results = query.find();
    query.close(); // Cleanup

    return results;
  }

  // Update createdAt and pageNumber by event code
  Future<void> updateCreatedAtWhereEvent({
    required DateTime createdAt,
    required String eventCode,
    required int page,
  }) async {
    final event = box.query(Events_.code.equals(eventCode)).build().findFirst();
    if (event != null) {
      event.createdAt = createdAt;
      event.pageNumber = page;
      box.put(event);
    }
  }

  // Search event by name and studioCode
  List<Events> getEventBySearch({
    required String code,
    required String searchQuery,
  }) {
    final query = box
        .query(
          Events_.code.equals(code) &
              Events_.name.contains(searchQuery, caseSensitive: false),
        )
        .build();

    return query.find();
  }

  // Get a single event by code
  Events? getEventWhereCode(String code) {
    return box.query(Events_.code.equals(code)).build().findFirst();
  }
  // Get a all events
  List<Events> getEvents() {
    return box.getAll();
  }

  // Delete all events
  void deleteEvents() {
    box.removeAll();
  }

  // Delete event and its related data
  Future<void> deleteEventsWhereCode(String code) async {
    // You may need to delete related data from their DAOs too
    final event = getEventWhereCode(code);
    if (event != null) {
      box.remove(event.id);
    }
  }
}
