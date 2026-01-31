import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_hover_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/common_widgets/split_view.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as app_db;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/album/album_list_view_model.dart';
import 'package:photomall_studio_manager/routes/albumDetail/album_detail_arguments.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:path/path.dart'as pathq;
import '../../common_widgets/common_outlined_button.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;

class AlbumList extends StatefulWidget {
  final String eventCode;
  final String studioCode;
  final String eventName;

  const AlbumList({
    Key? key,
    required this.eventCode,
    required this.studioCode,
    required this.eventName,
  }) : super(key: key);

  @override
  State<AlbumList> createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  BaseWidget<AlbumListController>? baseWidget;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLog("Album detailed view");
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<AlbumListController>(
      model: AlbumListController(context: context),
      onModelReady: (model) =>
          model.getInitialValues(widget.eventCode, widget.studioCode),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.white,
                      Colors.white,
                    ])),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CommonAppBar(
                title: "${S.of(context).media} of ${widget.eventName}",
                isCenterTitle: true,
                appBarWithLogo: false,
                automaticallyImplyLeading: false,
              ),
              body: model.isLoading
                  ? const PhotomallProgress()
                  : SplitView(
                      children: [
                        albumListDetailsView(model),
                        albumListGridView(model),
                      ],
                    ),
            ),
          ),
        );
      },
    );
    return baseWidget!;
  }

  albumListDetailsView(AlbumListController model) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                    text:
                        '${S.of(context).total_number_of_albums} : ${model.albums?.length}'),
                const SizedBox(
                  height: 25,
                ),
                CustomPrimaryButton(
                  onPressed: () async {
                    bool? isTimeSynced =
                        await model.deviceUtil.checkSystemTime(context);
                    showLog('pick folder button clicked');
                    if (isTimeSynced != null && isTimeSynced) {
                      AddAlbum album = (!Platform.isAndroid)
                          ? await getName(context)
                          : await getNameForAndroid(context);
                      showLog('add add $album');

                      if (album.path != null &&
                          album.name != null &&
                          context.mounted) {
                        String? code = await model.addAlbum(
                            album.name!, album.path!, context);
                        if (context.mounted &&
                            code != null &&
                            code.isNotEmpty) {
                          await Navigator.pushNamed(
                            context,
                            RoutePaths.albumDetail,
                            arguments: AlbumDetailArguments(
                                code, widget.studioCode, album.path!,
                                eventCode: model.eventCode),
                          );
                          //await model.insertPhotos(album.path!, code);
                          await model.getInitialValues(
                            widget.eventCode,
                            widget.studioCode,
                          );
                        }
                      } else {
                        // ToastUtil.getToast(context, 'Canceled', "event aborted");
                      }
                    }
                  },
                  text: S.of(context).add_album,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  albumListGridView(AlbumListController model) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: MasonryGridView.count(
                physics: const ScrollPhysics(),
                crossAxisCount: (Platform.isAndroid) ? 1 : 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                itemCount: model.albums!.length,
                crossAxisSpacing: 10,
                itemBuilder: (context, index) {
                  return FadeInRight(
                      animate: true,
                      child: listItem(model.albums![index], model, index));
                })));
  }

  Future<AddAlbum> getName(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    final ValueNotifier<bool> showError = ValueNotifier<bool>(false);
    final ValueNotifier<String?> path = ValueNotifier<String?>(null);
    String? name;
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          showLog('add add 1');

          return CommonAlertDialog(
            titleWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 145.0),
                  child: CommonText(
                    text: S.of(context).add_album,
                    style: const TextStyle(
                        fontSize: 24,
                        color: Color(photomallYellow),
                        fontWeight: FontWeight.bold),
                    isHeading: true,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            contentWidget: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 200,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * .30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                                hintText: S.of(context).album_name,
                                contentPadding: const EdgeInsets.only(left: 20),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                errorBorder: InputBorder.none,
                                hintStyle: const TextStyle(
                                    color: Colors.black26,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        Row(
                          //mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // const SizedBox(
                            //   width: 65,
                            //   height: 25,
                            // ),
                            ValueListenableBuilder<String?>(
                                valueListenable: path,
                                builder: (BuildContext context, String? value,
                                    Widget? child) {
                                  return value != null
                                      ? ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 400),
                                          child: Text(
                                            "${path.value}",
                                            softWrap: true,
                                          ),
                                        )
                                      : CommonText(
                                          text: S
                                              .of(context)
                                              .please_pick_a_folder,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                          isBody: true,
                                        );
                                }),

                            IconButton(
                                onPressed: () async {
                                  path.value = (Platform.isWindows)
                                      ? file.getDirectory()?.path
                                      : await FilePicker.platform
                                          .getDirectoryPath();
                                },
                                icon: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        const Icon(Icons.folder_copy_outlined)))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            CustomPrimaryButton(
                                text: S.of(context).cancel,
                                onPressed: () => Navigator.pop(context)),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomPrimaryButton(
                                text: S.of(context).add,
                                onPressed: () async {
                                  List<FileSystemEntity> files =
                                      Directory("${path.value}").listSync();
                                  final imageFiles = files.where((file) {
                                    final extension = pathq.extension(file.path).toLowerCase();
                                    return extension == '.jpg' || extension == '.jpeg';
                                  }).toList();
                                  showLog('add files ${files.length > 1} ');
                                  if (imageFiles.isNotEmpty &&
                                      nameController.text.isNotEmpty &&
                                      path.value != null) {
                                    name = nameController.text;
                                    Navigator.of(context).pop();
                                  } else if ( imageFiles.isEmpty) {
                                    showLog('else if ${files.length}');
                                    await ToastUtil.showSnackBarAtCurrentState(
                                        'Selected folder must have atleast one image',
                                        seconds: 5);
                                  } else {
                                    showError.value = true;
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      showError.value = false;
                                    });
                                  }
                                }),
                          ],
                        ),
                        ValueListenableBuilder<bool>(
                            valueListenable: showError,
                            builder: (BuildContext context, bool value,
                                Widget? child) {
                              return value
                                  ? CommonText(
                                      text: S
                                          .of(context)
                                          .please_pick_path_and_enter_file_name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.normal),
                                    )
                                  : const SizedBox(
                                      height: 1,
                                    );
                            }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
    return AddAlbum(name, path.value);
  }

  Future<AddAlbum> getNameForAndroid(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    final ValueNotifier<bool> showError = ValueNotifier<bool>(false);
    final ValueNotifier<String?> path = ValueNotifier<String?>(null);
    String? name;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen BottomSheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // Handle keyboard overlap
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 400,
                width: 400,
                padding: const EdgeInsets.all(16.0),
                //height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Header
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.transparent, // photomallYellow
                      ),
                      child: Center(
                        child: CommonText(
                          text: S.of(context).add_album,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(photomallYellow),
                            fontWeight: FontWeight.bold,
                          ),
                          isHeading: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TextFormField
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: S.of(context).album_name,
                        contentPadding: const EdgeInsets.only(left: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.black26,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Folder Picker
                    ValueListenableBuilder<String?>(
                      valueListenable: path,
                      builder: (context, value, child) {
                        return CommonText(
                          text: value ?? S.of(context).please_pick_a_folder,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          isLabel: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonElevatedButton(
                          text: S.of(context).pick_folder,
                          onTap: () async {
                            path.value = (Platform.isWindows)
                                ? file.getDirectory()?.path
                                : await FilePicker.platform.getDirectoryPath();
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 10),
                        path.value != null
                            ? CommonElevatedButton(
                                text: S.of(context).add,
                                onTap: () {
                                  if (nameController.text.isNotEmpty &&
                                      path.value != null) {
                                    name = nameController.text;
                                    Navigator.of(context)
                                        .pop(); // Close BottomSheet
                                  } else {
                                    showError.value = true;
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      showError.value = false;
                                    });
                                  }
                                },
                              )
                            : SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Error Message
                    ValueListenableBuilder<bool>(
                      valueListenable: showError,
                      builder: (context, value, child) {
                        return value
                            ? CommonText(
                                text: S
                                    .of(context)
                                    .please_pick_path_and_enter_file_name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal,
                                    ),
                              )
                            : const SizedBox(height: 1);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    return AddAlbum(name, path.value);
  }

  listItem(Album album, AlbumListController model, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () {
          if (model.deviceId != album.deviceId) {
            ToastUtil.getToast(context, S.of(context).device_changed,
                S.of(context).path_not_exists);
            return;
          }
          Navigator.pushNamed(
            context,
            RoutePaths.albumDetail,
            arguments: AlbumDetailArguments(
                album.code, widget.studioCode, album.path ?? "",
                eventCode: model.eventCode),
          );
        },
        child: Stack(
          children: [
            (model.thumbNail != null &&
                    (model.thumbNail.length == model.albumCode?.length))
                ? Center(
                    //height: 200,
                    //width: double.infinity,
                    child: CustomCachedNetworkImageWidget(
                        url:
                            '${model.thumbNail[index] ?? 'https://cdn.photomall.in/photomall/b0d2e23b-3d4d-4ded-8576-963356e4d1098KJmmHBt'}'))
                : const Center(
                    //height: 200,
                    //width: double.infinity,
                    child:
                        Image(image: AssetImage('assets/images/albums.png'))),
            Positioned(
              bottom: 0,
              left: (Platform.isAndroid) ? 10 : 180,
              child: CommonText(
                text: album.name ?? "Album",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(5.0, 5.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      offset: Offset(5.0, 5.0),
                      blurRadius: 8.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
                isHeading: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAlbum {
  final String? name;

  final String? path;

  AddAlbum(this.name, this.path);
}
