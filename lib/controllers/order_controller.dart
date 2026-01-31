import 'package:photomall_studio_manager/api/apiRequestModels/digital_oceans_space_service.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/album_show_responce.dart';
import 'package:photomall_studio_manager/database/object_box_model/object_box_models.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../main.dart';

class OrderController {
  DigitalOceanSpacesService service =DigitalOceanSpacesService(originalFilePath: "photomall");
  upsertOrder(
      {required String albumCode,required String eventCode,  AlbumShowResponse? albumShowResponse}) async {
    List<String> apiOrders = [];
    if (albumShowResponse?.data != null) {
      for (Order order in albumShowResponse!.data!.orders!) {
        apiOrders.add(order.code!);
      }
      List<String> existingOrders = [];
      if (apiOrders.isNotEmpty) {
        List create = []; // insert this event
        List delete = []; // delete this event
        List update = []; // change update required as true
        /// get local
        final orderModelDao = objectBox.orderModelDao;
        List<OrderImage>? imagesAtDB =
              orderModelDao.getImagesWhereAlbumCode(albumCode);
        if (imagesAtDB != null && imagesAtDB.isNotEmpty) {
          for (var order in imagesAtDB) {
            existingOrders.add(order.code ?? '');
          }
        }
        for (int i = 0; i < apiOrders.length; i++) {
          if (existingOrders.contains(apiOrders[i])) {
            update.add(apiOrders[i]);
          }
          if (!existingOrders.contains(apiOrders[i])) {
            create.add(apiOrders[i]);
          }
        }
        for (int i = 0; i < existingOrders.length; i++) {
          if (!apiOrders.contains(existingOrders[i])) {
            delete.add(existingOrders[i]);
          }
        }

        /// INSERT New

        if (create.isNotEmpty) {
          List<OrderImage> newOrdersEntity = [];
          for (int i = 0; i < create.length; i++) {
            Order? newOrder = albumShowResponse.data!.orders!
                .where((obj) => obj.code == create[i])
                .toList()
                .first;

            newOrdersEntity.add(OrderImage(
              code: newOrder.code,
              eventCode: eventCode,
              albumCode:albumCode,
              uploaded: true,
              uploadStatus: 0,
              name: newOrder.originalFileName,
              path:"",
                compressionStatus:  0,
              sha256:  service.generateUniqueId()
            ));
          }
          if (newOrdersEntity.isNotEmpty) {
            await orderModelDao.insertAllOrders(newOrdersEntity);
          }
        }

        /// UPDATE Existing

        if (update.isNotEmpty) {
          List< OrderImage> updateAlbumEntity = [];
          for (int i = 0; i < update.length; i++) {
            Order? updateOrder = albumShowResponse.data!.orders!
                .where((obj) => obj.code == update[i])
                .toList()
                .first;
            OrderImage order = imagesAtDB!
                .where((element) => element.code == updateOrder.code)
                .toList()
                .first;
            updateAlbumEntity.add(OrderImage(
              uploadStatus: 0,

              id: order.id,
              code: updateOrder.code,
              eventCode: eventCode,
              albumCode: albumCode,
              uploaded: true,
              name: updateOrder.originalFileName,
              path:order.path,
              sha256: order.sha256,
              compressionStatus: 0,
            ));
            showLog("Photo selection images update :: ");
          }
          if (updateAlbumEntity.isNotEmpty) {
            await orderModelDao.insertAllOrders(updateAlbumEntity);
          }
        }

        /// DELETE
        if (delete.isNotEmpty) {
          for (int i = 0; i < delete.length; i++) {
            await orderModelDao.deleteOrderWhereCode(delete[i]);
          }
        }
      }
    }

    String? getImageName() {
      return null;
    }
  }
}
