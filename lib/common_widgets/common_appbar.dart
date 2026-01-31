import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/studioDetail/studio_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../api/apiResponseModels/transporter_response_model.dart';
import '../controllers/app_update_controller.dart';
import '../database/object_box_model/object_box_models.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';
import '../routes/languages/locale_provider.dart';
import 'menu_popup.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.isMainPage = false,
    this.actions = const [SizedBox()],
    this.isTransparentAppBar = false,
    this.isAppBarTitleWidget = false,
    this.titleWidget,
    this.isCenterTitle = false,
    this.automaticallyImplyLeading = true,
    this.appBarWithLogo = false,
  });

  final double preferredHeight = 60.0;
  final String title;
  final bool isMainPage;
  final List<Widget> actions;
  final bool isTransparentAppBar;
  final bool isAppBarTitleWidget;
  final Widget? titleWidget;
  final bool isCenterTitle;
  final bool automaticallyImplyLeading;
  final bool appBarWithLogo;

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight); // default is 56.0

  @override
  _CommonAppBarState createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  late final ProgressController controller;
  late final LanguageController languageController;
  final uploadStatusDao = objectBox.uploadStatusDao;

  List<String> urls = [];
  List<UploadState>? uploadData = [];
  List<bool>? uploadInProgress = [];
  List<LanguageFormat> languages = [
    LanguageFormat(
      code: 'en',
      name: 'English',
      description: 'App Language',
    ),
    LanguageFormat(
      code: 'ta',
      name: 'தமிழ்',
      description: 'Tamil',
    ),
    LanguageFormat(
      code: 'hi',
      name: 'हिन्दी',
      description: 'Hindi',
    ),
    LanguageFormat(
      code: 'fr',
      name: 'Français',
      description: 'French',
    ),
    LanguageFormat(
      code: 'kn',
      name: 'ಕನ್ನಡ',
      description: 'Kannada',
    ),
    LanguageFormat(
      code: 'ml',
      name: 'മലയാളം',
      description: 'Malayalam',
    ),
    LanguageFormat(
      code: 'mr',
      name: 'मराठी',
      description: 'Marathi',
    ),
    LanguageFormat(
      code: 'te',
      name: 'తెలుగు',
      description: 'Telugu',
    ),
    LanguageFormat(
      code: 'ms',
      name: 'Melayu',
      description: 'Malay',
    ),
  ];

  @override
  void initState() {
    showLog("change theme..");

    controller = Get.put(ProgressController());
    languageController = Get.put(LanguageController());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getStudioLogo() async {
    try {
      uploadData = await uploadStatusDao.getUploadData();
      if (uploadData != null && uploadData!.isNotEmpty) {
        for (int i = 0; i < uploadData!.length; i++) {
          if (uploadData![i].remainingFilesCount != 0) {
            uploadInProgress!.add(true);
          } else {
            uploadStatusDao.deleteUploadStatusById(uploadData![i].id);
          }
        }
      }
    } catch (e, s) {
      showLog('error in upload data $e,$s');
    }
    showLog("controller.overallProgress ${controller.overallProgress}");
    showLog('uploadData is uploadInProgress');

    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    var logo = '';
    TransporterResponse studioData =
        transporterResponseFromJson(prefsStudioData);
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    if (studioData.studiosData![studioIndex].data != null &&
        studioData
            .studiosData![studioIndex].data!.jvtFileConnectors!.isNotEmpty) {
      logo =
          '${studioData.studiosData![studioIndex].data?.publicStoragePath}/'; // Handle potential null value with a fallback to an empty string
      logo += studioData.studiosData![studioIndex].data?.jvtFileConnectors![0]
              .jvtFile?.name ??
          '';
      if (!urls
          .contains(studioData.studiosData![studioIndex].data!.domainUrl!)) {
        urls.add(studioData.studiosData![studioIndex].data!.domainUrl!);
      }
      showLog('studiosData urls $urls');
    }
    return logo;
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: (Platform.isAndroid)
            ? const SizedBox.shrink()
            : (widget.appBarWithLogo)
                ? Obx(() {
                    return Container(
                      decoration: const BoxDecoration(
                        color: photomallBodyColor,
                      ),
                      child: AppBar(
                        surfaceTintColor: Colors.transparent,
                        automaticallyImplyLeading:
                            widget.automaticallyImplyLeading,
                        iconTheme: const IconThemeData(
                          color:
                              Color(photomallYellow), //change your color here
                        ),
                        backgroundColor: Colors.transparent,
                        //Color(photomallYellow),
                        centerTitle: true,
                        titleSpacing: -5,
                        leadingWidth: 250,
                        leading: Row(
                          children: [
                            (widget.isMainPage == false)
                                ? IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.arrow_back))
                                : const SizedBox(),
                            Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset(
                                  'assets/images/event_manager_logo.png',
                                  color: const Color(photomallYellow),
                                ))
                          ],
                        ),
                        actions: [
                          (controller.uploadStates.isNotEmpty &&
                                  controller.overallProgress != 1.0)
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                      shadowColor: Colors.transparent),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: const Color(photomallYellow),
                                            value: controller.overallProgress,
                                          ),
                                          Center(
                                            child: Text(
                                              '${(controller.overallProgress * 100).round()}%',
                                              style: const TextStyle(
                                                color: Color(photomallYellow),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Text(
                                              (controller.uploadedFiles.value !=
                                                      controller
                                                          .totalFiles.value)
                                                  ? S.of(context).uploading
                                                  : S.of(context).uploaded,
                                              style: const TextStyle(
                                                  color: Color(photomallYellow),
                                                  fontSize: 13),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: const EdgeInsets.only(
                                          //       right: 5.0),
                                          //   child: Text(
                                          //     ' - Upload Speed: ${controller.uploadSpeed.value.toStringAsFixed(2)} KB/s',
                                          //     style: const TextStyle(
                                          //         color: Color(photomallYellow),
                                          //         fontSize: 13),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _showCustomPopup(context, controller);
                                  },
                                )
                              : const SizedBox.shrink(),

                          /*: const SizedBox.shrink(),*/
                          const SizedBox(
                            width: 25,
                          ),
                          (widget.title != 'Profile' &&
                                  widget.title != 'Studios')
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder<String>(
                                      future: getStudioLogo(),
                                      builder: (context, snapshot) {
                                        return Skeletonizer(
                                          enabled: snapshot.connectionState ==
                                              ConnectionState.waiting,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                                onTap: () async {
                                                  showLog(
                                                      'snapshot.data! ${snapshot.data}');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              StudioProfile(
                                                                url: urls,
                                                              )));
                                                },
                                                child: Container(
                                                  width: 170,
                                                  height: 170,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      image: snapshot.data !=
                                                                  null &&
                                                              snapshot.data!
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                              snapshot.data ??
                                                                  "")
                                                          : const AssetImage(
                                                                  'assets/images/loading.png')
                                                              as ImageProvider,
                                                      // Replace with your image provider
                                                      fit: BoxFit
                                                          .cover, // Ensure the image covers the circular area
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        );
                                      }),
                                )
                              : const SizedBox(),
                          /*getPopUpMenu(context, widget.isMainPage),*/
                        ],
                        title: !widget.isAppBarTitleWidget
                            ? CommonText(
                                text: widget.title,
                                style: const TextStyle(
                                  color: Color(photomallYellow),
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal,
                                  /* shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],*/
                                ))
                            : widget.titleWidget,
                        elevation: 0,
                      ),
                    );
                  })
                : Obx(() {
                    return Container(
                      decoration: const BoxDecoration(
                        color: photomallBodyColor,
                      ),
                      child: AppBar(
                        surfaceTintColor: Colors.transparent,
                        automaticallyImplyLeading:
                            widget.automaticallyImplyLeading,
                        iconTheme: const IconThemeData(
                          color:
                              Color(photomallYellow), //change your color here
                        ),
                        backgroundColor: Colors.transparent,
                        //Color(photomallYellow),
                        centerTitle: false,
                        titleSpacing: 20,

                        actions: [
                          (controller.uploadStates.isNotEmpty &&
                                  controller.overallProgress != 1.0)
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                      shadowColor: Colors.transparent),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: const Color(photomallYellow),
                                            value: controller.overallProgress,
                                          ),
                                          Center(
                                            child: Text(
                                              '${(controller.overallProgress * 100).round()}%',
                                              style: const TextStyle(
                                                color: Color(photomallYellow),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Text(
                                              (controller.uploadedFiles.value !=
                                                      controller
                                                          .totalFiles.value)
                                                  ? S.of(context).uploading
                                                  : S.of(context).uploaded,
                                              style: const TextStyle(
                                                  color: Color(photomallYellow),
                                                  fontSize: 13),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: const EdgeInsets.only(
                                          //       right: 5.0),
                                          //   child: Text(
                                          //     ' - Upload Speed: ${controller.uploadSpeed.value.toStringAsFixed(2)} KB/s',
                                          //     style: const TextStyle(
                                          //         color: Color(photomallYellow),
                                          //         fontSize: 13),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _showCustomPopup(context, controller);
                                  },
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(
                            width: 25,
                          ),
                          (widget.title != 'Profile' &&
                                  widget.title != 'Studios')
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder<String>(
                                      future: getStudioLogo(),
                                      builder: (context, snapshot) {
                                        return Skeletonizer(
                                          enabled: snapshot.connectionState ==
                                              ConnectionState.waiting,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                                onTap: () async {
                                                  showLog(
                                                      'snapshot.data! ${snapshot.data}');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              StudioProfile(
                                                                url: urls,
                                                              )));
                                                },
                                                child: Container(
                                                  width: 170,
                                                  // Diameter of the CircleAvatar (2 * radius)
                                                  height: 170,

                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    image: DecorationImage(
                                                      image: snapshot.data !=
                                                                  null &&
                                                              snapshot.data!
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                              "${snapshot.data}")
                                                          : const AssetImage(
                                                                  'assets/images/loading.png')
                                                              as ImageProvider,
                                                      // Replace with your image provider
                                                      fit: BoxFit
                                                          .cover, // Ensure the image covers the circular area
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        );
                                      }),
                                )
                              : const SizedBox(),
                          /*getPopUpMenu(context, widget.isMainPage),*/

                          Tooltip(
                            message: S.of(context).languages,
                            decoration: toolTipDecoration,
                            child: IconButton(
                                onPressed: () async {
                                  var language =
                                      await PreferenceHelper.getString(
                                          languageSymbolKey);
                                  showLog('languageSymbolKey $language');
                                  language != ''
                                      ? languageController.currentLocale.value =
                                          language
                                      : null;
                                  _showLanguagePopup(
                                      context, languageController);
                                },
                                icon: const Icon(Icons.language)),
                          )
                        ],
                        title: !widget.isAppBarTitleWidget
                            ? CommonText(
                                text: widget.title,
                                style: const TextStyle(
                                  color: Color(photomallYellow),
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal,
                                  /* shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],*/
                                ))
                            : widget.titleWidget,
                        elevation: 0,
                      ),
                    );
                  }));
  }

  void _showLanguagePopup(BuildContext context, LanguageController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            height: 300,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).choose_an_languages,
                    // Adjust this based on your localization setup
                    style: const TextStyle(
                        color: Color(photomallYellow),
                        // Replace with your color value
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Expanded(
                      child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      return ListTile(
                        leading: Checkbox(
                          activeColor: const Color(photomallYellow),
                          value:
                              controller.currentLocale.value == language.code,
                          onChanged: (bool? selected) {
                            if (selected == true) {
                              controller.setLocale(language.code, context);
                            }
                          },
                        ),
                        title: Text(language.name),
                        subtitle: Text(language.description),
                      );
                    },
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

calculateOverAllProgress(ProgressController controller) {
  int totalFiles = 0;
  int uploadedFiles = 0;

  for (var uploadState in controller.uploadStates) {
    if (uploadState.totalFilesCount != null &&
        uploadState.totalFilesCount! > 0) {
      totalFiles += uploadState.totalFilesCount!;
      uploadedFiles +=
          uploadState.totalFilesCount! - uploadState.remainingFilesCount!;
    }
  }

  double overallProgress = totalFiles > 0 ? uploadedFiles / totalFiles : 0.0;
  return overallProgress;
}

void _showCustomPopup(BuildContext context, ProgressController controller) {
  final ScrollController _scrollController =
      ScrollController(); // Single instance

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          height: 300,
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (controller.uploadStates.isEmpty) {
                return Center(
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showLog('onTap');
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close)),
                      Text(S.of(context).no_recent_upload),
                    ],
                  ),
                );
              }

              return Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showLog('onTap');
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close)),
                          Text(
                            S.of(context).recent_upload,
                            style: const TextStyle(
                                color: Color(photomallYellow),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      /*  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(() => CircularProgressIndicator(
                                value: controller.overallProgress,
                              ))),
                      Text(
                          '${controller.uploadedFiles}/${controller.totalFiles} files uploaded'),*/
                      const SizedBox(height: 16.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.uploadStates.length,
                        itemBuilder: (context, index) {
                          final uploadState = controller.uploadStates[index];

                          return ListTile(
                              leading: const Icon(
                                Icons.cloud_upload,
                                color: Color(photomallYellow),
                              ),
                              title: Text(
                                '${uploadState.eventName}- ${uploadState.albumName}',
                              ),
                              subtitle: Stack(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: LinearProgressIndicator(
                                      color: Colors.green,
                                      minHeight: 2.8,
                                      value: uploadState.totalFilesCount !=
                                                  null &&
                                              uploadState.totalFilesCount! > 0
                                          ? (uploadState.totalFilesCount! -
                                                  uploadState
                                                      .remainingFilesCount!) /
                                              uploadState.totalFilesCount!
                                          : 0.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: (uploadState.remainingFilesCount !=
                                              0)
                                          ? Text(
                                              '${uploadState.totalFilesCount! - (uploadState.remainingFilesCount!.toDouble()).toInt()}/${uploadState.totalFilesCount!} uploading')
                                          : Text(
                                              S.of(context).upload_completed),
                                    ),
                                  )
                                ],
                              )
                              // Customize this widget based on your UploadStateData fields
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    },
  );
}

