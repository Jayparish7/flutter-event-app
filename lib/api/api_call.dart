import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/add_album_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/add_event_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/album_index_response.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/album_show_responce.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/app_update_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/device_register_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/folder_store_response.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/image_upload.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/login_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/logout_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/otp_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_confirm_index.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/studi_index_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/studio_store_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/user_staf_index_response_model.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/api/constants/key_constants.dart';
import 'package:photomall_studio_manager/api/constants/url_constants.dart';

import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';
import '../routes/1.constants/api_constants.dart';
import '../routes/1.constants/common_constants.dart';
import '../utils/device_util.dart';
import 'apiResponseModels/EventSettingsShowResponseModel.dart';
import 'apiResponseModels/add_user_response_model.dart';
import 'apiResponseModels/chat_notifier_response_model.dart';
import 'apiResponseModels/cover_image_response_model.dart';
import 'apiResponseModels/dash_board_details_response_model.dart';
import 'apiResponseModels/download_extension_response_model.dart';
import 'apiResponseModels/event_create_response_model.dart';
import 'apiResponseModels/event_store_response_model.dart';
import 'apiResponseModels/file_upload_credentials_response_model.dart';
import 'apiResponseModels/photoSelection_reverse_confirmation_response_model.dart';
import 'apiResponseModels/photoselection_details_for_Notification_response_model.dart';
import 'apiResponseModels/pre_signed_url_api_response_model.dart';
import 'apiResponseModels/studio_details_for_studio_settings_response_model.dart';
import 'apiResponseModels/studio_events_api_call.dart';
import 'apiResponseModels/studio_users_search_response_model.dart';

class Api {
  BuildContext? context;
  ApiHelper? apiHelper = ApiHelper();

  Api(this.context);

  Future<ErrorNotifier> callChatNotifier(
      {String? exception, String? errorDetail}) async {
    var map = {
      'type': 6, // (1-True Caller Failed, 2-403 Image Failed , 6-App error)
      'exception': exception,
      'exception_detail': errorDetail,
    };
    var response = await apiHelper!.apiRequest(
      chatNotifierURL,
      map,
    );
    return compute(errorNotifierFromJson, response);
  }

  Future<DeviceRegisterModel?> devRegApiCall(
      Map<String, dynamic> deviceMap) async {
    var response = await apiHelper!.apiRequest(
        (Platform.isAndroid) ? appRegisterUrl : deviceRegisterUrl, deviceMap);
    return compute(deviceRegisterModelFromJson, response);
  }

  Future<LoginModel> userNameApiCall(String userName, id) async {
    Map<String, dynamic> map = {
      userNameKey: userName,
      countryIdKey: id,
    };
    var response = await apiHelper!.apiRequest(
      userNameURL,
      map,
    );
    return compute(loginModelFromJson, response);
  }

  Future<OtpResponse?> otpApiCall(
      String userName, otp, int countryId, int clientId,
      {bool trueCaller = false}) async {
    Map<String, dynamic> map = {
      userNameKey: userName.trim(),
      //trueCallerSmsKey: trueCaller ?"1" :'0',
      signInWithGoogleKey: trueCaller ? "1" : '0',
      otpKey: otp,
      countryIdKey: countryId,
      grantTypeKey: 'otp_grant',
      scopeKey: '*',
      clientIdKey: clientId
    };
    var response = await apiHelper!.apiRequest(
      otpURL,
      map,
    );
    return compute(otpResponseFromJson, response);
  }

