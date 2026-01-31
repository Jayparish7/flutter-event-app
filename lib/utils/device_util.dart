import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_network_monitor/flutter_network_monitor.dart';
import 'package:flutter_ntp/flutter_ntp.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/eventSubView/event_subview_route.dart';
import 'package:system_info2/system_info2.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_call.dart';
import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';

class DeviceUtil {
  final speedTest = SpeedTest();

  Future<void> openFolderInExplorer(String path) async {
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [path]);
    } else if (Platform.isAndroid) {

      launch(path);

      /*openFileManager(
          androidConfig: AndroidConfig(
        folderType: FolderType.recent,

        //folderType: AndroidFolderType.other,
        //folderPath: 'Pictures/Screenshots',
      ));*/
    }
  }

  void checkDownloadSpeed() async {
    double speed = await speedTest.testDownloadSpeed();
    showLog('Download Speed: ${speed.toStringAsFixed(2)} Mbps');
  }

  Future<int> getDeviceMemoryForAndroid() async {
    int? deviceMemory = await SystemInfoPlus.physicalMemory; // returns in MB
    showLog("deviceMemory : $deviceMemory");
    return deviceMemory ?? 0;
  }

  Future<int> getDeviceMemoryForDesktop() async {
    const int megaByte = 1024 * 1024;

    if (Platform.isWindows) {
      Map<String, double> ramDetails =
          await getRamDetailsForWindows(); // your custom implementation
      return int.parse(ramDetails['totalMB']!.toStringAsFixed(2));
    } else {
      int freeMemory = SysInfo.getTotalPhysicalMemory();
      return freeMemory ~/ megaByte;
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    String? uniqueId = "";
    String details = "";
    Map<String, dynamic> deviceMap = {};

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo device = await deviceInfoPlugin.webBrowserInfo;
    } else {
      if (Platform.isAndroid) {
        //get android device info
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

        String deviceId;

        await PreferenceHelper.setString(
            deviceIdPreferenceKey, androidInfo.id.toString());
        deviceId = androidInfo.id.toString();
        details = androidInfo.device.toString();

        deviceMap = {
          "app": {
            "device": {
              "name": androidInfo.device.toString(),
              "android_version": androidInfo.version.sdkInt.toString(),
              "device_manufacturer": androidInfo.manufacturer.toString(),
              "android_device": deviceId.toString(),
              "fcm_notification_token":
                  await FirebaseMessaging.instance.getToken(),

              //await FirebaseMessaging.instance.getToken(),
            }
          },
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo device = await deviceInfoPlugin.iosInfo;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo device = await deviceInfoPlugin.linuxInfo;
        uniqueId = device.machineId;
        details = device.data.toString();
        showLog('application_code is $details');
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo device = await deviceInfoPlugin.macOsInfo;
        uniqueId = device.systemGUID;
        details = device.data.toString();
        showLog('application_code is $details');
      } else if (Platform.isWindows) {
        WindowsDeviceInfo device = await deviceInfoPlugin.windowsInfo;
        uniqueId = device.deviceId;
        details = device.data.toString();
      }
    }
    return Platform.isAndroid
        ? deviceMap
        : {
            "device": {"name": details, "desktop_device_uuid": uniqueId},
            "application_code": "tc8tfjui",
            "app_version_code": "1"
          };
  }

  Future<bool?> checkSystemTime(BuildContext? context) async {
    // Assuming WindowsSystemInfo.getDateTime() now correctly fetches system time in UTC
    final systemTimeUTC = DateTime.now().toUtc();
    DateTime? referenceUTC = await FlutterNTP.now() ?? null;
    showLog('referenceUTC  $referenceUTC'); // Implement an NTP client here

    final difference = referenceUTC?.difference(systemTimeUTC).inSeconds;

    showLog('🕒 System Time (UTC): $systemTimeUTC');
    showLog('🌍 Reference UTC Time: $referenceUTC');
    showLog('⏳ Time Difference: $difference seconds');

    if (difference!.abs() > 300) {
      showLog(
          '⚠️ Warning: System time is out of sync with UTC. Please update it.');
      if (context != null) {
        if (!context.mounted) return null;
        showDateTimeDifferenceAlertDialog(context);
      }
      return false;
    } else {
      showLog('✅ System time is synchronized.');
      return true;
    }
    return null;
  }

  void openDateTimeSettings() {
    Process.run('cmd', ['/c', 'start ms-settings:dateandtime']);
  }

  showDateTimeDifferenceAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: ((context) => CommonAlertDialog(
              title: "Change Date & Time",
              content:
                  "Your system date & time may be incorrect. Would you like to update it now?",
              actions: [
                CustomPrimaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: "Cancel",
                ),
                CustomPrimaryButton(
                  onPressed: () {
                    (Platform.isWindows) ? openDateTimeSettings() : null;
                    Navigator.pop(context);
                  },
                  text: "Change date & time🕒",
                ),
              ],
            )));
  }

  Future<int> calculateBatchSize() async {
    const int megaByte = 1024 * 1024;
    const int processMemoryUsageMB = 500; // Your process takes ~500MB
    // Get system memory info
    int freeMemoryMB = 500;
    if (!Platform.isWindows) {
      freeMemoryMB = SysInfo.getFreePhysicalMemory() ~/ megaByte;
    }
    // Subtract process memory usage from free memory
    if (Platform.isWindows) {
      Map<String, double> ramDetails = await getRamDetailsForWindows();
      freeMemoryMB = ramDetails['freeMB']!.toInt();
      showLog('Total Memory: ${ramDetails['totalMB']!.toStringAsFixed(2)} MB');
      showLog('Free Memory: ${ramDetails['freeMB']!.toStringAsFixed(2)} MB');
      showLog('Used Memory: ${ramDetails['usedMB']!.toStringAsFixed(2)} MB');
      showLog('Usage: ${ramDetails['usagePercent']!.toStringAsFixed(2)}%');
    }
    int availableMemoryMB = freeMemoryMB - processMemoryUsageMB;
    if (availableMemoryMB < 0) availableMemoryMB = 0;
    double? cpuUsage = 10.0;
    if (Platform.isWindows) {
      cpuUsage = await getCpuUsage();
    } // Avoid negative values
    // Calculate batch size based on remaining memory
    int batchSize = (Platform.isWindows || Platform.isLinux)
        ? await getBatchSizeForWindows(availableMemoryMB, cpuUsage)
        : getBatchSize(availableMemoryMB);

    showLog('Free memory before processing:: $freeMemoryMB MB');
    showLog('Estimated available memory: $availableMemoryMB MB');
    showLog('Calculated batch size: $batchSize');
    showLog('Calculated cpuUsage $cpuUsage');

    if (availableMemoryMB <= 1000) {
      triggerDartGarbageCollector();
    }
    return batchSize;
  }

  int getBatchSize(int memory) {
    if (memory >= 10000) return 6;
    if (memory >= 8000) return 5; // 8GB+
    if (memory >= 4000) return 4; // 4GB-8GB
    if (memory >= 2000) return 3; // 2GB-4GB
    if (memory >= 1000) return 2; // 1GB-2GB
    return 3; // Less than 500MB, use minimal batch
  }

  Future<int> getBatchSizeForWindows(int memory, double cpuUsage) async {
    int baseBatchSize = 3; // Default low batch size

    if (memory >= 10000) {
      baseBatchSize = 5;
    } else if (memory >= 8000) {
      baseBatchSize = 4;
    } else if (memory >= 4000) {
      baseBatchSize = 3;
    } else if (memory >= 2000) {
      baseBatchSize = 2;
    } else if (memory >= 1000) {
      baseBatchSize = 3;
    }
    // Reduce batch size if CPU usage is too high
    /* if (cpuUsage > 75) {
      showLog("High CPU detected! Reducing batch size...");
      baseBatchSize = (baseBatchSize / 2).ceil(); // Reduce batch size by 50%
      await Future.delayed(
          const Duration(milliseconds: 200)); // Slow down processing
    } // Reduce by 50%
    if (cpuUsage > 50) {
      showLog("Moderate CPU detected! Slowing down slightly...");
      baseBatchSize = (baseBatchSize * 0.75).ceil(); // Reduce batch size by 25%
      await Future.delayed(const Duration(milliseconds: 100));
    }
    showLog("getBatchSize ceil $baseBatchSize cpuUsage is $cpuUsage");*/

    return baseBatchSize;
  }

  static triggerDartGarbageCollector() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      showLog("GC should have run by now.");
    });
  }

  Future<void> getFreeRam() async {
    try {
      ProcessResult result = await Process.run('powershell',
          ['(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory']);

      if (result.exitCode == 0) {
        String output = result.stdout.toString().trim();
        int freeRamKb = int.tryParse(output) ?? 0;
        double freeRamMb = freeRamKb / 1024;
        showLog('Free RAM: ${freeRamMb.toStringAsFixed(2)} MB');
      } else {
        showLog('Error: ${result.stderr}');
      }
    } catch (e) {
      showLog('Exception: $e');
    }
  }

  Future<Map<String, double>> getRamDetailsForWindows() async {
    try {
      // Execute a PowerShell command to get memory details in JSON format.
      ProcessResult result = await Process.run(
        'powershell',
        [
          '-Command',
          'Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory,TotalVisibleMemorySize | ConvertTo-Json'
        ],
      );

      if (result.exitCode != 0) {
        throw Exception('Error retrieving memory details: ${result.stderr}');
      }

      // Parse the JSON output.
      final jsonOutput = jsonDecode(result.stdout);
      int freeMemoryKB = int.parse(jsonOutput['FreePhysicalMemory'].toString());
      int totalMemoryKB =
          int.parse(jsonOutput['TotalVisibleMemorySize'].toString());

      // Convert KB to MB.
      double totalMB = totalMemoryKB / 1024;
      double freeMB = freeMemoryKB / 1024;
      double usedMB = totalMB - freeMB;
      double usagePercent = (usedMB / totalMB) * 100;

      return {
        'totalMB': totalMB,
        'freeMB': freeMB,
        'usedMB': usedMB,
        'usagePercent': usagePercent,
      };
    } catch (e, s) {
      // Catch and print any exceptions that occur during the process.
      showLog('Exception in getRamDetails: $e');
      DeviceUtil deviceUtil = DeviceUtil();
      await deviceUtil.callChatNotifier('$e', '$s');
      return {
        'totalMB': 8000.0,
        'freeMB': 1000.0,
        'usedMB': 0.0,
        'usagePercent': 40.0,
      };
    }
  }

  Future<String> getDeviceProcessorForAndroid() async {
    if (Platform.isAndroid) {
      try {
        final result = await Process.run('cat', ['/proc/cpuinfo']);
        final lines = result.stdout.toString().split('\n');
        final modelLine = lines.firstWhere(
          (line) =>
              line.toLowerCase().contains('hardware') ||
              line.toLowerCase().contains('model name') ||
              line.toLowerCase().contains('processor'),
          orElse: () => '',
        );
        return modelLine.split(':').last.trim();
      } catch (e) {
        return 'Unknown Processor';
      }
    } else {
      return 'Not running on Android';
    }
  }

  Future<String> getDeviceProcessor() async {
    if (Platform.isWindows) {
      // Use PowerShell command to get processor name
      final result = await Process.run(
        'powershell',
        ['(Get-WmiObject Win32_Processor).Name'],
      );
      return result.stdout.toString().trim();
    } else if (Platform.isLinux) {
      final result = await Process.run('cat', ['/proc/cpuinfo']);
      final lines = result.stdout.toString().split('\n');
      final modelLine = lines.firstWhere(
        (line) => line.toLowerCase().contains('model name'),
        orElse: () => '',
      );
      return modelLine.split(':').last.trim();
    } else if (Platform.isMacOS) {
      final result = await Process.run(
        'sysctl',
        ['-n', 'machdep.cpu.brand_string'],
      );
      return result.stdout.toString().trim();
    } else {
      return 'Unknown Processor';
    }
  }

  /* Future<bool> isWindowsActivated() async {
    try {
      // Run the slmgr.vbs command
      ProcessResult result = await Process.run(
          'cscript', [r'C:\Windows\System32\slmgr.vbs', '/dli']);

      // Log the entire result for debugging
      showLog("slmgr.vbs Result: ${result.stdout}");
      showLog("slmgr.vbs Error: ${result.stderr}");

      // Check if the output contains "License Status: Licensed"
      String output = result.stdout.toString().trim();
      showLog("Activation Status Output: $output");

      return output.contains("License Status: Licensed");
    } catch (e) {
      showLog("Error checking activation: $e");
      return false;
    }
  }*/
  Future<bool> isWindowsActivated() async {
    try {
      ProcessResult result = await Process.run(
          'cscript', [r'C:\Windows\System32\slmgr.vbs', '/xpr']);

      String output = result.stdout.toString().trim();
      showLog("Activation Status Output: $output");

      return output.contains("permanently activated");
    } catch (e) {
      showLog("Error checking activation: $e");
      return false;
    }
  }

  Future<double> getCpuUsage() async {
    try {
      ProcessResult result = await Process.run('powershell', [
        '(Get-Counter "\\Processor(_Total)\\% Processor Time").CounterSamples.CookedValue'
      ]);

      String output = result.stdout.toString().trim();
      return double.tryParse(output) ?? 0.0;
    } catch (e) {
      showLog("Error fetching CPU usage: $e");
      return 0.0;
    }
  }

  callChatNotifier(String exception, String stack) async {
    showLog("callChatNotifier");
    try {
      String appCode = '';
      if (Platform.isLinux) {
        appCode = applicationCodeLinux;
      } else if (Platform.isMacOS) {
        appCode = applicationCodeMac;
      } else if (Platform.isWindows) {
        appCode = applicationCodeWindows;
      } else if (Platform.isAndroid) {
        appCode = applicationCodeAndroid;
      }
      Api api = Api(null);
      await api.callChatNotifier(
        exception: exception,
        errorDetail:
            '$stack\nappCode : $appCode \n App version: $appVersionCode',
      );
    } catch (e) {
      showLog("exception callChatNotifier $e");
    }
  }
}
