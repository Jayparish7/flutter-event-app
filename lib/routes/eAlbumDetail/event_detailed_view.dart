import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:photomall_studio_manager/common_widgets/common_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_icon.dart';
import 'package:photomall_studio_manager/common_widgets/common_outlined_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_progress.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/split_view.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/key_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/event_detailed_controller.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/eventdetail_arguments_model.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../api/apiRequestModels/digital_oceans_space_service.dart';
import '../../api/apiResponseModels/google_drive_files_api_response_model.dart';
import '../../common_widgets/dual_scroll.dart';
import '../../common_widgets/google_drive__folder_widget.dart';
import '../../common_widgets/show_fullscreen_image.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../../utils/device_util.dart';
import '../../utils/google_drive_utils.dart';
import '../../utils/toast_util.dart';

class EventDetailView extends StatefulWidget {
  final EventDetailArguments eventDetailedArguments;

  const EventDetailView({Key? key, required this.eventDetailedArguments})
      : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  BaseWidget<EventDetailedController>? baseWidget;
  GoogleDriveUtils googleDriveUtils = GoogleDriveUtils();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLog("Event detailed view");
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<EventDetailedController>(
      model: EventDetailedController(
          arguments: widget.eventDetailedArguments,
          context: context,
          controller: Get.put(ProgressController())),
      onModelReady: (model) async {




        await model.getInitialValues(widget.eventDetailedArguments);
        if (isUploadingFolders
            .contains(widget.eventDetailedArguments.folderCode)) {
          showLog('Upload already in progress, skipping...');
          return;
        }
        try {
          isUploadingFolders.add(widget.eventDetailedArguments.folderCode!);
          await model.uploadImagesInThisFolder(
              widget.eventDetailedArguments.folderCode!);
          Platform.isWindows
              ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
              : null;
        } catch (e) {
          showLog('exception view in uploadImagesInThisFolder $e ');
        } finally {
          isUploadingFolders.remove(widget.eventDetailedArguments.folderCode);
        }

      },
      builder: (context, model, child) {
        showLog('model isParentFolder ${model.isParentFolder}');
        return WillPopScope(
          onWillPop: () async {
            bool leave = false;
            if (!model.isParentFolder) {
              (/*model.isAlertDialog ==*/ false)
                  ? await showDialog(
                      context: context,
                      builder: (context) {
                        return CommonAlertDialog(
                          title: "Do You want to leave this page",
                          contentWidget: const CommonText(
                            text:
                                "Uploading process will terminated in this page",
                            isBody: true,
                          ),
                          actions: [
                            CommonOutlinedButton(
                                text: 'Leave',
                                onTap: () async {
                                  leave = true;
                                  Navigator.pop(context);
                                }),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(photomallYellow)),
                                child: const Text('Cancel',
                                    style: (TextStyle(color: Colors.white))),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        );
                      })
                  : {/*leave = true,*/ Navigator.pop(context)};
            }

            if (leave) {
              model.isFolderListeningStoped = true;
              //Navigator.pop(context);
              return true;
            } else {
              if (model.isParentFolder) {
                model.isFolderListeningStoped = true;
                //Navigator.pop(context);
                return true;
              } else {
                return false;
              }
            }
          },
          child: Container(
            decoration: const BoxDecoration(color: photomallBodyColor),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CommonAppBar(
                title:
                    "${S.of(context).photo_selection} of ${widget.eventDetailedArguments.eventName}",
                isCenterTitle: true,
                appBarWithLogo: false,
                automaticallyImplyLeading: model.folderName.isNotEmpty,
              ),
              body: model.isLoading
                  ? const CommonCircularProgress()
                  : model.valueNotifierPhotoSelectionImages.value.isEmpty
                      ? SplitView(
                          children: [
                            folderDetailViewForParent(model),
                            showFolderView(model),
                          ],
                        )
                      : SplitView(
                          children: [
                            folderDetailView(model),
                            showFolderView(model),
                          ],
                        ),
              floatingActionButton: !model.isLoading
                  ? model.isParentFolder
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 5,
                          children: [
                            // CustomPrimaryButton(
                            //   height: 55,
                            //   isLeadingIcon: true,
                            //   text: "Add DriveFolder",
                            //   onPressed: () async {
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => DriveFolderPicker(
                            //                   onFolderSelected:
                            //                       model.onFolderSelected,
                            //                 )));
                            //   },
                            //   icon: Icons.cloud,
                            // ),
                            CustomPrimaryButton(
                              height: 55,
                              isLeadingIcon: true,
                              text: S.of(context).add_folder,
                              onPressed: () async {
                                bool? isTimeSynced = await model.deviceUtil
                                    .checkSystemTime(context);
                                showLog('pick folder button clicked');
                                if (isTimeSynced != null && isTimeSynced) {
                                  await pickFolder(model);
                                }
                              },
                              icon: Icons.add,
                            ),
                          ],
                        )
                  : const SizedBox(),
            ),
          ),
        );
      },
    );
    return baseWidget!;
  }


  pickFolder(EventDetailedController controller) async {
    String? result = (Platform.isWindows)
        ? file.getDirectory()?.path
        : await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await controller.pickFolder(result);
    } else {
      // Do something else...
    }
  }

  pickImages(EventDetailedController controller) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      // controller.pickImages(result);
    } else {
      // Do something else...
    }
  }

  createFolder(EventDetailedController controller) async {
    await controller.createFolder();
  }

  showFolderView(EventDetailedController controller) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 10,
      trackVisibility: true,
      //showTrackOnHover: false,
      controller: controller.scrollController,
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            controller.folderList.value.isEmpty
                ? const SizedBox()
                : Wrap(
                    children: List.generate(controller.folderList.value.length,
                        (index) {
                      return FadeInRight(
                        animate: true,
                        child: InkWell(
                            onTap: () async {
                              controller.isFolderListeningStoped = true;
                              if (!controller.isParentFolder &&
                                  controller.folderList.value[index].deviceId !=
                                      controller.deviceId) {
                                await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CommonAlertDialog(
                                        title: S.of(context).pick_folder,
                                        content: S
                                            .of(context)
                                            .choose_the_original_folder,
                                        actions: [
                                          CustomPrimaryButton(
                                              text: S.of(context).select_folder,
                                              onPressed: () async {
                                                // assing new name
                                                await controller.pickFolderCode(
                                                    controller.folderList
                                                        .value[index].name);

                                                Navigator.pop(context);
                                              }),
                                          CustomPrimaryButton(
                                              text: S.of(context).cancel,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                          CustomPrimaryButton(
                                              width: 125,
                                              text: S
                                                  .of(context)
                                                  .go_to_sub_folder,
                                              onPressed: () async {
                                                showLog('Go to sub Folder');
                                                await Navigator.pushNamed(
                                                  context,
                                                  RoutePaths.eventDetailed,
                                                  arguments: EventDetailArguments(
                                                      studioCode: widget
                                                          .eventDetailedArguments
                                                          .studioCode,
                                                      isSubFolder: true,
                                                      eventCode: widget
                                                          .eventDetailedArguments
                                                          .eventCode,
                                                      eventName: widget
                                                          .eventDetailedArguments
                                                          .eventName,
                                                      folderCode: controller
                                                          .folderList
                                                          .value[index]
                                                          .code),
                                                );
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      );
                                    });

                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                RoutePaths.eventDetailed,
                                arguments: EventDetailArguments(
                                    studioCode: widget
                                        .eventDetailedArguments.studioCode,
                                    isSubFolder: true,
                                    eventCode:
                                        widget.eventDetailedArguments.eventCode,
                                    eventName:
                                        widget.eventDetailedArguments.eventName,
                                    folderCode: controller
                                        .folderList.value[index].code),
                              );

                              showLog(" navigate returned..");
                              //controller.isFolderListeningStoped = false;
                              controller.listenLocalDirectory(
                                  folderCode:
                                      controller.folderList.value[index].code);
                            },
                            child: SizedBox(
                              height: 100,
                              width: 150,
                              child: Column(
                                children: [
                                  controller.isParentFolder
                                      ? const CommonCard(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CommonText(
                                                text:
                                                    "Image and name of the photo Selections",
                                                isBody: true),
                                          ),
                                        )
                                      : const CommonIcon(
                                          icon: Icons.folder,
                                          color: Color(0xFFEFB054),
                                        ),
                                  Expanded(
                                    child: CommonText(
                                      textAlign: TextAlign.center,
                                      isBody: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      text: controller
                                          .folderList.value[index].name,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    }),
                  ),
            /*ValueListenableBuilder<List<appDb.PhotoSelectionImage>>(
                key: GlobalKey(),
                valueListenable:
                    controller.localValueNotifierPhotoSelectionImages,
                builder: (BuildContext context,
                    List<appDb.PhotoSelectionImage> value, Widget? child) {
                  showLog(
                      "widget rebuild ..${controller.localValueNotifierPhotoSelectionImages.value.length}");
          */
            StreamBuilder<List<PhotoSelectionImage>>(
                stream: controller.streamPhotoSelectionImagesForView(),
                builder: (context,
                    AsyncSnapshot<List<PhotoSelectionImage>> snapshot) {
                  if (snapshot.hasData) {
                    showLog("streamImageForView ${snapshot.data!.length}");
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ImageWithTagGrid(
                        allImages: controller
                            .localValueNotifierPhotoSelectionImages.value,
                        //snapshot.data!,
                        model: controller,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
            // })
          ],
        ),
      ),
    );
  }

  Future<String> pickOriginalFolder({bool isCustomPath = false}) async {
    String originPath = "";
    await showDialog(
        context: context,
        builder: (context) {
          return CommonAlertDialog(
            title: (isCustomPath)
                ? S.of(context).select_destination_folder
                : S.of(context).pick_original_folder,
            contentWidget: CommonText(
              text: (isCustomPath)
                  ? S.of(context).choose_destination_folder
                  : S.of(context).Pick_Path_original_photos_exists,
              isBody: true,
            ),
            actions: [
              CommonElevatedButton(
                  text: S.of(context).Pick,
                  onTap: () async {
                    String? result = (Platform.isWindows)
                        ? file.getDirectory()?.path
                        : await FilePicker.platform.getDirectoryPath();
                    if (result != null) {
                      originPath = result;
                      Navigator.pop(context);
                    }
                  }),
              CommonElevatedButton(
                  text: S.of(context).cancel,
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });

    return originPath;
  }

  pickFormate() async {
    String formate = '';
    await showDialog(
        context: context,
        builder: (context) {
          return CommonAlertDialog(
            title: "Pick Formate",
            contentWidget: DropdownSearch<int>(
              items: const [1, 2, 3, 4, 5, 6, 7],
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Fotmate",
                  hintText: "Select an Int",
                  filled: true,
                ),
              ),
              popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                  //  disabledItemFn: (int i) => i <= 3,
                  ),
            ),
            actions: [
              CommonElevatedButton(
                  text: 'Ok',
                  onTap: () async {
                    Navigator.pop(context);
                  }),
              CommonElevatedButton(
                  text: 'cancel',
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
    return formate;
  }

  folderDetailView(EventDetailedController model) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            model.folderName.isNotEmpty
                ? const SizedBox(
                    height: 10,
                  )
                : const SizedBox(),
            CommonText(
              text: "${S.of(context).segregation_format} :",
              isBody: true,
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownSearch<String>(
              onChanged: (value) async {
                if (value != null) {
                  showLog("the new formate $value");
                  model.isLoading = true;
                  await model.setSegregationFormat(value);
                  model.isLoading = false;
                }
              },
              selectedItem: model.folderSegritionFormat,
              items: model.extensionList,
              //const ["jpeg", "pdf", "png"],
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: S.of(context).format,
                  hintText: S.of(context).select_an_format,
                  filled: true,
                ),
              ),
              popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                  //  disabledItemFn: (int i) => i <= 3,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            CommonText(
              text: '${S.of(context).images_path}  :',
              isBody: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              //  margin: const EdgeInsets.all(15.0),
              //  padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: S.of(context).images_path,
                          isLabel: true,
                        ),
                        CommonText(
                          maxLines: 1,
                          text: model.folderSegritionPath,
                          isLabel: true,
                        ),
                      ],
                    ),
                    InkWell(
                        onTap: () async {
                          String? path = await pickOriginalFolder();
                          if (path.isNotEmpty) {
                            showLog("the segregation path :: ::>$path<");
                            await model.setSegregationPath(path);
                            await model.setCustomSegregationPath(path);
                          }
                        },
                        child:
                            const CommonIcon(icon: Icons.edit, iconSize: 25)),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CommonText(
              text: '${S.of(context).segregation_path}  :',
              isBody: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              //  margin: const EdgeInsets.all(15.0),
              //  padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: S.of(context).segregation_path,
                          isLabel: true,
                        ),
                        CommonText(
                          maxLines: 1,
                          text: model.folderCustomSegritionPath,
                          isLabel: true,
                        ),
                      ],
                    ),
                    InkWell(
                        onTap: () async {
                          String? path =
                              await pickOriginalFolder(isCustomPath: true);
                          if (path.isNotEmpty) {
                            showLog(
                                "${model.folderCustomSegritionPath}the segregation path :: ::>$path<");
                            await model.setCustomSegregationPath(path);
                          }
                        },
                        child:
                            const CommonIcon(icon: Icons.edit, iconSize: 25)),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CommonText(
              text:
                  '${S.of(context).number_of_images}  : ${model.valueNotifierPhotoSelectionImages.value.length}',
              isBody: true,
            ),
            const SizedBox(
              height: 10,
            ),
            (model.folderList.value.isNotEmpty)
                ? CommonText(
                    text:
                        '${S.of(context).number_of_folders}  : ${model.folderList.value.length}',
                    isBody: true,
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              height: 5,
            ),
            StreamBuilder<String>(
              stream: model.streamProgress(),
              builder:
                  (BuildContext? context, AsyncSnapshot<String>? snapshot) {
                if (snapshot!.hasData) {
                  return CommonText(
                      isBody: true, text: 'Status:${snapshot.data} ');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(
              height: 5,
            ),
            (model.pendingImagesForUpload!.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UploadButton(
                      uploadState: model.uploadState,
                      onPressed: () async {
                        Platform.isWindows
                            ? WindowsTaskbar.setProgressMode(
                                TaskbarProgressMode.paused)
                            : null;

                        await model.updateUploadStatus(
                            widget.eventDetailedArguments.folderCode ?? "");
                      },
                    ),
                  )
                : const SizedBox.shrink(),
            model.pSConfirmStatus
                ? CustomPrimaryButton(
                    width: 150,
                    text: model.isLoadingForGetSelectedImages
                        ? 'Getting Selected List...'
                        : 'Get Selected List',
                    onPressed: () async {
                      try {
                        showLog('onPressed get selected list xyz');

                        await model.checkForSelectedImages();
                      } catch (e) {
                        if (!context.mounted) return;
                        model.isLoadingForGetSelectedImages = false;
                        ToastUtil.getToast(
                            context, 'Error', 'Some thing went Wrong $e');
                      }
                    })
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  folderDetailViewForParent(EventDetailedController model) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 100,
            ),
            (model.folderList.value.isNotEmpty)
                ? CommonText(
                    text:
                        '${S.of(context).number_of_folders}  :  ${model.folderList.value.length}',
                    isBody: true,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 10,
            ),
            (model.pSConfirmStatus != true)
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CommonText(
                          text: '${S.of(context).confirmation_status}  :  ',
                          isBody: true,
                        ),
                        CommonText(
                            text: S.of(context).not_submitted,
                            isBody: true,
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                : Row (
                    children: [
                      CommonText(
                        text: '${S.of(context).confirmation_status}  : ',
                        isBody: true,
                      ),
                      CommonText(
                        text: S.of(context).submitted,
                        isBody: true,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}

class ImageWithTagGrid extends StatelessWidget {
  final EventDetailedController model;
  final List< PhotoSelectionImage> allImages;

  const ImageWithTagGrid(
      {super.key, required this.model, required this.allImages});

  @override
  Widget build(BuildContext context) {
    var sortedImages = List.of(allImages);
    sortedImages.sort((a, b) => a.name!.compareTo(b.name!));
    return SingleChildScrollView(
      //controller: model.scrollController,
      child: SizedBox(
          child: MasonryGridView.count(
        padding: const EdgeInsets.only(right: 10),
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 10,
        itemCount: sortedImages.length,
        crossAxisSpacing: 10,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(40)),
                  child: InkWell(
                    onTap: () {
                      showLog('photosGridView');
                      showLog('path is indexed $index');

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullScreenView(
                                    index: index,
                                    key: UniqueKey(),
                                    title: model.folderName!,
                                    imagePath: sortedImages[index].path!,
                                    imagePaths: sortedImages,
                                    bgColor: Colors.transparent,
                                    largeScreenFitType: FitType.contained,
                                  )));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(
                        File(sortedImages[index].path!),
                        //width: 100,
                        height: 100,
                        //cacheWidth: 200,  // reduce memory use
                        cacheHeight: 200,
                        fit: BoxFit.cover,
                      ),
                      /*CustomCachedNetworkImageWidget(
                            url: "$publicPath${sortedImages[index].sha256}")*/
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: sortedImages[index].uploaded!
                          ? Tooltip(
                              decoration: toolTipDecoration,
                              message: 'Status:Uploaded',
                              child: Card(
                                shape: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(photomallYellow),
                                        width: .9),
                                    borderRadius: BorderRadius.circular(100)),
                                color: Colors.white,
                                child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )),
                              ),
                            )
                          : Tooltip(
                              decoration: toolTipDecoration,
                              message: "Status:Uploading...",
                              child: const Card(
                                color: Colors.white,
                                child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.timelapse_outlined,
                                      color: Colors.grey,
                                      size: 20,
                                    )),
                              ),
                            ),
                    ),
                    Text(
                      "${sortedImages[index].name}",
                      style: const TextStyle(
                        color: Color(photomallYellow),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}