class ProgressController extends GetxController {
  var uploadSpeed = 0.0.obs;
  var isProcessing = false.obs;
  var progress = ''.obs;
  List<PopupMenuItem<int>> menuItems = [];
  var totalFiles = 0.obs;
  var uploadedFiles = 0.obs;

  void startProcessing() {
    isProcessing.value = true;
    progress.value = '';
  }

  void stopProcessing() {
    isProcessing.value = false;
  }

  final uploadStatusDao = objectBox.uploadStatusDao;

  // Observable list to store the upload state data
  RxList<UploadState> uploadStates = <UploadState>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Subscribe to the stream and update the observable list
    showLog('onInit ');

    // database.select(database.uploadState).watch().listen((data) {
    //   uploadStates.assignAll(data);
    //   _updateOverallProgress();
    //
    // });
    uploadStatusDao.streamUploadState().listen((data) {
      uploadStates.assignAll(data);
      _updateOverallProgress();
    });
  }

  void _updateOverallProgress() {
    int total = 0;
    int uploaded = 0;

    for (var uploadState in uploadStates) {
      if (uploadState.totalFilesCount != null &&
          uploadState.totalFilesCount! > 0) {
        total += uploadState.totalFilesCount!;
        uploaded +=
            uploadState.totalFilesCount! - uploadState.remainingFilesCount!;
      }
    }

    // Update the observable variables
    totalFiles.value = total;
    uploadedFiles.value = uploaded;
  }

  // Compute overall progress as a percentage (0.0 to 1.0)
  double get overallProgress =>
      totalFiles.value > 0 ? uploadedFiles.value / totalFiles.value : 1.0;
}

