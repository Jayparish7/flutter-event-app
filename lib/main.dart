import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connected/connected.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:photomall_studio_manager/internet/internet_provider.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/process_supervisor.dart';
import 'package:photomall_studio_manager/redirection/redirection_controller.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/redirection_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/custom_route.dart';
import 'package:photomall_studio_manager/routes/dashBoard/dashBoard_view_model.dart';
import 'package:photomall_studio_manager/routes/sideMenu/side_menu_bar.dart';
import 'package:photomall_studio_manager/utils/notification_utils.dart';
import 'package:photomall_studio_manager/utils/permission_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_native_image_compress/simple_native_image_compress.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import 'api/api_call.dart';
import 'background_task/background_task_handler.dart';
import 'common_widgets/common_appbar.dart';
import 'database/model/app_db.dart';
import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'image_uploader/image_file_uploader.dart';
import 'notification/notification_response_model.dart';

/// Provides access to the ObjectBox Store throughout the app.
late ObjectBox objectBox;
int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse notificationResponse) async {
  // ignore: avoid_print
  RedirectionController redirectionController = RedirectionController();

  showLog('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');

  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    showLog(
        'notification action tapped with input: ${notificationResponse.input}');
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(
      redirectionConstantsKey, sideMenuRedirectionRouteConstants);
  redirectionController.redirectionToRoute();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationUtils notificationUtils = NotificationUtils();

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
  PendingNotificationModel? data = pendingNotificationModelFromJson(
      (json.decode(jsonEncode(message.data['values']))));
  //if(message.data.isNotEmpty){
  await notificationUtils.fetchEventDataFromApi(
      data.eventCode ?? "", data.title ?? "", data.message ?? "");

  //}

  //await TriggerNotification.triggerNotification(message, isBackGround: true);
}

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(BackgroundTaskHandler());
}
late ProcessSupervisor uploadSupervisor;

void main() async {
 /* print('🚀 Dart version: ${Platform.version}');
  uploadSupervisor =  ProcessSupervisor(
    'UploadWorker',
    'dart',
    ['run', 'lib/upload/upload_main.dart'],
  );
  await uploadSupervisor.start();*/

  (Platform.isAndroid) ? null : await NativeImageCompress.init();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    showLog('main flutter error details $details');
    //  call api only release mode

    if (true) {
      Api api = Api(null);
      api.callChatNotifier(
        exception: '${details.exception}',
        errorDetail: '${details.stack} \n App version: $appVersionCode',
      );
    }
    showLog(
        'Main :: FlutterError.onError :: details :: ${details.exception} => ${details.stack},//// ${details.library}');
  };

  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set the preferred status bar style
 // ImageFileUploader().runInIsolates();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    FlutterForegroundTask.initCommunicationPort();

    showLog('fcm  token $fcmToken');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  showLog(' notification step 1 :: ');
  if (Platform.isMacOS || Platform.isLinux || Platform.isAndroid) {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
    }

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      defaultPresentSound: true,
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
      /* onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },*/
      notificationCategories: darwinNotificationCategories,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('assets/images/loading.png'),
      defaultSuppressSound: true,
    );
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/loading');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux,
            android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Photomall Event Manager');
      /*   Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;*/
    });
    setWindowMaxSize(const Size(7680, 4320));
    setWindowMinSize(const Size(768, 384));
  }
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kDebugMode) {
      showLog(details.toString());
    }
  };
  try {
    await PreferenceHelper.removePreference(isIsolateRunningPreferenceKey);
  } catch (e) {
    showLog(e);
  }
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    getDefaultLanguage();

    (!Platform.isAndroid) ? _requestPermissions() : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      updateFcmToken();
      //_requestPermissionForAndroid();
    });
  }

  updateFcmToken() async {
    bool isUpdateTokenToApi =
        await PreferenceHelper.getBool(isUpdateTokenToApiPreferenceKey);
    bool isDeviceRegister =
        await PreferenceHelper.getBool(isDeviceRegisteredPreferenceKey);
    //  String? token = await FirebaseMessaging.instance.getToken();

    if (isUpdateTokenToApi == false && isDeviceRegister && Platform.isAndroid) {
      String? token = await FirebaseMessaging.instance.getToken();
      showLog('tokentokensdsdsddd: $token');
      if (token != null && token != 'BLACKLISTED') {
        Api(null).callUpdateFcmToken(context, token);
      }
      PreferenceHelper.setBool(isUpdateTokenToApiPreferenceKey, true);
    }
    if (Platform.isAndroid) {
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        PreferenceHelper.getBool(isDeviceRegisteredPreferenceKey).then((value) {
          if (value) {
            if (token != 'BLACKLISTED') {
              Api(context).callUpdateFcmToken(context, token);
            }
          }
        });
      });
    }
  }

  Future<String> getDefaultLanguage([Locale? newLocale]) async {
    //await PreferenceHelper.removePreference(studioSelectedKey);

    var prefs = await SharedPreferences.getInstance();
    languageSymbol = prefs.getString(languageSymbolKey) ?? 'en';
    showLog('getDefaultLanguage === >$languageSymbol');

    if (languageSymbol == null || languageSymbol == '') {
      languageSymbol = 'en';
    }

    setState(() {
      S.load(Locale(languageSymbol!));
    });
    return languageSymbol;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  final ValueNotifier<Object?> _receivedTaskData = ValueNotifier(null);

  Future<void> _requestPermissionForAndroid() async {
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
      showLog(
          '_requestPermissionForAndroid ${await FlutterForegroundTask.canDrawOverlays}');

      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
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

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  var languageSymbol = 'en';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: true),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(
            create: (context) => DashBoardViewModel(
                progressController: Get.put(ProgressController()),
                context: context)),
      ],
      child: Consumer<ConnectivityProvider>(builder: (context, model, widget) {
        showLog("rebuild");
        return Sizer(builder: (context, orientation, screenType) {
          return GetMaterialApp(
            scaffoldMessengerKey: snackBarKey,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],

            supportedLocales: S.delegate.supportedLocales,
            theme: ThemeData(
                fontFamily: 'ProductSans',
                textTheme: Theme.of(context)
                    .textTheme
                    .apply(fontFamily: 'ProductSans')),
            scrollBehavior:
                const MaterialScrollBehavior().copyWith(scrollbars: false),
            onGenerateRoute: CustomRoute.generateRoute,
            initialRoute: RoutePaths.splash,
            locale: Locale(languageSymbol),
            debugShowCheckedModeBanner: false,
            title: 'Photomall Event Manager',
          );
        });
      }),
    );
  }
}

/*class EscapeKeyListener extends StatelessWidget {
  final Widget child;

  EscapeKeyListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          // Handle ESC key press here
          showLog('RawKeyboardListener');

          SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
        }
      },
      child: child,
    );
  }
}*/

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
