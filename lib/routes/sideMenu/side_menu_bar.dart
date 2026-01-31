import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/dashBoard/dashBoard_view_model.dart';
import 'package:photomall_studio_manager/routes/youtubeShorts/youtube_shorts_view_route.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/base_widget.dart';
import '../../common_widgets/common_appbar.dart';
import '../../controllers/app_update_controller.dart';
import '../../controllers/windows_activation_controller.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../notification/notification_response_model.dart';
import '../../oauth/oauth_methods.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../../redirection/redirection_controller.dart';
import '../../utils/device_util.dart';
import '../../utils/notification_utils.dart';
import '../../utils/permission_util.dart';
import '../1.constants/common_constants.dart';
import '../dashBoard/dashBoard_view_route.dart';
import '../google_reviews/google_review_view_route.dart';
import '../inbox/inbox_view_route.dart';
import '../languages/languages_view_route.dart';
import '../packages/packages_view_route.dart';
import '../studioDetail/event_ list.dart';
import '../studioList/studio_list_view.dart';
import '../studio_settings/studio_settings_view_route.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class SideMenuBar extends StatefulWidget {
  final int initialIndex;
  final bool? isMultiStudio;

  const SideMenuBar({
    super.key,
    required this.initialIndex,
    this.isMultiStudio,
  });

  @override
  State<SideMenuBar> createState() => _SideMenuBarState();
}

class _SideMenuBarState extends State<SideMenuBar> {
  final _controller = SideMenuController();
  DeviceUtil deviceUtil = DeviceUtil();
  AppUpdateController appUpdateController = AppUpdateController();
  WindowsActivationController windowsActivationController =
      WindowsActivationController();
  NotificationUtils notificationUtils = NotificationUtils();
  RedirectionController redirectionController = RedirectionController();
  int selectedIndex = 0;
  String code = '';
  String appVersion = '';
  var isActivated = true.obs;

  bool isOpen = false;
  late PageController _pageController;
  int _selectedItemPosition = 0;
  BaseWidget<DashBoardViewModel>? baseWidget;

  void navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    //windowsActivationCheck();
    _pageController = PageController();
    showLog('SideMenuBar initialIndex ${widget.initialIndex} ');
    selectedIndex = widget.initialIndex;
    _selectedItemPosition = widget.initialIndex;
    redirectionController.redirectionToRoute();

