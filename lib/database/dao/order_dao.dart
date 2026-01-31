import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:objectbox/objectbox.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as app_db;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../objectbox.g.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../object_box_model/object_box_models.dart';

// class OrderModelDao {
//   AppDb database = AppDb();
//
//   Future<void> insertAllOrders(List<OrdersCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.orders, entity);
//     });
//   }
//
//   Future<void> deleteOrdersWhereAlbumCode(String albumCode) async {
//     await (database.delete(database.orders)
//           ..where((tbl) => tbl.albumCode.equals(albumCode)))
//         .go();
//   }
//
//   Future<void> deleteOrderWhereCode(String code) async {
//     await (database.delete(database.orders)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
//
//   Future<void> deleteOrderWhereId(int id) async {
//     await (database.delete(database.orders)..where((tbl) => tbl.id.equals(id)))
//         .go();
//   }
//
//   Future<void> deleteOrderWherePath(String path) async {
//     await (database.delete(database.orders)
//           ..where((tbl) => tbl.path.equals(path)))
//         .go();
//   }
//
//   Stream<List<Order>> streamImagesWhereAlbumCode(String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.albumCode.equals(albumCode));
//           }))
//         .watch();
//   }
//
//   Future<List<Order>?> getImagesWhereAlbumCodeWhereNotUploaded(
//       String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.albumCode.equals(albumCode)) &
//                 (tbl.uploaded.equals(false));
//           })
//           ..orderBy([(tbl) => drift.OrderingTerm(expression: tbl.name)]))
//         .get();
//   }
//
//
//
//   Future<List<Order>?> getImagesWhereAlbumCodeWhereUploaded(String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.albumCode.equals(albumCode)) &
//                 (tbl.uploaded.equals(true));
//           }))
//         .get();
//   }
//
//   Future<List<Order>?> getImagesWhereEventCodeWhereNotCompressed(
//       String eventCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.eventCode.equals(eventCode)) &
//                 (tbl.compressionStatus.equals(0) & tbl.uploaded.equals(false) |
//                     tbl.compressionStatus.equals(4) &
//                         tbl.uploaded.equals(false) |
//                     tbl.compressionStatus.equals(3) &
//                         tbl.uploaded.equals(false) |
//                     tbl.compressionStatus.equals(1) &
//                         tbl.uploaded.equals(false));
//           }))
//         .get();
//   }
//
//   Future<List<Order>?> getImagesWhereEventCodeWhereNotUploaded(
//       String eventCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.eventCode.equals(eventCode)) &
//                 (tbl.uploaded.equals(false));
//           }))
//         .get();
//   }
//
//   Future<List<Order>?> getImagesWhereAlbumCode(String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.albumCode.equals(albumCode));
//           }))
//         .get();
//   }
//
//   Future<List<UploadDetails>> getEventName(String albumCode) async {
//     // Prepare the query with necessary joins
//     var query = database.select(database.orders).join([
//       // Inner join between orders and albums
//       drift.innerJoin(
//         database.albums,
//         database.albums.code.equalsExp(database.orders.albumCode),
//       ),
//       // Inner join between albums and events
//       drift.innerJoin(
//         database.events,
//         database.events.code.equalsExp(database.albums.eventCode),
//       ),
//     ])
//       ..where(database.orders.albumCode.equals(albumCode))
//       ..limit(1); // Filter by albumCode
//
//     // Map the result to extract order, album, and event names
//     final result = await query.map((row) {
//       final order =
//           row.readTable(database.orders); // Read from the orders table
//       final album =
//           row.readTable(database.albums); // Read from the albums table
//       final event =
//           row.readTable(database.events); // Read from the events table
//
//       return UploadDetails(albumName: album.name!, eventName: event.name);
//     }).get(); // Execute the query and return the result
//
//     return result;
//   }
//
//
//
//   Stream<List<Order>> streamImageNamesWhereUploadedAndAlbumCode(
//       String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return tbl.albumCode.equals(albumCode) & tbl.uploaded.equals(true);
//           }))
//         .watch();
//   }
//
//   Future<List<Order>> imagesWhereUploadedAndAlbumCode(String albumCode) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return tbl.albumCode.equals(albumCode) & tbl.uploaded.equals(true);
//           }))
//         .get();
//   }
//
//   Future<Order?> getImageWhereSha256(String sha256) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.sha256.equals(sha256));
//           }))
//         .getSingleOrNull();
//   }
//
//   Future<Order?> getImageWhereId(int id) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.id.equals(id));
//           }))
//         .getSingleOrNull();
//   }
//
//   Future<Order?> getImageWhereSha256ForScreenDisplay2(String sha256) {
//     return (database.select(database.orders)
//           ..where((tbl) {
//             return (tbl.screenDisplay2ImageUrl.equals(sha256));
//           }))
//         .getSingleOrNull();
//   }
//
//
//
//
//   Future<void> updateImageUploadedStatusTrue(int id, String? code, String path,
//       {int from = 0}) async {
//     showLog("updateImageUploadedStatusTrue id  >> $path $from");
//     await (database.update(database.orders)..where((tbl) => tbl.id.equals(id)))
//         .write(OrdersCompanion(
//             uploaded: const drift.Value(true),
//             code: drift.Value(code),
//             path: drift.Value(path)));
//   }
//
//   Future<void> updateImageFileCode(
//     int id,
//     String? code,
//   ) async {
//     showLog("updating id  >> $id");
//     await (database.update(database.orders)..where((tbl) => tbl.id.equals(id)))
//         .write(OrdersCompanion(
//       code: drift.Value(code),
//     ));
//   }
//
//   Future<void> updateImageRatio(String ratio, String path) async {
//     showLog("updateImageRatio >> $ratio");
//     await (database.update(database.orders)
//           ..where((tbl) => tbl.path.equals(path)))
//         .write(OrdersCompanion(
//       ratio: drift.Value(ratio),
//     ));
//   }
//
//   Future<void> updateImageCompressionStatus(int status, int id) async {
//     showLog("updateImageRatio >>");
//     await (database.update(database.orders)..where((tbl) => tbl.id.equals(id)))
//         .write(OrdersCompanion(
//       compressionStatus: drift.Value(status),
//     ));
//   }
//
//   Future<void> updateImageMd5Hash(
//       {required String md5Hash,
//       required String sha256,
//       required String presignedUrlCode}) async {
//     showLog("updateImageMd5Hash >> $md5Hash $sha256");
//     await (database.update(database.orders)
//           ..where((tbl) => tbl.sha256.equals(sha256)))
//         .write(OrdersCompanion(
//       md5hash: drift.Value(md5Hash),
//       preSignedURlCode: drift.Value(presignedUrlCode),
//     ));
//   }
//
//   Future<void> updateImageMd5HashForScreenDisplay2(
//       {required String md5Hash,
//       required String sha256,
//       required String presignedUrlCode}) async {
//     showLog("updateImageMd5HashForScreenDisplay2 >> $md5Hash $sha256");
//     await (database.update(database.orders)
//           ..where((tbl) => tbl.screenDisplay2ImageUrl.equals(sha256)))
//         .write(OrdersCompanion(
//       screenDisplay2Md5hash: drift.Value(md5Hash),
//       screenDisplay2PreSignedURlCode: drift.Value(presignedUrlCode),
//     ));
//   }
// }
class OrderModelDao {
  final Box<OrderImage> box;

