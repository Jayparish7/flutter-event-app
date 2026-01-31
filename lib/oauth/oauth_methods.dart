import 'package:flutter/cupertino.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';

import '../main.dart';
import '../routes/login/login_form.dart';


class OauthMethods {
  static setLogout(BuildContext context) async {
    final folderModelDao = objectBox.folderModelDao;
    final imageModelDao = objectBox.imageModelDao;

    final photoMallStudioInfoDao = objectBox.photoMallStudioInfoDao;
    final transporterDao = objectBox.transporterDao;
    final eventModelDao = objectBox.eventModelDao;

    final uploadStatusDao = objectBox.uploadStatusDao;

    final notificationsDao = objectBox.notificationsDao;
    Api api = Api(null);
    await api.logoutApiCall();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, RoutePaths.login, (Route<dynamic> route) => false);
    } else {
      // close the app if any error on navigate
    }
    await PreferenceHelper.setBool(isLoggedInPreferenceKey, false);
    await PreferenceHelper.removePreference(accessTokenPreferenceKey);
    await PreferenceHelper.removePreference(refreshTokenPreferenceKey);
    await PreferenceHelper.removePreference(accessTokenPreferenceExpiresKey);
    await PreferenceHelper.removePreference(studioDataKey);
    await PreferenceHelper.removePreference(studioDetectedKey);
    await PreferenceHelper.removePreference(eventCodePreferenceKey);
    await PreferenceHelper.removePreference(eventCodeAlbumCodeKey);
    await PreferenceHelper.removePreference(updateStatusKey);
    await PreferenceHelper.removePreference(lastUpdateCheckKey);
    await PreferenceHelper.removePreference(redirectionConstantsKey);
    await PreferenceHelper.removePreference(defaultEventCoverImageKey);
    await PreferenceHelper.removePreference(studioCoverImageKey);
    await PreferenceHelper.removePreference(studioCodePrefKey);
    await PreferenceHelper.removePreference(studioIndexKey);
    await PreferenceHelper.removePreference(studioSelectedKey);
    await PreferenceHelper.removePreference(screenDisplayKey);
    await PreferenceHelper.removePreference(windowsActivationCheckKey);
    await PreferenceHelper.removePreference(originalFilePathKey);
    await googleSignIn.signOut();
    // delete the database File
    await folderModelDao.deleteFolders();
    await imageModelDao.deleteImages();
    await photoMallStudioInfoDao.deletePhotomallStudioInfo();
    await transporterDao.deleteTransporter();
     eventModelDao.deleteEvents();
      uploadStatusDao.deleteUploadStatus();
    await notificationsDao.deleteNotificationTableData();
  }

  static setLogin(bool value) async {
    await PreferenceHelper.setBool(isLoggedInPreferenceKey, value);
  }

  static Future<bool> getLogin() async {
    return await PreferenceHelper.getBool(isLoggedInPreferenceKey);
  }

  static setOauthInPreference(OauthObject oauthObject) async {
    await PreferenceHelper.setString(
        accessTokenPreferenceKey, oauthObject.accessToken);
    await PreferenceHelper.setString(
        refreshTokenPreferenceKey, oauthObject.refreshToken);
    await PreferenceHelper.setInt(
        accessTokenPreferenceExpiresKey, oauthObject.expiresIn);
  }

  static Future<OauthObject> getOauthInPreference() async {
    String accessToken =
        await PreferenceHelper.getString(accessTokenPreferenceKey);
    String refreshToken = await PreferenceHelper.getString(
      refreshTokenPreferenceKey,
    );
    int expires = await PreferenceHelper.getInt(
      accessTokenPreferenceExpiresKey,
    );
    return OauthObject(
      accessToken: accessToken,
      expiresIn: expires,
      refreshToken: refreshToken,
    );
  }
}

class OauthObject {
  String accessToken;
  String refreshToken;
  int expiresIn;

  OauthObject(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresIn});
}
