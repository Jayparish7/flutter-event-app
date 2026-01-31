import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

class PermissionUtil {
  /// 安卓权限
  static List<Permission> androidPermissions = <Permission>[
    // 在这里添加需要的权限
    Permission.storage
  ];

  /// ios权限
  static List<Permission> iosPermissions = <Permission>[
    // 在这里添加需要的权限
    Permission.storage
  ];

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    if (Platform.isIOS) {
      return await iosPermissions.request();
    }
    var status = await Permission.storage.request();
    showLog('requestAll and camera req $status' );

    return await androidPermissions.request();
  }

  static Future<Map<Permission, PermissionStatus>> request(
      Permission permission) async {
    final List<Permission> permissions = <Permission>[permission];
    return await permissions.request();
  }

  static bool isDenied(Map<Permission, PermissionStatus> result) {
    var isDenied = false;
    result.forEach((key, value) {
      if (value == PermissionStatus.denied) {
        isDenied = true;
        return;
      }
    });
    return isDenied;
  }

  /*static void showDeniedDialog(BuildContext context) {
    HDialog.show(
        context: context,
        title: '权限申请异常',
        content: '请在【应用信息】-【权限管理】中，开启全部所需权限，以正常使用惠爆单功能',
        options: <DialogAction>[
          DialogAction(text: '去设置', onPressed: () => openAppSettings())
        ]);
  }
*/
  /// 检查权限
  static Future<bool> checkGranted(Permission permission) async {
    PermissionStatus storageStatus = await permission.status;
    if (storageStatus == PermissionStatus.granted) {
      //已授权
      return true;
    } else {
      //拒绝授权
      return false;
    }
  }
}
Future<void> requestPermissionForAndroid(BuildContext context) async {
  if (!Platform.isAndroid) {
    return;
  }
  showLog('_requestPermissionForAndroid');
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // onNotificationPressed function to be called.
  //
  // When the notification is pressed while permission is denied,
  // the onNotificationPressed function is not called and the app opens.
  //
  // If you do not use the onNotificationPressed or launchApp function,
  // you do not need to write this code.
  if (!await FlutterForegroundTask.canDrawOverlays) {
    showLog('_requestPermissionForAndroid ${await FlutterForegroundTask.canDrawOverlays}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'This app requires permission to draw over other apps. Please grant this permission in the next screen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FlutterForegroundTask.openSystemAlertWindowSettings();
              },
              child: Text('Allow'),
            ),
          ],
        );
      },
    );
    // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
   // await FlutterForegroundTask.openSystemAlertWindowSettings();
  }

  // Android 12 or higher, there are restrictions on starting a foreground service.
  //
  // To restart the service on device reboot or unexpected problem, you need to allow below permission.
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
  final NotificationPermission notificationPermissionStatus =
  await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
}
Future<void> requestStoragePermission1() async {
  var status = await Permission.photos.request();
//var permission = await Permission.manageExternalStorage.request();
 // print("Storage permission granted. $permission");

  if (status.isGranted) {
    showLog("Storage permission granted.");

    // Proceed with accessing storage
  } else if (status.isDenied) {
    // Permission was denied but can be requested again
    showLog("Storage permission denied. Requesting again...");
    // Optionally, show a dialog explaining why you need the permission
    // Then request the permission again or handle the denial
    requestPermissionAgain();
  } else if (status.isPermanentlyDenied) {
    // Permission is permanently denied, you should open the app settings
    showLog("Storage permission permanently denied. Please enable it in settings.");
    await openAppSettings();
  }
}
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    showLog("sdkInt $sdkInt");
    PermissionStatus status;
    if (sdkInt >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await ToastUtil.showSnackBarAtCurrentState(
          "Please grant Photos permission to proceed.");
      await Future.delayed(
          const Duration(seconds: 3));
      await openAppSettings();
    }

    return false;
  }

  return false;
}

Future<void> requestPermissionAgain() async {
  var status = await Permission.photos.request();

  if (status.isGranted) {
    showLog("Permission granted after second request.");
    // Proceed with your functionality
  } else if (status.isDenied || status.isPermanentlyDenied) {
    showLog("Permission still denied. Inform the user.");
    // You may show a dialog explaining why this permission is critical
  }
}

void listFilesInDirectory(String directoryPath) async {
  // Request permission to read external storage
  showLog('listFilesInDirectory $directoryPath');
  var status = await Permission.photos.request();

  if (status.isGranted) {
    // Create a Directory instance
    Directory directory = Directory(directoryPath);

    // Check if the directory exists
    if (directory.existsSync()) {
      // List all the files and directories within, filtering to only include files
      List<FileSystemEntity> files = directory.listSync().where((file) {
        return FileSystemEntity.isFileSync(file.path); // Filter only files
      }).toList();

      // Log the number of files found
      print('android path files --- > ${files.length}');

      // Iterate through the files and print their paths
      for (var file in files) {
        print(file.path);
      }
    } else {
      print('Directory does not exist');
    }
  } else {
    print('Permission denied');
  }
}



getVideoPermission() async {
  if (Platform.isAndroid) {
    // Video permissions.
    if (await Permission.videos.isDenied || await Permission.videos.isPermanentlyDenied) {
      final state = await Permission.videos.request();
      if (!state.isGranted) {
        await SystemNavigator.pop();
      }
    }
    // Audio permissions.
    if (await Permission.audio.isDenied || await Permission.audio.isPermanentlyDenied) {
      final state = await Permission.audio.request();
      if (!state.isGranted) {
        await SystemNavigator.pop();
      }
    }
  } else {
    /*if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
      final state = await Permission.storage.request();
      if (!state.isGranted) {
        await SystemNavigator.pop();
      }
    }*/
  }
  showLog('getVideoPermission {await Permission.videos.isGranted} || {await Permission.audio.isGranted}');
}