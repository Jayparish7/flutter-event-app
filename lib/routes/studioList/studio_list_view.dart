import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_hover_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/studioDetail/event_argument_model.dart';
import 'package:photomall_studio_manager/routes/studioList/studio_list_controller.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../preference/preference_constants.dart';
import '../dashBoard/dashBoard_view_model.dart';
import '../sideMenu/side_menu_bar.dart';

class StudioUserListRoute extends StatefulWidget {
  const StudioUserListRoute({Key? key}) : super(key: key);

  @override
  State<StudioUserListRoute> createState() => _StudioUserListRouteState();
}

class _StudioUserListRouteState extends State<StudioUserListRoute>
    with SingleTickerProviderStateMixin {
  BaseWidget<StudioListController>? baseWidget;
  StudioListController controller = StudioListController();

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<StudioListController>(
      model: StudioListController(context: context),
      onModelReady: (model) => model.getInitialValues(),
      builder: (context, model, child) {
        return Container(
            decoration: const BoxDecoration(
                color: photomallBodyColor,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/studio1.png',
                  ),
                  //fit: BoxFit.contain,
                )),
            child: eventListView(model));
      },
    );
    return baseWidget!;
  }

  ontap() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String? result = (Platform.isWindows)
        ? file.getDirectory()?.path
        : await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      String directory = result;
      List<FileSystemEntity> files = Directory("$directory/").listSync();
      // List<File> files = result.map((path) => File(path!)).toList();
      for (FileSystemEntity file in files) {
        showLog("hovered ${file.path}");
      }
    } else {
      // Do something else...
    }
  }

  Widget eventListView(StudioListController model) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CommonAppBar(
        automaticallyImplyLeading: false,
        title: "Studios",
        isCenterTitle: true,
        isMainPage: true,
      ),
      body: IgnorePointer(
        ignoring: model.isLoading,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(child: eventGrid(model, context)),
            model.isLoading
                ? const Center(child: PhotomallProgress())
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  eventGrid(StudioListController model, BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Wrap(
            children: List.generate(model.studios.length, (index) {
          return InkWell(
            hoverColor: Colors.transparent,
            onTap: () async {
              var dashBoardViewModel =
                  Provider.of<DashBoardViewModel>(context, listen: false);
              await PreferenceHelper.setInt(studioIndexKey, index);
              await PreferenceHelper.setBool(studioSelectedKey, true);
              /*Navigator.pushNamed(
                context,
                RoutePaths.eventList,
                arguments: EventArguments(model.studios[index].code),
              );*/
              await dashBoardViewModel.callStudioIndex();
              dashBoardViewModel.isLoading =false;
              dashBoardViewModel.setBusy(false);
             /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SideMenuBar(
                            isMultiStudio: true,
                            initialIndex: 0,
                          )));*/
              Navigator.pop(context);
            },
            child: SizedBox(
                width: isMobile ? size.width * 0.45 : size.width * .45,
                child: listTile(model, index)),
          );
        })),
      ),
    );
  }

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  listTile(StudioListController model, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 20),
      child: Commonhovercard(
        child: Stack(
          /*  crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,*/
          // crossAxisAlignment: CrossAxisAlignment.stretch, //add this
          children: <Widget>[
            (model.studios[index].imageURL != '')
                ? Image.network(
                    '${model.publicPath}/${model.studios[index].imageURL}',
                    //fit: BoxFit.cover,
                  )
                : Image.asset('assets/images/forest.jpg'),
            /*   Positioned(top: 10,
              child: SizedBox(
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: UniqueText(
                    text: model.studios[index].name,
                    isTitle: true,
                  ),
                ),
              ),
            ),
            Positioned(bottom: 10,right: 40,
              child: SizedBox(
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: UniqueText(
                      text: "Role : ${model.studios[index].role}",
                      isTitle: true,

                    ),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
