import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photomall_studio_manager/common_widgets/no_internet_widget.dart';
import 'package:photomall_studio_manager/internet/internet_provider.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/album/album_list.dart';
import 'package:photomall_studio_manager/routes/album/album_list_arguments.dart';
import 'package:photomall_studio_manager/routes/albumDetail/album_detail.dart';
import 'package:photomall_studio_manager/routes/albumDetail/album_detail_arguments.dart';
import 'package:photomall_studio_manager/routes/appUpdation/update_argument_model.dart';
import 'package:photomall_studio_manager/routes/appUpdation/updation_view.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/event_detailed_view.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/eventdetail_arguments_model.dart';
import 'package:photomall_studio_manager/routes/eventSubView/event_sub_view_arguments.dart';
import 'package:photomall_studio_manager/routes/eventSubView/event_subview_route.dart';
import 'package:photomall_studio_manager/routes/login/login_view.dart';
import 'package:photomall_studio_manager/routes/sideMenu/side_menu_bar.dart';
import 'package:photomall_studio_manager/routes/splashScreen/splash_view.dart';
import 'package:photomall_studio_manager/routes/studioDetail/event_%20list.dart';
import 'package:photomall_studio_manager/routes/studioDetail/event_argument_model.dart';
import 'package:photomall_studio_manager/routes/studioList/studio_list_view.dart';
import 'package:provider/provider.dart';

class CustomRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final isOnLine = Provider.of<ConnectivityProvider>(context).isOnline;
      showLog("the internet onlin $isOnLine");
     /* if (!isOnLine) {
       // return const NoInternet();
      } else */{
        switch (settings.name) {
          case RoutePaths.splash:
            return const SplashView();
          case RoutePaths.update:
            final AppUpdateStatus arguments =
                settings.arguments as AppUpdateStatus;
            return AppUpdate(
              status: arguments.status,
            );
          case RoutePaths.studioList:
            return const StudioUserListRoute();
          case RoutePaths.login:
            return const LoginView();
            case RoutePaths.sideMenuView:
              final SideMenuArguments argument =
              settings.arguments as SideMenuArguments;
            return  SideMenuBar(initialIndex: argument.initialIndex ,);
          case RoutePaths.eventList:
            final EventArguments arguments =
                settings.arguments as EventArguments;
            return /*ShowCaseWidget(
                onStart: (index, key) {
                  showLog('onStart: $index, $key');
                },
                onComplete: (index, key) {
                  showLog('onComplete: $index, $key');
                  if (index == 4) {
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.light.copyWith(
                        statusBarIconBrightness: Brightness.dark,
                        statusBarColor: Colors.white,
                      ),
                    );
                  }
                },
                blurValue: 1,
                builder: (context) => */ EventListView(studioCode: arguments.studioCode);
        //);
          case RoutePaths.eventSubView:
            final EventSubViewArguments arguments =
                settings.arguments as EventSubViewArguments;
            return /*ShowCaseWidget(
              onStart: (index, key) {
                showLog('onStart: $index, $key');
              },
              onComplete: (index, key) {
                showLog('onComplete event sub view: $index, $key');
                if (index == 4) {
                  SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle.light.copyWith(
                      statusBarIconBrightness: Brightness.dark,
                      statusBarColor: Colors.white,
                    ),
                  );
                }
              },
              blurValue: 1,
              builder: (context) =>*/ EventSubView(
              studioCode: arguments.studioCode,
              eventCode: arguments.eventCode,
              eventName: arguments.eventName,
           // )
        );
          case RoutePaths.albumList:
            final AlbumListArguments arguments =
                settings.arguments as AlbumListArguments;
            return AlbumList(
              studioCode: arguments.studioCode,
              eventCode: arguments.eventCode,
              eventName: arguments.eventName,
            );
          case RoutePaths.albumDetail:
            final AlbumDetailArguments arguments =
                settings.arguments as AlbumDetailArguments;
            return AlbumDetail(
              studioCode: arguments.studioCode,
              albumCode: arguments.albumCode,
              path: arguments.path,
              eventCode: arguments.eventCode??'',
            );
          case RoutePaths.eventDetailed:
            final EventDetailArguments arguments =
                settings.arguments as EventDetailArguments;
            return EventDetailView(
              eventDetailedArguments: arguments,
            );

          default:
            return Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            );
        }
      }
    });
  }
}