  OrderModelDao(Store store) : box = store.box<OrderImage>();

  Future<void> insertAllOrders(List<OrderImage> orders) async {
    box.putMany(orders);
  }

  Future<void> deleteOrdersWhereAlbumCode(String albumCode) async {
    final query = box.query(OrderImage_.albumCode.equals(albumCode)).build();
    box.removeMany(query.findIds());
    query.close();
  }

  Future<void> deleteOrderWhereCode(String code) async {
    final query = box.query(OrderImage_.code.equals(code)).build();
    box.removeMany(query.findIds());
    query.close();
  }

  /// Delete order by ID
  void deleteOrderWhereId(int id) {
    box.remove(id);
  }

  /// Delete order by path
  void deleteOrderWherePath(String path) {
    final query = box.query(OrderImage_.path.equals(path)).build();
    box.removeMany(query.findIds());
    query.close();
  }

  /// Stream orders by albumCode (reactive query)
  Stream<List<OrderImage>> streamImagesWhereAlbumCode(String albumCode) {
    final query = box.query(OrderImage_.albumCode.equals(albumCode));
    return query.watch(triggerImmediately: true).map((q) => q.find());
  }

  Stream<List<OrderImage>> streamImageNamesWhereUploadedAndAlbumCode(
      String albumCode) {
    final query = box.query(
      OrderImage_.albumCode.equals(albumCode) &
          OrderImage_.uploaded.equals(true),
    );

    return query.watch(triggerImmediately: true).map((q) => q.find());
  }  Stream<List<OrderImage>> streamImagesWhereCompressedAndAlbumCode(
      String albumCode) {
    final query = box.query(
      OrderImage_.albumCode.equals(albumCode) &
          OrderImage_.compressionStatus.equals(1),
    );

    return query.watch(triggerImmediately: true).map((q) => q.find());
  }