    if (Platform.isAndroid) {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        showLog('getInitialMessage side-menu ');

        redirectionController.redirectionToRoute();
      });

      requestStoragePermission();
    }

    // TODO: implement initState
    /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
    (Platform.isAndroid)
        ? null
        : appUpdateController.checkForAppUpdate(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) {
        widget.initialIndex == 1 ? navigateToPage(1) : null;
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      appVersion = prefs.getString(updateStatusKey) ?? "";

      showLog('addPostFrameCallback sidemenu $appVersion');
    });
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    if (Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        showLog('Received a message: ${message.data}');
        PendingNotificationModel? data = pendingNotificationModelFromJson(
            (json.decode(jsonEncode(message.data['values']))));
        if (message.notification != null) {
          showLog(
              'Message also contained a notification: ${message.notification}');

          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);

          flutterLocalNotificationsPlugin.show(
            id++, // Ensure `id` is defined and incremented correctly
            message.notification!.title, // Use message.notification.title
            message.notification!.body, // Use message.notification.body
            notificationDetails,
            payload: 'item x',
          );
        }
        if (message.data.isNotEmpty) {
          await notificationUtils.fetchEventDataFromApi(
              data.eventCode ?? "", data.title ?? "", data.message ?? "");
        }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        showLog('Received a message: ${message.data}');
        PendingNotificationModel? data = pendingNotificationModelFromJson(
            (json.decode(jsonEncode(message.data['values']))));
        if (message.notification != null) {
          showLog(
              'Message also contained a notification: ${message.notification}');

          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);

          flutterLocalNotificationsPlugin.show(
            id++, // Ensure `id` is defined and incremented correctly
            message.notification!.title, // Use message.notification.title
            message.notification!.body, // Use message.notification.body
            notificationDetails,
            payload: 'item x',
          );
        }
        if (message.data.isNotEmpty) {
          await notificationUtils.fetchEventDataFromApi(
              data.eventCode ?? "", data.title ?? "", data.message ?? "");
        }
        showLog('Message clicked! ${message.data}');
        // Navigate to a specific screen or handle the notification click
      });
    }
  }

  windowsActivationCheck() async {
    if (Platform.isWindows) {
      isActivated.value = await deviceUtil.isWindowsActivated();
      showLog("windowsActivationCheck ${isActivated.value}");
      if (!isActivated.value) {
        windowsActivationController.checkWindowsActivation(isActivated.value);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  AndroidNotificationChannel? channel;

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    //if (notification != null && android != null && !kIsWeb) {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(
      id++, // Ensure `id` is defined and incremented correctly
      message.notification!.title, // Use message.notification.title
      message.notification!.body, // Use message.notification.body
      notificationDetails,
      payload: 'item x',
    );

    //await TriggerNotification.triggerNotification(message, isBackGround: true);
  }

  setSideMenu(bool open) async {
    await PreferenceHelper.setBool(sideMenuOpenKey, open);
    var sideOpen = await PreferenceHelper.getBool(sideMenuOpenKey);
    isOpen = sideOpen;
    showLog('setSideMenu $sideOpen $isOpen');
  }

  @override
  Widget build(BuildContext context) {
    List<SideMenuItemData>? items = [
      SideMenuItemDataTile(
        borderRadius: borderRadius,
        hasSelectedLine: isSelectedLine,
        highlightSelectedColor: photomallBodyColor,
        selectedTitleStyle: textStyle,
        titleStyle: unSelectedTextStyle,
        hoverColor: bottomNavBGColor,
        isSelected: selectedIndex == 0,
        onTap: () async {
          setState(() {
            selectedIndex = 0;
          });
        },
        title: S.of(context).dashboard,
        icon: const Icon(Icons.dashboard),
      ),
      SideMenuItemDataTile(
        hoverColor: bottomNavBGColor,
        borderRadius: borderRadius,
        hasSelectedLine: isSelectedLine,
        highlightSelectedColor: photomallBodyColor,
        selectedTitleStyle: textStyle,
        titleStyle: unSelectedTextStyle,
        isSelected: selectedIndex == 2,
        onTap: () async {
          code = await getStudioCode();

          setState(() {
            selectedIndex = 2;
          });
        },
        title: S.of(context).events,
        icon: const Icon(Icons.event),
      ),
      SideMenuItemDataTile(
        hoverColor: bottomNavBGColor,
        borderRadius: borderRadius,
        hasSelectedLine: isSelectedLine,
        highlightSelectedColor: photomallBodyColor,
        selectedTitleStyle: textStyle,
        titleStyle: unSelectedTextStyle,
        isSelected: selectedIndex == 3,
        onTap: () async {
          setState(() {
            selectedIndex = 3;
          });
        },
        title: S.of(context).packages,
        icon: const Icon(Icons.shopping_bag),
      ),
      SideMenuItemDataTile(
        hoverColor: bottomNavBGColor,
        borderRadius: borderRadius,
        hasSelectedLine: isSelectedLine,
        highlightSelectedColor: photomallBodyColor,
        selectedTitleStyle: textStyle,
        titleStyle: unSelectedTextStyle,
        isSelected: selectedIndex == 4,
        onTap: () async {
          setState(() {
            selectedIndex = 4;
          });
        },
        title: S.of(context).reviews,
        icon: const Icon(Icons.reviews),
      ),
      SideMenuItemDataTile(
        hoverColor: bottomNavBGColor,
        borderRadius: borderRadius,
        hasSelectedLine: isSelectedLine,
        highlightSelectedColor: photomallBodyColor,
        selectedTitleStyle: textStyle,
        titleStyle: unSelectedTextStyle,
        isSelected: selectedIndex == 5,
        onTap: () async {
          setState(() {
            selectedIndex = 5;
          });
        },
        title: S.of(context).studio_settings,
        icon: const Icon(Icons.settings),
      ),
    ];

    baseWidget = BaseWidget(
      model: DashBoardViewModel(
          progressController: Get.put(ProgressController()), context: context),
      onModelReady: (model) async {
        var open = await PreferenceHelper.getBool(sideMenuOpenKey);
        isOpen = open;
        showLog('pref open $open');
        (Platform.isAndroid) ? await model.getInitialData(context) : null;
        (Platform.isAndroid) ? await requestStoragePermission() : null;
      },
      builder: (context, model, child) {
        return WithForegroundTask(
            child: WillPopScope(
          onWillPop: () async {
            (Platform.isAndroid)
                ? SystemChannels.platform
                    .invokeMethod<void>('SystemNavigator.pop')
                : null;
            return true;
          },
          child: Scaffold(
            appBar: (Platform.isAndroid && _selectedItemPosition != 4)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(75),
                    child: AppBarForAndroid(
                      leadingIcon: false,
                      title: getAppbarTitle(),
                    ),
                  )
                : null,
            body: (Platform.isAndroid)
                ? AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: <Widget>[
                        DashboardView(isMultiStudio: widget.isMultiStudio),
                        EventListView(studioCode: code),
                        InboxViewRoute(isSideMenuOpen: isOpen),
                        const StudioSettingsViewRoute(),
                        //const YoutubeShortsViewRoute(),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      SideMenu(
                          key: GlobalKey(),
                          backgroundColor: photomallColor,
                          controller: _controller,
                          hasResizerToggle: true,
                          // mode:
                          //isOpen ? SideMenuMode.auto : SideMenuMode.compact,
                          resizerData: ResizerData(
                              resizerWidth: 5,
                              resizerColor: const Color(photomallYellow)
                                  .withValues(alpha: .3),
                              resizerHoverColor: const Color(photomallYellow)),
                          hasResizer: true,
                          builder: (data) {
                            showLog('SideMenu $isOpen');
                            isOpen = data.isOpen;
                            setSideMenu(data.isOpen);
                            return SideMenuData(
                              animHeader: const SideMenuItemsAnimationData(
                                  duration: Duration(seconds: 5)),
                              header: Padding(
                                  padding: Platform.isAndroid
                                      ? const EdgeInsets.only(top: 25)
                                      : const EdgeInsets.all(15.0),
                                  child: Image.asset(
                                    'assets/images/event_manager_logo.png',
                                    color: photomallBodyColor,
                                  )),
                              items: items,
                              footer: Column(
                                children: [
                                  // (Platform.isWindows &&
                                  //         !isActivated.value &&
                                  //         isOpen)
                                  //     ? Tooltip(
                                  //         message: "Windows Not Activated",
                                  //         decoration: toolTipDecoration,
                                  //         child: FloatingActionButton.extended(
                                  //           heroTag: UniqueKey(),
                                  //           backgroundColor: Colors.transparent,
                                  //           foregroundColor: Colors.transparent,
                                  //           elevation: 0,
                                  //           focusColor: Colors.transparent,
                                  //           splashColor: Colors.transparent,
                                  //           hoverColor: Colors.grey,
                                  //           hoverElevation: 1,
                                  //           onPressed: () async {
                                  //             Get.to(
                                  //                 const WindowsActivationAlertScreen());
                                  //           },
                                  //           icon: Image.asset(
                                  //             "assets/images/win_not_active.png",
                                  //             height: 25,
                                  //           ),
                                  //           label: const Text(
                                  //             "Windows Not Activated",
                                  //             style: TextStyle(
                                  //                 color: photomallBodyColor,
                                  //                 fontSize: 16),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : const SizedBox(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: (isOpen) ? 0 : 20.0),
                                    child: Tooltip(
                                      message: S.of(context).logout,
                                      decoration: toolTipDecoration,
                                      child: FloatingActionButton.extended(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.transparent,
                                        elevation: 0,
                                        focusColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.grey,
                                        hoverElevation: 1,
                                        onPressed: () {
                                          OauthMethods.setLogout(context);
                                        },
                                        icon: const Icon(
                                          Icons.logout,
                                          color: photomallBodyColor,
                                        ),
                                        label: (isOpen)
                                            ? Text(
                                                S.of(context).logout,
                                                style: const TextStyle(
                                                    color: photomallBodyColor,
                                                    fontSize: 18),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                  isOpen
                                      ? SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'App Version:${(Platform.isAndroid) ? androidAppVersionCode : appVersionCode}',
                                                style: const TextStyle(
                                                    color: photomallBodyColor),
                                              ),
                                              (appVersion == '1')
                                                  ? Tooltip(
                                                      message:
                                                          S.of(context).update,
                                                      decoration:
                                                          toolTipDecoration,
                                                      child:
                                                          FloatingActionButton
                                                              .extended(
                                                        heroTag: UniqueKey(),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        foregroundColor:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        focusColor:
                                                            Colors.transparent,
                                                        splashColor:
                                                            Colors.transparent,
                                                        hoverColor: Colors.grey,
                                                        hoverElevation: 1,
                                                        onPressed: () async {
                                                          await appUpdateController
                                                              .updateCheck(
                                                                  context);
                                                        },
                                                        icon: const Icon(
                                                          Icons.update,
                                                          color:
                                                              photomallBodyColor,
                                                        ),
                                                        label: Text(
                                                          S.of(context).update,
                                                          style: const TextStyle(
                                                              color:
                                                                  photomallBodyColor,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Image.asset(
                                      'assets/images/poweredBy.png',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      Expanded(child: _getPage(selectedIndex)),
                    ],
                  ),
            backgroundColor: (Platform.isAndroid)
                ? (_selectedItemPosition != 4)
                    ? Colors.white
                    : Colors.black
                : Colors.transparent,
            bottomNavigationBar: (Platform.isAndroid)
                ? SnakeNavigationBar.color(
                    height: 65,
                    backgroundColor: (_selectedItemPosition == 4)
                        ? Colors.white
                        : highlightSelectedColor,
                    shadowColor: Colors.white,
                    behaviour: snakeBarStyle,
                    snakeShape: snakeShapeForEventDetailView,
                    shape: bottomBarShape,
                    padding: padding,
                    showSelectedLabels: true,
                    //showUnselectedLabels: true,

                    ///configuration for SnakeNavigationBar.color
                    snakeViewColor: highlightSelectedColor,
                    selectedItemColor: snakeShape == SnakeShape.indicator
                        ? selectedColor
                        : null,
                    unselectedItemColor: unselectedColor,
                    currentIndex: _selectedItemPosition,
                    onTap: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    items: const [
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          //color: highlightSelectedColor,
                        ),
                        icon: Icon(
                          Icons.dashboard,
                          color: Colors.white,
                        ),
                        label: 'Dashboard',

                      ),
                      BottomNavigationBarItem(
                          activeIcon: Icon(
                            Icons.event,
                            color: Colors.white,
                            //color: highlightSelectedColor,
                          ),
                          icon: Icon(
                            Icons.event,
                            color: Colors.white,
                          ),
                          label: 'Events'),
                      BottomNavigationBarItem(
                          activeIcon: Icon(
                            Icons.message,
                            color: Colors.white,
                            //color: highlightSelectedColor,
                          ),
                          icon: Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          label: 'Inbox'),
                      BottomNavigationBarItem(
                          activeIcon: Icon(
                            Icons.settings,
                            color: Colors.white,
                            //color: highlightSelectedColor,
                          ),
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          label: 'Settings'),
                      /*BottomNavigationBarItem(
                            activeIcon: Icon(
                              Icons.play_arrow,
                              color: highlightSelectedColor,
                            ),
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: 'search',
                          ),*/
                    ],
                    selectedLabelStyle: const TextStyle(
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 10,),
                  )
                : null,
          ),
        ));
      },
    );
    return baseWidget!;
  }

  String getAppbarTitle() {
    switch (_selectedItemPosition) {
      case 0:
        return 'Event Manager';
      case 1:
        return S.of(context).events;
      case 2:
        return S.of(context).inbox;
      case 3:
        return S.of(context).studio_settings;
      default:
        return '';
    }
  }

  void _onPageChanged(int page) {
    containerColor = containerColors[page];
    switch (page) {
      case 0:
        setState(() {
          showLog('_selectedItemPosition $_selectedItemPosition');
          _selectedItemPosition = 0;
          // snakeBarStyle = SnakeBarBehaviour.floating;
          //snakeShape = SnakeShape.circle;
          // padding = const EdgeInsets.all(12);
          // bottomBarShape =
          //  RoundedRectangleBorder(borderRadius: BorderRadius.circular(25));
        });
        break;
      case 1:
        setState(() {
          _selectedItemPosition = 1;
          /*snakeBarStyle = SnakeBarBehaviour.pinned;
          snakeShape = SnakeShape.circle;
          padding = EdgeInsets.zero;
          bottomBarShape = RoundedRectangleBorder(borderRadius: _borderRadius);
          showSelectedLabels = false;
          showUnselectedLabels = false;*/
        });
        break;

      case 2:
        setState(() {
          _selectedItemPosition = 2;
        });
        break;
      /*  case 3:
        setState(() {
          _selectedItemPosition = 3;
        });*/
      case 3:
        setState(() {
          _selectedItemPosition = 3;
        });

        break;
    }
  }

  Widget _getPage(int index) {
    showLog("_getPage $index");
    switch (index) {
      case 0:
        return DashboardView(
            isMultiStudio:
                widget.isMultiStudio); // Replace with your actual widget
      case 1:
        return InboxViewRoute(
            isSideMenuOpen: isOpen); // Replace with your actual widget
      case 2:
        return EventListView(studioCode: code);
      case 3:
        return const PackagesViewRoute();
      case 4:
        return const GoogleReviewViewRoute();
      case 5:
        return const StudioSettingsViewRoute();
      //case 6:
      //return const YoutubeShortsViewRoute();

      default:
        return Container(); // Default to an empty container or a not found page
    }
  }

  Future<String> getStudioCode() async {
    return await PreferenceHelper.getString(eventCodePreferenceKey);
  }
}

BorderRadius borderRadius = BorderRadius.circular(10);
bool isSelectedLine = false;
Color highlightSelectedColor = const Color(photomallYellow);
TextStyle textStyle = const TextStyle(color: photomallColor);
TextStyle unSelectedTextStyle = const TextStyle(color: photomallBodyColor);

/*

class CommonSideMenuBar extends StatefulWidget {
  final List<SideMenuItemDataTile> items;
  const CommonSideMenuBar({super.key, required this.items});


  @override
  State<CommonSideMenuBar> createState() => _CommonSideMenuBarState();
}

class _CommonSideMenuBarState extends State<CommonSideMenuBar> {
  final _controller = SideMenuController();
  int selectedIndex = 0;
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          SideMenu(
            backgroundColor: const Color(0xFFd2e6f7),
            controller: _controller,
            mode: SideMenuMode.auto,
            builder: (data) => SideMenuData(animHeader: SideMenuItemsAnimationData(duration: Duration(seconds: 5)),
              header: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  'assets/images/event_manager_logo.png',

                ) .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                  duration: 1200.ms,
                  color: Colors.blue,
                )
                    .animate() // this wraps the previous Animate in another Animate
                    .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad),
              ),
              items: widget.items,
              footer: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/images/poweredBy.png',
                ),
              ),
            ),
          ),
          Expanded(
            child: _getEventOptionsRoute(selectedIndex),
          ),
        ],
      );

  }

    Widget _getEventOptionsRoute(int index) {
      switch (index) {
        case 0:
          return const StudioUserListRoute(); // Replace with your actual widget
        case 1:
          return EventListView(
              studioCode: code); // Replace with your actual widget
        default:
          return Container(); // Default to an empty container or a not found page
      }
    }

  Future<String> getStudioCode() async {
    return await PreferenceHelper.getString(eventCodePreferenceKey);
  }
}*/
