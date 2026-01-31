//const String applicationCodeLinux = "0widrznk";
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';

const String applicationCodeLinux = "0widrznk";
const String applicationCodeWindows = "tc8tfjui";
const String applicationCodeMac = "ezf7wtjj";
const String applicationCodeAndroid = "edtr3yui";

const int androidAppVersionCode = 14;
const int appVersionCode = 27;
const int photomallYellow = 0xFF1D1D1F;
const Color photomallBgColor = Colors.transparent;
const Color photomallColor = Color(0xFF1D1D1F);
const Color photomallSecondaryColor = Color(0x0ff1d1d1);
const Color photomallBodyColor = Color(0xFFFffffff);
const Color bottomNavBGColor = Colors.grey;
const Color highlightedColor = Color(photomallYellow);

ShapeBorder? bottomBarShape = const RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(25)),
);
SnakeBarBehaviour snakeBarStyle = SnakeBarBehaviour.floating;
EdgeInsets padding = const EdgeInsets.all(8);

SnakeShape snakeShape = SnakeShape.circle;
  SnakeShape snakeShapeForEventDetailView = SnakeShape.rectangle;
bool showSelectedLabels = true;
bool showUnselectedLabels = true;
Color selectedColor = bottomNavBGColor;
Color unselectedColor = Colors.black;
BoxDecoration toolTipDecoration = BoxDecoration(
    color: const Color(photomallYellow),
    borderRadius: BorderRadius.circular(5));
BoxDecoration alertToolTipDecoration = BoxDecoration(
    color:  Colors.red,
    borderRadius: BorderRadius.circular(5));
BorderRadius dropdownButtonFormField = BorderRadius.circular(10);
Gradient selectedGradient =
    const LinearGradient(colors: [Colors.red, Colors.amber]);
Gradient unselectedGradient =
    const LinearGradient(colors: [Colors.red, Colors.blueGrey]);
final file = DirectoryPicker()..title = 'Select a directory';
Color? containerColor;
List<Color> containerColors = [
  const Color(0xFFFDE1D7),
  const Color(0xFFE4EDF5),
  const Color(0xFFE7EEED),
  const Color(0xFFF4E4CE),
];
const int resendOTPDelay = 60;
const String appUpdate =
    "To experience the exciting new features and improvements, make sure to update the App to the latest version by clicking the 'Update' button below";
const bool isDeveloperMode = true;
const String photomallLogo = 'assets/images/photomall_logo.png';
const String photomallCameraLogo = 'assets/images/loading.png';
const String appName = 'Photomall Event Manager';
const String publicPath = 'https://cdn.photomall.in/photomall/';

const localDirectoryListenTime = Duration(seconds: 5);
final GlobalKey<ScaffoldMessengerState> snackBarKey =
    GlobalKey<ScaffoldMessengerState>();
List<String> streamingAlbums = [];
List<String> compressedEvents = [];
List<String>  isUploadingFolders = [];
String driveAccessToken = '';
bool isIsolate = false;
// show log only in developer mode
showLog(message) {
  if (isDeveloperMode) {
    print(message);
  } else {}
}