  /// Get orders by albumCode where uploaded == false
  List<OrderImage> getImagesWhereAlbumCodeWhereNotUploaded(String albumCode) {
    final query = box
        .query(OrderImage_.albumCode.equals(albumCode) &
            OrderImage_.uploaded.equals(false))
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  List<OrderImage> getImagesNotUploaded() {
    final query = box
        .query(OrderImage_.uploaded.equals(false) &
            OrderImage_.screenDisplay2imageBytes.notNull())
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  /// Get orders by albumCode where uploaded == true
  List<OrderImage> getImagesWhereAlbumCodeWhereUploaded(String albumCode) {
    final query = box
        .query(OrderImage_.albumCode.equals(albumCode) &
            OrderImage_.uploaded.equals(true))
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  /// Get orders by eventCode where compressionStatus in (0,1,3,4) and uploaded == false
  List<OrderImage> getImagesWhereEventCodeWhereNotCompressed(String eventCode) {
    final query = box
        .query(
          OrderImage_.eventCode.equals(eventCode) &
              (OrderImage_.compressionStatus.equals(0) |
                  OrderImage_.compressionStatus.equals(1) |
                  OrderImage_.compressionStatus.equals(2) |
                  OrderImage_.compressionStatus.equals(3) |
                  OrderImage_.compressionStatus.equals(4)) &
              OrderImage_.uploaded.equals(false),
        )
        .build();

    final result = query.find();
    query.close();
    return result;
  }

  /// Get order where compressionStatus in (0,4) and uploaded == false
  List<OrderImage>? getAndReserveImageForCompression({int offset = 0}) {
    final query = box
        .query(((OrderImage_.compressionStatus.equals(0) |
                OrderImage_.compressionStatus.equals(1) |
                OrderImage_.compressionStatus.equals(4)) &
            OrderImage_.uploaded.equals(false)))
        .build();

    final results = query.find();
    query.close();

    if (results.isNotEmpty) {
      final image = results;

      // Atomically reserve this image

      return image;
    }

    return null;
  }

  /// Get one image that is not uploaded and not yet being uploaded
  List<OrderImage>? getImageForUpload() {
    final query = box
        .query(OrderImage_.imageBytes.notNull() &
            OrderImage_.uploaded.equals(false) &
            (OrderImage_.uploadStatus.equals(0) |
                OrderImage_.uploadStatus.isNull()))
        .build();

    final results = query.find();
    query.close();

    if (results.isNotEmpty) {
      final image = results;

      // Mark image as in-progress to prevent race conditions
      //image.compressionStatus = 1;
      //  image.uploadStatus = 1;
      // box.put(image);

      return image;
    }

    return null;
  }

  /// Get one image that is not uploaded and not yet being uploaded
  List<OrderImage>? getImageForUploadForScreenDisplay2() {
    final query = box
        .query(OrderImage_.screenDisplay2imageBytes.notNull() &
            OrderImage_.code.notNull() &
            OrderImage_.uploaded.equals(false))
        .build();

    final results = query.find();
    query.close();

    if (results.isNotEmpty) {
      final image = results;

      // Mark image as in-progress to prevent race conditions
      //image.compressionStatus = 1;
      //image.uploadStatus = 2;
      //box.put(image);

      return image;
    }

    return null;
  }

  /// Get orders by eventCode where uploaded == false
  Future<List<OrderImage>> getImagesWhereEventCodeWhereNotCompress() async {
    int speedStatus = await PreferenceHelper.getInt(uploadSpeedPreferenceKey);
    showLog("loadSpeed $speedStatus");
    final query = box.query(OrderImage_.compressionStatus.equals(0)).build()
      ..limit = speedStatus != 0 ? speedStatus : 3;
    final result = query.find();
    query.close();
    return result;
  }

  /// Get orders by eventCode where uploaded == false
  Future<List<OrderImage>> getImagesWhereEventCodeWhereNotUploaded() async {
    int speedStatus = await PreferenceHelper.getInt(uploadSpeedPreferenceKey);
    showLog("loadSpeed $speedStatus");
    final query = box
        .query(OrderImage_.compressionStatus.equals(1) &
            OrderImage_.uploaded.equals(false))
        .build()
      ..limit = speedStatus != 0 ? speedStatus : 3;
    final result = query.find();
    query.close();
    return result;
  }

  /// Get orders by eventCode where uploaded == false
  List<OrderImage> getImagesCountWhereEventCodeWhereNotUploaded(
      String eventCode) {
    final query = box
        .query(OrderImage_.eventCode.equals(eventCode) &
            OrderImage_.uploaded.equals(false))
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  /// Get orders by eventCode where uploaded == false
  List<OrderImage> getImagesWhereEventCodeWhereUploaded(String eventCode) {
    final query = box.query(OrderImage_.eventCode.equals(eventCode)).build();
    final result = query.find();
    query.close();
    return result;
  }

  List<OrderImage> getImagesWhereAlbumCode(String albumCode) {
    final query = box.query(OrderImage_.albumCode.equals(albumCode)).build();
    final result = query.find();
    query.close();
    return result;
  }

  List<OrderImage> imagesWhereUploadedAndAlbumCode(String albumCode) {
    final query = box
        .query(OrderImage_.albumCode.equals(albumCode) &
            OrderImage_.uploaded.equals(true))
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  /// Get order by sha256 hash
  OrderImage? getImageWhereSha256(String sha256) {
    final query = box.query(OrderImage_.sha256.equals(sha256)).build();
    final order = query.findFirst();
    query.close();
    return order;
  }

  /// Get order by id
  OrderImage? getImageWhereId(int id) {
    return box.get(id);
  }

  OrderImage? getImageWhereSha256ForScreenDisplay2(String sha256) {
    final query =
        box.query(OrderImage_.screenDisplay2ImageUrl.equals(sha256)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Update uploaded status to true for order with id, also update code and path
  updateImageUploadedStatusTrue(int id, int uploadsStatus,
      {String? code, String? path}) {
    final order = box.get(id);
    showLog("updateImageUploadedStatusTrue : $order");
    if (order != null) {
      order.uploaded = true;
      if (code != null) order.code = code;
      if (path != null) order.path = path;
      order.uploadStatus = uploadsStatus;
      box.put(order);
    }
  }

  void updateImageFileCode(int id, String? code) {
    showLog("updating id  >> $id");

    final image = box.get(id);
    if (image != null) {
      image.code = code;
      box.put(image); // This updates the record
    }
  }

  void updateImageBytes(int id, Uint8List? bytes, String ratio) {
    showLog(
        "compressAndSave exit updateImageBytes updating id  >> $id ${bytes?.length}");

    final image = box.get(id);
    if (image != null) {
      image.imageBytes = bytes;
      image.ratio = ratio;
      box.put(image); // This updates the record
    }
  }

  void updateImageBytesForScreenDisplay2(
      int id, Uint8List? bytes, String ratio) {
    showLog(
        "updateImageBytesForScreenDisplay2 updating id  >> $id ${bytes?.length}");

    final image = box.get(id);
    if (image != null) {
      image.screenDisplay2imageBytes = bytes;
      image.screenDisplay2ratio = ratio;

      box.put(image); // This updates the record
    }
  }

  void clearImageBytes(int id) {
    final image = box.get(id);
    if (image != null) {
      image.imageBytes = null;
      box.put(image); // Save the update to ObjectBox
      showLog("Cleared imageBytes and ratio for image id >> $id");
    } else {
      showLog("Image not found for id >> $id");
    }
  }

  void clearImageBytesForScreenDisplay2(int id) {
    final image = box.get(id);
    if (image != null) {
      image.screenDisplay2imageBytes = null;
      box.put(image); // Save the update to ObjectBox
      showLog("Cleared imageBytes and ratio for image id >> $id");
    } else {
      showLog("Image not found for id >> $id");
    }
  }

  /// Update ratio for order(s) by path
  void updateImageRatio(String ratio, String path) {
    final query = box.query(OrderImage_.path.equals(path)).build();
    final orders = query.find();
    for (var order in orders) {
      order.ratio = ratio;
    }
    box.putMany(orders);
    query.close();
  }

  void updateImageCompressionStatus(int status, int id, String ratio) {
    showLog("updateImageCompressionStatus $id");
    final image = box.get(id);
    if (image != null) {
      image.compressionStatus = status;
      image.ratio = ratio;
      box.put(image);
    }
  }

  void updateImageMd5Hash({
    required String md5Hash,
    required String sha256,
    required String presignedUrlCode,
  }) {
    final image =
        box.query(OrderImage_.sha256.equals(sha256)).build().findFirst();
    if (image != null) {
      image.md5hash = md5Hash;
      image.preSignedURlCode = presignedUrlCode;
      box.put(image);
    }
  }

  void updateImageMd5HashForScreenDisplay2({
    required String md5Hash,
    required String sha256,
    required String presignedUrlCode,
  }) {
    final image = box
        .query(OrderImage_.screenDisplay2ImageUrl.equals(sha256))
        .build()
        .findFirst();
    if (image != null) {
      image.screenDisplay2Md5hash = md5Hash;
      image.screenDisplay2PreSignedURlCode = presignedUrlCode;
      box.put(image);
    }
  }
}

class UploadDetails {
  final String albumName;
  final String eventName;

  UploadDetails({required this.albumName, required this.eventName});
}
