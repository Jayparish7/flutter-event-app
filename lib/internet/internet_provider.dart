import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
class ConnectivityProvider with ChangeNotifier{
  bool? _isOnline;
  bool get isOnline => _isOnline ?? true;

  ConnectivityProvider(){
    Connectivity connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async{
    /*  showLog("the inter net connection");
      showLog("the inter net connection ${result[0]}");
      if(result.contains(ConnectivityResult.none)){
        _isOnline = false;
        notifyListeners();
      }else{
        _isOnline = true;
        notifyListeners();
      }*/
    });
  }
}


class InterNetProvider{
  static Future<void> waitForInternet() async {
    Completer<void> completer = Completer<void>();
    Connectivity connectivity = Connectivity();

    StreamSubscription? subscription;
    subscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      if (!result.contains(ConnectivityResult.none)) {
        showLog("Internet is back!");
        completer.complete(); // Resolve the future when the internet is restored
        subscription?.cancel(); // Stop listening once internet is back
      }
    });

    // If already connected, resolve immediately
    var connectivityResult = await connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      showLog("Already connected!");
      subscription.cancel();
      return;
    }

    showLog("No internet, waiting...");
    return completer.future; // Wait until internet is restored
  }
}