class AppBarForAndroid extends StatefulWidget {
  final String title;
  final bool leadingIcon;

  const AppBarForAndroid(
      {super.key, required this.leadingIcon, required this.title});

  @override
  State<AppBarForAndroid> createState() => _AppBarForAndroidState();
}

class _AppBarForAndroidState extends State<AppBarForAndroid> {
  AppUpdateController appUpdateController = AppUpdateController();
  BaseWidget<AppBarForAndroidViewModel>? baseWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //appUpdateController.checkForAppUpdate(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // appVersion = prefs.getString(updateStatusKey) ?? "";
      //showLog('addPostFrameCallback appbar $appVersion');
    });
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Change to a contrasting color
      statusBarIconBrightness: Brightness.dark, // Adjust icon color for visibility
    ));*/
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: AppBarForAndroidViewModel(),
      onModelReady: (model) async {
        await model.getInitialValues();
      },
      builder: (context, model, child) {
        return PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            color: Colors.transparent,
            child: AppBar(
              iconTheme: const IconThemeData(color: highlightedColor),
              actionsIconTheme: const IconThemeData(color: highlightedColor),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: widget.leadingIcon,
              title: Text(
                widget.title,
                style: const TextStyle(
                    color: highlightedColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                (widget.leadingIcon)
                    ? const SizedBox()
                    : getPopUpMenu(context, true),
              ],
            ),
          ),
        );
      },
    );
    return baseWidget!;
  }
}

class AppBarForAndroidViewModel extends BaseObserver {
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  AppUpdateController appUpdateController = AppUpdateController();
  String appVersion = '';

  getInitialValues() async {
    await appUpdateController.checkForAppUpdate(null);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    appVersion = prefs.getString(updateStatusKey) ?? "";
    showLog('appbar appVersion ${appVersion}');
  }
}
