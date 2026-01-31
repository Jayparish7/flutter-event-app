import 'dart:io';
import 'dart:isolate';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/common_widgets/split_view.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/albumDetail/album_detail_view_model.dart';
import 'package:photomall_studio_manager/utils/device_util.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import '../../common_widgets/common_elevated_button.dart';
import '../../common_widgets/common_icon.dart';
import '../../common_widgets/dual_scroll.dart';
import '../../common_widgets/show_fullscreen_image.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
//import '../../web_socket/web_socket_methods.dart';

class AlbumDetail extends StatefulWidget {
  final String albumCode;
  final String studioCode;
  final String path;
  final String eventCode;

  const AlbumDetail({
    Key? key,
    required this.albumCode,
    required this.studioCode,
    required this.path,
    required this.eventCode,
  });

  @override
  State<AlbumDetail> createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail> {
  BaseWidget<AlbumDetailedController>? baseWidget;
  ReceivePort? _receivePort;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLog("Album detailed view ${widget.eventCode}");

    if (Platform.isAndroid) {
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      //_initForegroundTask();
      //_startForegroundTask();
      // You can get the previous ReceivePort without restarting the service.
      // if (await FlutterForegroundTask.isRunningService) {}
      // });
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        //foregroundServiceType: AndroidForegroundServiceType.DATA_SYNC,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startForegroundTask() async {
    //var res = await myTaskHandler.callbackDispatcher();
    showLog(
        '_startForegroundTask started ${await FlutterForegroundTask.isRunningService}');
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) async {
      if (data is int) {
        showLog('eventCount: $data');
      } else if (data is String) {
      } else if (data is DateTime) {
        showLog('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<AlbumDetailedController>(
      model: AlbumDetailedController(
          context: context, controller: Get.put(ProgressController())),
      onModelReady: (model) async {
        await model.getInitialValues(
            widget.albumCode, widget.studioCode, widget.path, widget.eventCode);
        if (false) {
          showLog("Platform.isAndroid _initForegroundTask ${widget.path}");
          _initForegroundTask();
          _startForegroundTask();
        } else {}
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            //    model.isFolderListeningStoped = true;
            Navigator.pop(context);
            return true;
          },
          child: Scaffold(
              appBar: CommonAppBar(
                title: model.albumName ?? '',
                isCenterTitle: true,
              ),
              body: Builder(builder: (context) {
                if (model.isLoading) {
                  return const PhotomallProgress();
                }

                if (model.pendingImagesForUpload == [] &&
                    model.isLoading == false) {
                  showLog("model.isLoading");
                  return const Center(
                    child: Text(
                      "No Images Found in the selected Folder",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  );
                }

                return Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                        Colors.white,
                        Colors.white
                        /*const Color(0xFF003B73),
                              Color(0xFF003B73).withOpacity(.2)*/
                      ])),
                  child: SplitView(area: .65,
                    children: [
                      photosDetailsView(model),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ImageWithTagGrid(
                          model: model,
                        ),
                      )
                    ],
                  ),
                );
              })),
        );
      },
    );
    return baseWidget!;
  }

  Widget photosDetailsView(AlbumDetailedController model) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add spacing for macOS if needed
            if (!Platform.isAndroid)  SizedBox(height: MediaQuery.of(context).size.height*.2),

            // Source folder path section
            Tooltip(
              decoration: model.isDirectoryExist.value
                  ? toolTipDecoration
                  : alertToolTipDecoration,
              message: model.isDirectoryExist.value
                  ? "Go to source folder"
                  : "Folder does not exist",
              child: InkWell(
                onTap: () async {
                  final folderPath = Platform.isWindows
                      ? model.selectedPath.value.replaceAll(r"/", '')
                      : model.selectedPath.value;

                  showLog("Go to source folder $folderPath");

                  try {
                    final dir = Directory(folderPath);
                    if (await dir.exists()) {
                      DeviceUtil().openFolderInExplorer(folderPath);
                    } else {
                      await ToastUtil.showSnackBarAtCurrentState(
                        "Folder does not exist: $folderPath",
                        seconds: 3,
                        isError: true,
                      );
                    }
                  } catch (e) {
                    showLog("Exception in Go to source folder $e");
                  }
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: model.isDirectoryExist.value
                          ? Colors.grey
                          : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: "${S.of(context).images_path}:",
                          isBody: true,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        CommonText(
                          text: model.selectedPath.value,
                          isLabel: true,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Number of images
            CommonText(
              text:
              '${S.of(context).number_of_images} : ${model.imagesCount}',
              isBody: true,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // Compression status
            _buildProgressBar(
              label: "Processing",
              stream: model.streamCompressionProgress(),
              progressColor: Colors.blue, // or Color(0xFF2196F3)
            ),
            const SizedBox(height: 10),
            _buildProgressBar(
              label: "Uploading",
              stream: model.streamProgress(),
              progressColor: Colors.green, // or Color(0xFF2196F3)
            )
          ],
        ),
      ),
    );
  }


  Widget _buildProgressBar({
    required String label,
    required Stream<String> stream,
    Color progressColor = Colors.green,
    Color backgroundColor = const Color(0xFFE0E0E0),
  }) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data == 'done') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LinearProgressIndicator(
                //   value: 1,
                //   color: Colors.green,
                //   backgroundColor: backgroundColor,
                //   minHeight: 8,
                // ),
                // const SizedBox(height: 8),
                Text(
                  '$label complete ✅',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          final parts = data.split('/');
          if (parts.length == 2) {
            final current = int.tryParse(parts[0]) ?? 0;
            final total = int.tryParse(parts[1]) ?? 1;
            final progress = current / total;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    color: progressColor,
                    backgroundColor: backgroundColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$label: $current of $total files',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }
        }

        // Default loading
        return LinearProgressIndicator(
          value: null,
          minHeight: 8,
          color: progressColor,
          backgroundColor: backgroundColor,
        );
      },
    );
  }



}

class ImageWithTagGrid extends StatefulWidget {
  final AlbumDetailedController model;

  const ImageWithTagGrid({super.key, required this.model});

  @override
  State<ImageWithTagGrid> createState() => _ImageWithTagGridState();
}

class _ImageWithTagGridState extends State<ImageWithTagGrid> {
  /* final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!Platform.isAndroid) {
      //_connectToWebSocket();
    }
  }

  /* void _connectToWebSocket() async {
    const wsUrl = 'wss://echo.websocket.events';

    await handleWebSocketConnection1(wsUrl, (message) {
      showLog('message ${message}');
      setState(() {});
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderImage>>(
        stream: widget.model.streamImageForView(),
        builder: (context, AsyncSnapshot<List<OrderImage>> snapshot) {
          showLog("streamImageForView ${snapshot.hasData}");

          if (snapshot.hasData) {

            showLog("streamImageForView ${snapshot.data!.length}");
            return PaginatedImageGridView(
              allImages: snapshot.data!,
              model: widget.model,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  @override
  void dispose() {
    //_channel.sink.close();
    super.dispose();
  }
}
