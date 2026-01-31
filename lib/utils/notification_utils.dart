import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photomall_studio_manager/api/apiRequestModels/add_event_request_model.dart'
    as request;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/apiResponseModels/add_event_response_model.dart';
import '../api/apiResponseModels/photo_selection_confirm_index.dart';
import '../api/apiResponseModels/photoselection_details_for_Notification_response_model.dart';
import '../api/apiResponseModels/transporter_response_model.dart';
import '../api/api_call.dart';
import '../database/dao/notifications_dao.dart';
import '../database/model/app_db.dart';
import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';
import '../redirection/redirection_controller.dart';
import '../routes/1.constants/common_constants.dart';
import 'package:drift/drift.dart' as drift;

import '../routes/1.constants/redirection_constants.dart';

class NotificationUtils {
  TransporterResponse? studioData;
  final notificationsDao = objectBox.notificationsDao;
  RedirectionController redirectionController = RedirectionController();
  String studioCode = '';
  String publicPath = '';
  String imageUrl = '';
  String eventCode = '';
  Api? apiRepo = Api(null);

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(id++, 'PhotoSelection ',
        'Moving selected files completed ', notificationDetails,
        payload: 'item x');
  }

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'app_notifications', // id
    'App notifications', // title
    description: 'This channel is used for get app notifications.',
    // description
    importance: Importance.high,
  );

  showNotifications(
      int? notificationId, String title, String description, Uint8List? image,
      {String? payload, String? subheading}) async {
    try {
      BigPictureStyleInformation? bigPictureStyleInformation;
      showLog('the push notify step 1');
      /*  var df =
        'https://cdn.pixabay.com/photo/2018/01/21/01/46/architecture-3095716_960_720.jpg';*/
      showLog('the push notify step 2');

      if (image != null) {
        showLog('the push notify step 5');

        bigPictureStyleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(base64Encode(image)),
          // largeIcon:
          //ByteArrayAndroidBitmap.fromBase64String(base64Encode(image)),
          //largeIcon: FilePathAndroidBitmap(base64Encode(List.from(image.toList()))),
          //largeIcon: DrawableResourceAndroidBitmap("logo_1024_500"),
        );
      }
      showLog('the push notify step 3$subheading');

      await flutterLocalNotificationsPlugin.show(
          notificationId ?? Random().nextInt(1000),
          title,
          '$subheading - $description',
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              styleInformation: bigPictureStyleInformation,
              largeIcon: const DrawableResourceAndroidBitmap(
                  'notification_large_icon'),
            ),
          ),
          payload: payload);
      showLog('the push notify step 4');
    } catch (e) {
      showLog('Exeption in the push notify $e');
    }
  }

  Future<void> showLocalNotification(
      String? imageURL, String title, String subTitle,
      {String? payload, String? subheading}) async {
    Uint8List? image;
    try {
      if (imageURL != null) {
        http.Response response = await http.get(
          Uri.parse(imageURL),
        );
        image = response.bodyBytes;
      }
    } catch (e) {
      image = null;
      showLog('Error : in notify method $e');
    }

    await showNotifications(null, title, subTitle, image,
        payload: payload, subheading: subheading);
  }

  getStudioData() async {
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    //showLog('res2res2res2res2 ${prefsStudioData}');
    studioData = transporterResponseFromJson(prefsStudioData);
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!.studiosData![studioIndex].data!.packages!.isNotEmpty) {
      studioCode = studioData?.studiosData![studioIndex].data!.code ?? "";
      publicPath =
          studioData!.studiosData![studioIndex].data!.publicStoragePath!;

      showLog('getStudioData in for studioCode :$studioCode');
    }
  }

  fetchEventDataFromApi(String eventCode, String title, String message) async {
    await getStudioData();
    await redirectionController.setRedirection(message);
    List<Notification> entity = [];
    int lastUpdated = 0;
    List<request.Event> events = [
      request.Event(
          code: eventCode,
          lastUpdatedAt: 0,
          confirmedLastUpdated_at: lastUpdated)
    ];

    PhotoSelectionDetailsForNotificationResponseModel? notificationDetails =
        await apiRepo!
            .photoSelectionDetailsForNotificationApiCall(eventCode, studioCode);
    showLog(
        "photoSelectionDetailsForNotificationApiCall --- message $notificationDetails");
    imageUrl = notificationDetails!.data!.eventCoverImage!.jvtFile!.name ?? "";

    showLog('eventResponse from notify $imageUrl');

    entity.add(Notification(
        notificationData: jsonEncode(notificationDetails),
        createdAt: DateTime.now(),
        eventCode: eventCode,
        notification: message));
    await notificationsDao.insertNotifications(entity);
    //updateIconBadge();

    showLocalNotification('$publicPath/$imageUrl', title ?? "", message ?? "",
        subheading: notificationDetails!.data!.eventName, payload: '');
  }

  updateIconBadge() async {
    // showLog("isAppBadgeSupported: $value");
    var res = await AppBadgePlus.isSupported();

    showLog('AppBadgePlus $res');
    AppBadgePlus.updateBadge(5);
  }
}