  Future<StudioIndex?> studioIndexApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(studioIndexUrl, map);
    return compute(studioIndexFromJson, response);
  }

  Future<AppUpdate?> appUpdateApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(appUpdateStatusUrl, map);
    return compute(appUpdateFromJson, response);
  }

  Future<UserStaffGroupsIndex?> userStaffIndexApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(userStaffGroupsIndexUrl, map);
    return compute(userStaffGroupsIndexFromJson, response);
  }

  Future<StudioStoreresponse?> studioStoreApiCall(
      String name, String email) async {
    Map<String, dynamic> map = {nameKey: name, emailAddressKey: email};
    var response = await apiHelper!.apiRequest(studioStoreUrl, map);
    return compute(studioStoreFromJson, response);
  }

  Future<TransporterResponse?> transporterApiCall(
      Map<String, dynamic> transporter) async {
    var response = await apiHelper!.apiRequest(transporterUrl, transporter);
    return compute(transporterResponseFromJson, response);
  }

  Future<List<AddEventResponse>?> addEventApiCall(
      Map<String, dynamic> map) async {
    var studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    map['studio_code'] = studioCode;
    var response = await apiHelper!.apiRequest(eventsAddUrl, map);
    return compute(addEventResponseFromJson, response);
  }

  Future<PhotoSelectionResponse?> photoSelectionApiCall(
      String eventCode, String studioCode, int lastUpdatedAt) async {
    if (!Platform.isAndroid) {
      Map<String, dynamic> map = {
        'event_code': eventCode,
        'studio_code': studioCode,
        'last_updated_at': lastUpdatedAt
      };
      var response =
          await apiHelper!.apiRequest(photoSelectionUrl, map, isFormData: true);
      showLog("photoSelectionApiCall  response:${response}");
      return compute(photoSelectionResponseFromJson, response);
    }
  }

  Future<PhotoSelectionResponse?> photoSelectionStoreApiCall(
      String eventCode, String studioCode, int lastUpdatedAt) async {
    Map<String, dynamic> map = {
      eventCodeKey: eventCode,
      studioCodeKey: studioCode,
      lastUpdatedAtKey: lastUpdatedAt
    };
    var response = await apiHelper!.apiRequest(photoSelectionStoreUrl, map);
    return compute(photoSelectionResponseFromJson, response);
  }

  Future<PhotoSelectionConfirmedIndex?> photoSelectionConfirmIndexApiCall(
      {required String eventCode,
      required String studioCode,
      required String lastUpdatedAt}) async {
    if (!Platform.isAndroid) {
      Map<String, dynamic> map = {
        eventCodeKey: eventCode,
        studioCodeKey: studioCode,
        lastUpdatedAtKey: lastUpdatedAt
      };
      var response =
          await apiHelper!.apiRequest(photoSelectionConfirmIndexUrl, map);
      return compute(photoSelectionConfirmedIndexFromJson, response);
    }
  }

  Future<FolderStore?> folderStoreApiCall(
      {required String studioCode,
      required String folderName,
      required String eventCode,
      required String parentCode,
      required String? path}) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
      nameKey: folderName,
      eventCodeKey: eventCode,
      parentCodeKey: parentCode,
      pathKey: path
    };
    var response = await apiHelper!.apiRequest(folderStoreUrl, map);
    return compute(folderStoreFromJson, response);
  }

  Future<AddAlbumResponse?> albumStoreApiCall(
      {required String studioCode,
      required String albumName,
      required String eventCode,
      required int albumType,
      required String? path}) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
      nameKey: albumName,
      eventCodeKey: eventCode,
      pathKey: path,
      albumTypeKey: albumType.toString()
    };
    Map<String, dynamic> androidMap = {
      studioCodeKey: studioCode,
      nameKey: albumName,
      eventCodeKey: eventCode,
      albumTypeKey: albumType.toString()
    };
    var response = await apiHelper!
        .apiRequest(albumStoreUrl, (Platform.isAndroid) ? androidMap : map);
    return compute(addAlbumResponseFromJson, response);
  }

  Future<AlbumIndexResponse?> albumIndexApiCall({
    required String studioCode,
    required String eventCode,
  }) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
      eventCodeKey: eventCode,
    };
    var response = await apiHelper!.apiRequest(albumIndexUrl, map);
    return compute(albumIndexResponseFromJson, response);
  }

  Future<AlbumShowResponse?> albumShowApiCall({
    required String studioCode,
    required String albumCode,
    required int lastUpdatedAt,
  }) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
      albumCodeKey: albumCode,
      lastUpdatedAtKey: lastUpdatedAt,
    };
    var response = await apiHelper!.apiRequest(albumShowUrl, map);
    return compute(albumShowResponseFromJson, response);
  }

  Future<ImageUploadResponse?> imageUploadApiCallReal({
    required String studioCode,
    required String type,
    required String ableCode,
    required String image,
    required String fileName,
  }) async {
    Map<String, dynamic> map = {
      'studio_code': studioCode,
      'able_type': type,
      'able_code': ableCode,
      'image': image,
      'file_name': fileName
    };
    var response = await apiHelper!.apiRequest(imageUploadUrl, map);
    return compute(imageUploadResponseFromJson, response);
  }

  Future<ImageUploadResponse?> imageUploadApiCall(
      {required String studioCode,
      required String eventCode,
      required String extension,
      required String type,
      required String ableCode,
      required String jvtFileName,
      required String filePath,
      required String fileName,
      required String imageHash,
      required String imageHeight,
      required String imageWidth,
      required String preSignedUrlCode,
      required String screenDisplay,
      String ratio = '',
      String largeJvtFileCode = '',
      bool isFromCompressForScreenDisplay2 = false}) async {
    showLog("large_jvt_file_name in api req $ratio $largeJvtFileCode $isFromCompressForScreenDisplay2");
    Map<String, dynamic> map = {
      'studio_code': studioCode,
      'able_type': type,
      'able_code': ableCode,
      'event_code': eventCode,
      'mime_subtype': extension.replaceAll("image/", ''),
      'jvt_file_name': jvtFileName,
      'original_file_name': fileName,
      'hash': imageHash.replaceAll('"', ''),
      'image_height': imageHeight,
      'image_width': imageWidth,
      'presigned_url_code': preSignedUrlCode,
      'screen_display': "2",//isFromCompressForScreenDisplay2 ? "2" : screenDisplay,
      'status': '1'
      //'size': size,
    };
    isFromCompressForScreenDisplay2
        ? map.addAll({
            "ratio": ratio,
            "large_jvt_file_code": largeJvtFileCode,
          })
        : null;
    showLog("imageUploadApiCall map is $map");
    if(type!='folders'){
      if ((isFromCompressForScreenDisplay2==true) &&
          (ratio == '' || largeJvtFileCode == '')) {
        showLog(
            "Validation failed: ratio and large_jvt_file_code must be provided for screen_display  $screenDisplay");
        return null;
      }
    }
    try {
      var response = await apiHelper!.apiRequest(imageUploadUrl, map);

      // Parse the response directly without using compute
      if (response != null) {
        return compute(imageUploadResponseFromJson, response);
      } else {
        return null;
      }
    } catch (e, s) {
      showLog("Image upload failed: $e");
      DeviceUtil deviceUtil = DeviceUtil();
      await deviceUtil.callChatNotifier(
          'Image upload failed photomall server timeout $e', '$s');
      return null;
    }
  }

  Future<ImageUploadResponse?> multipleImageUploadApiCall({
    required String studioCode,
    required String type,
    required String ableCode,
    required List<String> images,
    required List<String> fileNames,
  }) async {
    List<Map<String, dynamic>> maps = [];
    for (int i = 0; i < images.length; i++) {
      maps.add({
        'studio_code': studioCode,
        'able_type': type,
        'able_code': ableCode,
        'image': images[i],
        'file_name': fileNames[i],
      });
    }

    var responses = await Future.wait(
        maps.map((map) => apiHelper!.apiRequestMultipart(imageUploadUrl, map)));
    var parsedResponses = responses
        .map((response) => compute(imageUploadResponseFromJson, response))
        .toList();

    return parsedResponses.isNotEmpty ? parsedResponses.first : null;
  }

  Future<DownloadExtensionIndexModel?> downloadExtensionIndexApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(downloadExtensionUrl, map);
    return compute(downloadExtensionIndexModelFromJson, response);
  }

  Future<Logout?> logoutApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(logoutUrl, map);
    return compute(logoutFromJson, response);
  }

  Future<bool> callUpdateFcmToken(BuildContext context, String token) async {
    Map<String, dynamic> map = {tokenKey: token};
    var response = await apiHelper!.apiRequest(updateFcmTokenUrl, map,
        isShowProgress: false, showSnackBarIfError: false);
    return jsonDecode(response)['updated'] ?? true;
  }

  Future<PhotoSelectionDetailsForNotificationResponseModel?>
      photoSelectionDetailsForNotificationApiCall(
          String eventCode, String studioCode) async {
    Map<String, dynamic> map = {
      eventCodeKey: eventCode,
      studioCodeKey: studioCode
    };
    var response =
        await apiHelper!.apiRequest(photoSelectionForNotificationUrl, map);
    return compute(
        photoSelectionDetailsForNotificationResponseModelFromJson, response);
  }

  Future<PhotoselectionReverseConfirmationResponseModel?>
      photoSelectionReverseConfirmationApiCall(
          {required String eventCode, required String studioCode}) async {
    Map<String, dynamic> map = {
      eventCodeKey: eventCode,
      studioCodeKey: studioCode,
      confirmedStatusKey: "0"
    };
    var response =
        await apiHelper!.apiRequest(photoSelectionReverseConfirmationUrl, map);
    return compute(
        photoselectionReverseConfirmationResponseModelFromJson, response);
  }

  Future<PhotoselectionReverseConfirmationResponseModel?> studioSettingsApiCall(
      {required Map<String, dynamic> map, required String studioCode}) async {
    var response = await apiHelper!.apiRequest(studioSettingsUrl, map);
    return compute(
        photoselectionReverseConfirmationResponseModelFromJson, response);
  }

  Future<StudioDetailsForStudioSettingsResponseModel?>
      studioDetailsForStudioSettingsApiCall(
          {required String studioCode}) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
    };
    var response = await apiHelper!.apiRequest(studioDetailsUrl, map);
    return compute(
        studioDetailsForStudioSettingsResponseModelFromJson, response);
  }

  Future<CoverImageResponseModel?> coverImageUpdateApiCall(
      {required String studioCode,
      required String ableCode,
      required String fileName,
      required String imageInBase64}) async {
    Map<String, dynamic> map = {
      studioCodeKey: studioCode,
      ableTypeKey: 'studios',
      ableCodeKey: ableCode,
      fileNameKey: fileName,
      imageKey: 'data:image/png;base64,$imageInBase64'
    };
    var response = await apiHelper!.apiRequest(coverImageUpdateUrl, map);
    return compute(coverImageResponseModelFromJson, response);
  }

  Future<DashBoardDetailsResponseModel?> dashBoardDetailsApiCall(
      {required String studioCode}) async {
    Map<String, dynamic> map = {
      'code': await PreferenceHelper.getString(studioCodePrefKey),
    };
    var response = await apiHelper!.apiRequest(dashBoardDetailsUrl, map);
    return compute(dashBoardDetailsResponseModelFromJson, response);
  }

  Future<PhotoselectionReverseConfirmationResponseModel?>
      studioNameUpdateApiCall({required String studioName}) async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
      'studio_name': studioName
    };
    var response = await apiHelper!.apiRequest(studioNameUpdateUrl, map);
    return compute(
        photoselectionReverseConfirmationResponseModelFromJson, response);
  }

  Future<EventSettingsShowResponse?> eventSettingsShowApiCall(
      {required String eventCode}) async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
      'event_code': eventCode
    };
    var response = await apiHelper!.apiRequest(eventsShowUrl, map);
    return compute(eventSettingsShowResponseFromJson, response);
  }

  Future<EventCreateResponseModel?> eventCreateUrlApiCall() async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
    };
    var response = await apiHelper!.apiRequest(eventsCreateUrl, map);
    return compute(eventCreateResponseModelFromJson, response);
  }

  Future<EventStoreResponseModel?> eventsStoreApiCall({
    required String eventPlanCode,
    required String eventName,
    required String userRandomId,
    required String eventCategoryCode,
    required String newCategoryName,
  }) async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
      "event_plan_code": eventPlanCode,
      "event_name": eventName,
      "type": "1",
      "user_random_id": userRandomId,
      "event_category_code": eventCategoryCode,
    };
    if (newCategoryName != '') {
      map.addAll({"new_category": newCategoryName});
    }
    var response = await apiHelper!.apiRequest(eventsStoreUrl, map);
    return compute(eventStoreResponseModelFromJson, response);
  }

  Future<StudioUsersSearchResponseModel?> eventStudioUsersSearchApiCall(
      {required String searchString}) async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
      'search_term': searchString
    };
    var response = await apiHelper!.apiRequest(eventsStudioUsersSearchUrl, map);
    return compute(studioUsersSearchResponseModelFromJson, response);
  }

  Future<AddUserResponseModel?> addUserApiCall(
      {required String emailOrPhone, country, name}) async {
    Map<String, dynamic> map = {
      'studio_code': await PreferenceHelper.getString(studioCodePrefKey),
      'email_or_phone_number': emailOrPhone,
      'country_id': country,
      'name': name,
    };
    var response = await apiHelper!.apiRequest(addUserUrl, map);
    return compute(addUserResponseModelFromJson, response);
  }

  Future<FileUploadCredentialsResponseModel?>
      fileUploadCredentialsApiCall() async {
    Map<String, dynamic> map = {};
    var response = await apiHelper!.apiRequest(fileUploadCredentialsUrl, map);
    return compute(fileUploadCredentialsResponseModelFromJson, response);
  }

  Future<PreSignedUrlResponseModel?> generatePreSignedUrlApiCall({
    required String filePath,
    required String fileName,
    required String ableType,
    required String ableCode,
    required String eventCode,
  }) async {
    Map<String, dynamic> map = {
      "file_key": "$filePath/$fileName",
      "able_type": ableType,
      "able_code": ableCode,
      "event_code": eventCode,
      "jvt_file_name": fileName
    };
    var studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    map['studio_code'] = studioCode;

    var response = await apiHelper!.apiRequest(generatePreSignedUrl, map);
    return compute(preSignedUrlResponseModelFromJson, response);
  }

  Future<StudioEventsResponseModel?> studioEventsApiCall({
    required String skip,
  }) async {
    Map<String, dynamic> map = {"skip": skip};

    var studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    map['studio_code'] = studioCode;

    var response = await apiHelper!.apiRequest(studioEventsUrl, map);
    return compute(studioEventsResponseModelFromJson, response);
  }
}
