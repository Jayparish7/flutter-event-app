import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_hover_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/database/dao/folder_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/album/album_list_arguments.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/eventdetail_arguments_model.dart';
import 'package:photomall_studio_manager/routes/eventSubView/event_sub_view_model.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../album/album_list.dart';
import '../eAlbumDetail/event_detailed_view.dart';
import '../eventSettings/event_settings_view_route.dart';
import '../shareView/share_view_route.dart';
import '../sideMenu/side_menu_bar.dart';
import 'event_sub_view_arguments.dart';

class EventSubView extends StatefulWidget implements PreferredSizeWidget {
  final String eventCode;
  final String studioCode;
  final String eventName;

  const EventSubView({
    Key? key,
    required this.eventCode,
    required this.studioCode,
    required this.eventName,
  }) : super(key: key);

  @override
  State<EventSubView> createState() => _EventSubViewState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _EventSubViewState extends State<EventSubView> {
  BaseWidget<EventSubViewController>? baseWidget;
  Folder? folder;
  final folderModelDao = objectBox.folderModelDao;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLog("Event detailed view");
  }

  final PageController _pageController = PageController();
  int selectedItemPosition = 0;

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<EventSubViewController>(
      model: EventSubViewController(context: context),
      onModelReady: (model) async {
        await model.getInitialValues(widget.eventCode, widget.studioCode);

        folder = await folderModelDao
            .getFoldersByEventAndParentNull(widget.eventCode);
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            // Navigator.pop(context);
            return true;
          },
          child: Scaffold(
            backgroundColor:
                (Platform.isAndroid) ? Colors.white : photomallBodyColor,
            appBar: (Platform.isAndroid)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(75),
                    child: AppBarForAndroid(
                      leadingIcon: true,
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
                        AlbumList(
                          studioCode: widget.studioCode,
                          eventCode: widget.eventCode,
                          eventName: widget.eventName,
                        ),
                        ShareView(
                          eventCode: widget.eventCode,
                          eventName: widget.eventName,
                        )
                      ],
                    ),
                  )
                : Row(
                    children: [
                      SideMenu(
                        controller: model.controller,
                        backgroundColor: photomallColor,
                        mode: SideMenuMode.auto,
                        builder: (data) => SideMenuData(
                          animHeader: const SideMenuItemsAnimationData(
                              duration: Duration(seconds: 5)),
                          header: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: photomallBodyColor,
                                  )),
                              Image.asset(
                                'assets/images/event_manager_logo.png',
                                height: 55,
                                width: 180,
                                color: photomallBodyColor,
                              ),
                            ],
                          ),
                          items: [
                            SideMenuItemDataTile(
                              hoverColor: bottomNavBGColor,
                              borderRadius: borderRadius,
                              hasSelectedLine: isSelectedLine,
                              highlightSelectedColor: photomallBodyColor,
                              selectedTitleStyle: textStyle,
                              titleStyle: unSelectedTextStyle,
                              isSelected: model.selectedIndex == 0,
                              onTap: () {
                                setState(() {
                                  model.selectedIndex = 0;
                                });
                              },
                              title: S.of(context).photo_selection,
                              icon: const Icon(Icons.check_circle),
                            ),
                            SideMenuItemDataTile(
                              hoverColor: bottomNavBGColor,
                              borderRadius: borderRadius,
                              hasSelectedLine: isSelectedLine,
                              highlightSelectedColor: photomallBodyColor,
                              selectedTitleStyle: textStyle,
                              titleStyle: unSelectedTextStyle,
                              isSelected: model.selectedIndex == 1,
                              onTap: () async {


                                folder = await folderModelDao
                                    .getFoldersByEventAndParentNull(
                                        widget.eventCode);

                                setState(() {
                                  model.selectedIndex = 1;
                                });
                              },
                              title: S.of(context).media,
                              icon: const Icon(Icons.photo_library_sharp),
                            ),
                            SideMenuItemDataTile(
                              hoverColor: bottomNavBGColor,
                              borderRadius: borderRadius,
                              hasSelectedLine: isSelectedLine,
                              highlightSelectedColor: photomallBodyColor,
                              selectedTitleStyle: textStyle,
                              titleStyle: unSelectedTextStyle,
                              isSelected: model.selectedIndex == 2,
                              onTap: () async {
                                setState(() {
                                  model.selectedIndex = 2;
                                });
                              },
                              title: S.of(context).share,
                              icon: const Icon(Icons.share),
                            ),
                          ],
                          footer: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              'assets/images/poweredBy.png',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: _getEventOptionsRoute(
                              model.selectedIndex, model)),
                    ],
                  ),
            bottomNavigationBar: (Platform.isAndroid)
                ? SnakeNavigationBar.color(
                    height: 65,
                    backgroundColor: selectedColor,
                    shadowColor: Colors.white,
                    // height: 80,
            showSelectedLabels: true,
                    showUnselectedLabels: true,
                    behaviour: snakeBarStyle,
                    snakeShape: snakeShapeForEventDetailView,
                    shape: bottomBarShape,
                    padding: padding,

                    ///configuration for SnakeNavigationBar.color
                    snakeViewColor: highlightSelectedColor,
                    selectedItemColor: snakeShape == SnakeShape.indicator
                        ? selectedColor
                        : null,
                    unselectedItemColor: unselectedColor,

                    currentIndex: selectedItemPosition,
                    onTap: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    items: [
                      BottomNavigationBarItem(
                          activeIcon: const Icon(
                            Icons.photo_library_sharp,
                            color: Colors.white,
                          ),
                          icon: Icon(
                            Icons.photo_library_sharp,
                            color: highlightSelectedColor,
                          ),
                          label: 'Media'),
                      BottomNavigationBarItem(
                          activeIcon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          icon: Icon(
                            Icons.share,
                            color: highlightSelectedColor,
                          ),
                          label: 'Share'),
                    ],
                    selectedLabelStyle: const TextStyle(
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 10),
                  )
                : null,
          ),
        );
      },
    );

    return baseWidget!;
  }

  String getAppbarTitle() {
    switch (selectedItemPosition) {
      case 0:
        return 'Media';
      case 1:
        return S.of(context).share;
      case 2:
        return S.of(context).studio_settings;
      case 3:
        return 'Shorts';
      default:
        return '';
    }
  }

  void _onPageChanged(int page) {
    containerColor = containerColors[page];
    switch (page) {
      case 0:
        setState(() {
          showLog('selectedItemPosition $selectedItemPosition');
          selectedItemPosition = 0;
          // snakeBarStyle = SnakeBarBehaviour.floating;
          //snakeShape = SnakeShape.circle;
          // padding = const EdgeInsets.all(12);
          // bottomBarShape =
          //  RoundedRectangleBorder(borderRadius: BorderRadius.circular(25));
        });
        break;
      case 1:
        setState(() {
          selectedItemPosition = 1;
          /*snakeBarStyle = SnakeBarBehaviour.pinned;
          snakeShape = SnakeShape.circle;
          padding = EdgeInsets.zero;
          bottomBarShape = RoundedRectangleBorder(borderRadius: _borderRadius);
          showSelectedLabels = false;
          showUnselectedLabels = false;*/
        });
        break;
    }
  }

  Widget _getEventOptionsRoute(int index, EventSubViewController controller) {
    switch (index) {
      case 0:
        if (folder != null && context.mounted) {
          return Stack(
            children: [
              (controller.isLoading)
                  ? const PhotomallProgress()
                  : EventDetailView(
                      eventDetailedArguments: EventDetailArguments(
                        studioCode: widget.studioCode,
                        eventName: widget.eventName,
                        isSubFolder: true,
                        eventCode: widget.eventCode,
                        folderCode: folder?.code,
                      ),
                    ),
              controller.getListButton
                  ? Positioned(
                      top: 400,
                      left: 5,
                      child: CustomPrimaryButton(
                          width: 150,
                          text: controller.isLoadingForGetSelectedImages
                              ? 'Getting Selected List...'
                              : 'Get Selected List',
                          onPressed: () async {
                            try {
                              showLog('onPressed get selected list xyz');
                              await controller.checkForSelectedImages();
                            } catch (e) {
                              if (!context.mounted) return;
                              controller.isLoadingForGetSelectedImages = false;
                              ToastUtil.getToast(
                                  context, 'Error', 'Some thing went Wrong $e');
                            }
                          }),
                    )
                  : const SizedBox()
            ],
          );
        } else {
          controller.isAddPhotoSelection = true;
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: (controller.isLoading)
                  ? const PhotomallProgress()
                  : const Center(
                      child: CommonText(text: "No Photo Selection available")),
              floatingActionButton:
                  (controller.isAddPhotoSelection && (!controller.isLoading))
                      ? CustomPrimaryButton(
                          isLeadingIcon: true,
                          height: 50,
                          width: 160,
                          onPressed: () async {
                            await controller.addPhotoSelection();
                            showLog(
                                'model.isAddPhotoSelection ${controller.isAddPhotoSelection}');
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              RoutePaths.eventSubView,
                              arguments: EventSubViewArguments(
                                  eventCode: widget.eventCode,
                                  studioCode: widget.studioCode,
                                  eventName: widget.eventName),
                            );
                          },
                          text: S.of(context).add_photo_selection,
                          icon: Icons.add,
                        )
                      : const SizedBox());
        }
      case 1:
        return AlbumList(
          studioCode: widget.studioCode,
          eventCode: widget.eventCode,
          eventName: widget.eventName,
        );
      case 2:
        return ShareView(
          eventCode: widget.eventCode,
          eventName: widget.eventName,
        );
      case 3:
        return EventSettingsViewRoute(
          eventCode: widget.eventCode,
        );
      default:
        return Container(); // Default to an empty container or a not found page
    }
  }

  title(EventSubViewController model) {
    return Wrap(
      children: List.generate(model.events.length, growable: false, (index) {
        return CommonAppBar(
          title: model.events[1].categoryName,
          isCenterTitle: true,
        );
      }),
    );
  }

  showSubView(EventSubViewController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomPaint(
            // painter: ShapesPainter(),
            child: Column(
              children: [
                Container(height: 25), //custom_paint height
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !controller.isAddPhotoSelection
                        ? Flexible(
                            fit: FlexFit.loose,
                            flex: 2,
                            child: Commonhovercard(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () async {



                                  Folder? folder = await folderModelDao
                                      .getFoldersByEventAndParentNull(
                                          widget.eventCode);
                                  if (folder != null && context.mounted) {
                                    Navigator.pushNamed(
                                        context, RoutePaths.eventDetailed,
                                        arguments: EventDetailArguments(
                                          studioCode: widget.studioCode,
                                          eventName: widget.eventName,
                                          isSubFolder: true,
                                          eventCode: widget.eventCode,
                                          folderCode: folder.code,
                                        ));
                                  } else {
                                    ToastUtil.getToast(context, "Oops",
                                        "Something went wrong");
                                  }

                                  /*    Navigator.pushNamed(
                                    context,
                                    RoutePaths.eventDetailed,
                                    arguments: EventDetailArguments(
                                      studioCode: widget.studioCode,
                                      eventCode: widget.eventCode,
                                    ),
                                  );*/
                                },
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Container(
                                    height: 300,
                                    width: 300,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            stops: [
                                              0.1,
                                              0.5,
                                              0.8
                                            ],
                                            colors: [
                                              // Color(0xFFd2e6f7),
                                              Color(0xFF003B73),
                                              Color(0xFF003B73),
                                              Color(0xFF003B73),
                                              //Color(0xFFd2e6f7),
                                            ])),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                            height: 200,
                                            width: 300,
                                            child: Image(
                                                image: AssetImage(
                                                    'assets/images/ps.png'))),
                                        const CommonText(
                                          isHeading: true,
                                          text: "Photo Selection",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        controller.getListButton
                                            ? ElevatedButton(
                                                child: controller
                                                        .isLoadingForGetSelectedImages
                                                    ? const SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Color(
                                                              photomallYellow),
                                                          strokeWidth: 1,
                                                        ))
                                                    : const Text(
                                                        'Get Selected List'),
                                                onPressed: () async {
                                                  try {
                                                    showLog(
                                                        'onPressed get selected list 2');
                                                    await controller
                                                        .checkForSelectedImages();
                                                  } catch (e) {
                                                    if (!context.mounted)
                                                      return;
                                                    controller
                                                            .isLoadingForGetSelectedImages =
                                                        false;
                                                    ToastUtil.getToast(
                                                        context,
                                                        'Error',
                                                        'Some thing went Wrong $e');
                                                  }
                                                })
                                            : const SizedBox()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 25,
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 2,
                      child: Commonhovercard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutePaths.albumList,
                              arguments: AlbumListArguments(widget.eventCode,
                                  widget.studioCode, widget.eventName),
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      stops: [
                                        0.1,
                                        0.5,
                                        0.8
                                      ],
                                      colors: [
                                        //const Color(0xFFd2e6f7),
                                        Color(0xFF003B73),
                                        Color(0xFF003B73),
                                        Color(0xFF003B73),
                                        // const Color(0xFFd2e6f7),
                                      ])),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                      height: 200,
                                      width: 300,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 25.0),
                                        child: Image(
                                            image: AssetImage(
                                                'assets/images/media.png')),
                                      )),
                                  Container(
                                    alignment: Alignment.center,

                                    height: 100,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    // color: Colors.grey,
                                    child: const CommonText(
                                      isHeading: true,
                                      text: "Media",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*   Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 25),
                  const Text(
                    'Help',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 620,
                    height: 200,
                    child: Column(
                      children: [
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: () =>
                                launchURL('https://youtu.be/yRlwOdCK7Ho'),
                            shape: RoundedRectangleBorder(
                              //<-- SEE HERE

                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: const Image(
                                image: AssetImage(
                                    'assets/images/photo_selections.png')),
                            title: const Text(
                              'Photo Selection',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                            subtitle: const Text(
                              'How to upload Photo Selection ?',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                            ),
                            trailing: const Icon(Icons.play_arrow_rounded),
                            tileColor:
                                Colors.amberAccent.shade200.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            onTap: () =>
                                launchURL('https://youtu.be/yRlwOdCK7Ho'),
                            shape: RoundedRectangleBorder(
                              //<-- SEE HERE

                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: const Image(
                                image: AssetImage(
                                    'assets/images/photo_albums.png')),
                            title: const Text(
                              'Medias',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                            subtitle: const Text(
                              'How to upload Medias ?',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                            ),
                            trailing: const Icon(Icons.play_arrow_rounded),
                            tileColor:
                                Colors.amberAccent.shade200.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )*/
        ],
      ),
    );
  }
}

const double _kCurveHeight = 200;

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    p.lineTo(0, size.height - _kCurveHeight);
    p.relativeQuadraticBezierTo(
        size.width / 2, 1 * _kCurveHeight, size.width, 0);
    p.lineTo(size.width, 0);
    p.close();

    canvas.drawPath(
        p, Paint()..color = Colors.blue.shade200.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
