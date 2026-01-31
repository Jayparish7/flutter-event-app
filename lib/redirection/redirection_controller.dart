 import 'package:get/get.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preference/preference_constants.dart';
import '../routes/1.constants/redirection_constants.dart';
import '../routes/sideMenu/side_menu_bar.dart';

class  RedirectionController {

  setRedirection(String message) async {
    showLog('setRedirection message $message');
    SharedPreferences preferences =await SharedPreferences.getInstance();
    if(message == 'Photo Selection Confirmed') {
      await preferences.setString(
          redirectionConstantsKey, sideMenuRedirectionRouteConstants);
    }

   var res =  preferences.getString(redirectionConstantsKey);
    showLog('redirectionConstantsKey message $res');

  }




  redirectionToRoute()async{
    SharedPreferences preferences =await SharedPreferences.getInstance();
     String? redirection = preferences.getString(redirectionConstantsKey);
      showLog('redirectionToRoute $redirection');
      if(redirection== sideMenuRedirectionRouteConstants){
        await removeRedirection();
        Get.to(() => const SideMenuBar(initialIndex: 1,));

      }



  }
  removeRedirection()async{
    SharedPreferences preferences =await SharedPreferences.getInstance();
    await preferences.remove(redirectionConstantsKey);
  }
 }