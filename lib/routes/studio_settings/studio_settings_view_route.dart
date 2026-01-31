import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/studio_settings/studio_settings_route_view_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import '../../common_widgets/base_widget.dart';
import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../1.constants/api_constants.dart';

class StudioSettingsViewRoute extends StatefulWidget {
  const StudioSettingsViewRoute({super.key});

  @override
  State<StudioSettingsViewRoute> createState() =>
      _StudioSettingsViewRouteState();
}

class _StudioSettingsViewRouteState extends State<StudioSettingsViewRoute> {
  BaseWidget<StudioSettingsRouteViewModel>? baseWidget;
  double borderRadius = (Platform.isAndroid) ? 0 : 20;
  String selectedSpeed = 'Default';

  void loadSpeed() async {
    String speed = await PreferenceHelper().getUploadSpeedLabel();

    setState(() {
      selectedSpeed = speed;
    });
  }

  void changeSpeed(String speed) async {
    await PreferenceHelper().saveUploadSpeed(speed);
    setState(() {
      selectedSpeed = speed;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSpeed();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    baseWidget = BaseWidget(
      model: StudioSettingsRouteViewModel(Get.put(ProgressController())),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        List<SettingsSwitch?> settingsSwitches = [
          (model.plan?.photoSelectionDownloadStatus == 1)
              ? SettingsSwitch(
                  title: S.of(context).photo_selection_download_status,
                  controller: model.photoSelectionDownloadStatusController,
                  initialValue: model.photoSelectionDownloadStatusValue,
                  activeText: S.of(context).on,
                  inactiveText: S.of(context).off,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  onChanged: (res) async {
                    await model.studioSettingsUpdateApi(map: {
                      photoSelectionDownloadableKey: (res) ? '1' : '0',
                    });
                    showLog(
                        'onChanged photoSelectionDownloadStatusController $res');
                  },
                )
              : null,
          SettingsSwitch(
            title: S.of(context).show_photos_as_rounded_edge,
            controller: model.showPhotosAsRoundedEdgeController,
            initialValue: model.showPhotosAsRoundedEdgeValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(map: {
                showPhotosAsRoundedEdgeKey: (res) ? '1' : '0',
              });
              showLog('onChanged downloadWithIconController $res');
            },
          ),
          SettingsSwitch(
            title: '${S.of(context).download_with_watermark} ',
            controller: model.downloadWithWaterMarkController,
            initialValue: model.downloadWithWaterMarkValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(map: {
                downloadWithWaterMarkKey: (res) ? '1' : '0',
              });
              showLog('onChanged downloadWithWaterMarkController $res');
            },
          ),
          (model.plan?.photosDownloadStatus == 1)
              ? SettingsSwitch(
                  title: S.of(context).my_photos_downloadable,
                  controller: model.myPhotoDownloadStatusController,
                  initialValue: model.myPhotoDownloadStatusValue,
                  activeText: S.of(context).on,
                  inactiveText: S.of(context).off,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  onChanged: (res) async {
                    await model.studioSettingsUpdateApi(map: {
                      myPhotosDownloadableKey: (res) ? '1' : '0',
                    });
                    showLog('onChanged myPhotoDownloadStatusController $res');
                  },
                )
              : null,
          SettingsSwitch(
            title: '${S.of(context).hide_media_photos} ',
            controller: model.hideMediaPhotosController,
            initialValue: model.hideMediaValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(map: {
                hideMediaPhotosKey: (res) ? '1' : '0',
              });
              showLog('onChanged hideMediaPhotosController $res');
            },
          ),
          SettingsSwitch(
            title: S.of(context).photos_print_status,
            controller: model.printPhotosStatusController,
            initialValue: model.printPhotosStatusValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(map: {
                photosPrintStatusKey: (res) ? '1' : '0',
              });
              showLog('onChanged printPhotosStatusController $res');
            },
          ),
          SettingsSwitch(
            title: '${S.of(context).app_tour} ',
            controller: model.appTourController,
            initialValue: model.appTourValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(
                  map: {appTourKey: (res) ? '1' : '0'});
              showLog('onChanged appTourController $res');
            },
          ),
          SettingsSwitch(
            title: S.of(context).download_with_icon,
            controller: model.downloadWithIconController,
            initialValue: model.downloadWithIconValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(
                  map: {downloadWithIconKey: (res) ? '1' : '0'});
              showLog('onChanged downloadWithIconController $res');
            },
          ),
          SettingsSwitch(
            title:
                '${S.of(context).users_allowed_per_account_in_face_recognition} ',
            controller: model.usersAllowedInFaceRecognitionController,
            initialValue: model.usersAllowedInFaceRecognitionValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(
                  map: {usersAllowedInFaceRecognitionKey: (res) ? '1' : '0'});
              showLog('onChanged usersAllowedInFaceRecognitionController $res');
            },
          ),
          SettingsSwitch(
            title: S.of(context).doubt_image_clear_for_end_user,
            controller: model.doubtImageClearController,
            initialValue: model.doubtImageClearValue,
            activeText: S.of(context).on,
            inactiveText: S.of(context).off,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            onChanged: (res) async {
              await model.studioSettingsUpdateApi(
                  map: {doubtImageClearKey: (res) ? '1' : '0'});
              showLog('onChanged doubtImageClearController $res');
            },
          ),
          (model.playStoreLink != '')
              ? SettingsSwitch(
                  title: S.of(context).forbidden_app_redirect,
                  controller: model.androidAppRedirectionController,
                  initialValue: model.androidAppRedirectionValue,
                  activeText: S.of(context).on,
                  inactiveText: S.of(context).off,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  onChanged: (res) async {
                    await model.studioSettingsUpdateApi(
                        map: {androidAppRedirectionKey: (res) ? '0' : '1'});
                    showLog('onChanged doubtImageClearController $res');
                  },
                )
              : null,
        ];
        (model.plan?.photoSelectionDownloadStatus == 1)
            ? null
            : settingsSwitches.remove(null);
        (model.plan?.photosDownloadStatus == 1)
            ? null
            : settingsSwitches.remove(null);
        (model.playStoreLink != '') ? null : settingsSwitches.remove(null);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CommonAppBar(
            title: S.of(context).studio_settings,
            isCenterTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Skeletonizer(
            enabled: model.isLoading.value,
            child: Container(
              decoration: const BoxDecoration(
                color: photomallBodyColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    (!Platform.isAndroid)
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28.0, right: 8),
                                  child: Card(
                                      surfaceTintColor: Colors.transparent,
                                      color: photomallBodyColor,
                                      child: ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CommonText(
                                            text:
                                                '${S.of(context).studio_name} : ${model.studioName}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CommonAlertDialog(
                                                      titleWidget: Text(S
                                                          .of(context)
                                                          .change_studio_name),
                                                      contentWidget: TextField(
                                                        controller: model
                                                            .nameController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: S
                                                              .of(context)
                                                              .studio_name,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                        ),
                                                      ),
                                                      actions: [
                                                        CommonElevatedButton(
                                                            text: S
                                                                .of(context)
                                                                .ok,
                                                            onTap: () async {
                                                              Navigator.pop(
                                                                  context);

                                                              try {
                                                                await model
                                                                    .changeStudioName(model
                                                                        .nameController
                                                                        .text);
                                                              } catch (e) {
                                                                showLog(
                                                                    'changeStudioName $e');
                                                              }
                                                              model
                                                                  .nameController
                                                                  .text = '';
                                                            }),
                                                        CommonElevatedButton(
                                                            text: S
                                                                .of(context)
                                                                .cancel,
                                                            onTap: () {
                                                              model
                                                                  .nameController
                                                                  .text = '';
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                    );
                                                  });
                                            },
                                            icon: const Icon(Icons.edit)),
                                      )),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 18),
                                  child: Card(
                                      surfaceTintColor: Colors.transparent,
                                      color: photomallBodyColor,
                                      child: ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Row(
                                            children: [
                                              CommonText(
                                                text:
                                                    '${S.of(context).studio_established} : ',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TimePickerSpinnerPopUp(
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                                initTime: (model.studioEstablished
                                                                .year ==
                                                            '0' &&
                                                        model.studioEstablished
                                                                .date ==
                                                            '0' &&
                                                        model.studioEstablished
                                                                .month ==
                                                            '0')
                                                    ? DateTime.now()
                                                    : DateTime.parse(
                                                        '${model.studioEstablished.year ?? '1999'}-${model.studioEstablished.month.toString().padLeft(2, '0')}-${model.studioEstablished.date.toString().padLeft(2, '0')}'),
                                                maxTime: DateTime.now(),
                                                barrierColor: Colors.black12,
                                                //Barrier Color when pop up show
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 10, 12, 10),
                                                cancelText:
                                                    S.of(context).cancel,
                                                confirmText: S.of(context).ok,
                                                pressType:
                                                    PressType.singlePress,
                                                timeFormat: 'dd/MM/yyyy',
                                                // Customize your time widget
                                                // timeWidgetBuilder: (dateTime) {},
                                                onChange: (dateTime) async {
                                                  await model
                                                      .studioSettingsUpdateApi(
                                                          map: {
                                                        establishedYearKey:
                                                            dateTime.year
                                                                .toString(),
                                                        establishedMonthKey:
                                                            dateTime.month
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                        establishedDateKey:
                                                            dateTime.day
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                      });
                                                  showLog(
                                                      ' DateTime === ${DateTime.now()}');
                                                  // Implement your logic with select dateTime
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                )),
                                Expanded(
                                    child: Card(
                                        surfaceTintColor: Colors.transparent,
                                        color: photomallBodyColor,
                                        child: ListTile(
                                          title: CommonText(
                                            text:
                                                'Control upload speed: $selectedSpeed',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle: const Text(
                                              'Speed as per system capacity'),
                                          trailing: PopupMenuButton<String>(
                                            color: Colors.white,
                                            icon: const Icon(Icons.edit),
                                            onSelected: changeSpeed,
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'Default',
                                                child: Text('Default'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Fast',
                                                child: Text('Fast'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Ultra Fast',
                                                child: Text('Ultra Fast'),
                                              ),
                                            ],
                                          ),
                                        ))),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    (Platform.isAndroid)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Card(
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                color: photomallBgColor,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text:
                                          '${S.of(context).studio_name} : ${model.studioName}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  trailing: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CommonAlertDialog(
                                                titleWidget: Text(S
                                                    .of(context)
                                                    .change_studio_name),
                                                contentWidget: TextField(
                                                  controller:
                                                      model.nameController,
                                                  decoration: InputDecoration(
                                                    labelText: S
                                                        .of(context)
                                                        .studio_name,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                              width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 2.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  CommonElevatedButton(
                                                      text: S.of(context).ok,
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        try {
                                                          await model
                                                              .changeStudioName(
                                                                  model
                                                                      .nameController
                                                                      .text);
                                                        } catch (e) {
                                                          showLog(
                                                              'changeStudioName $e');
                                                        }
                                                        model.nameController
                                                            .text = '';
                                                      }),
                                                  CommonElevatedButton(
                                                      text:
                                                          S.of(context).cancel,
                                                      onTap: () {
                                                        model.nameController
                                                            .text = '';
                                                        Navigator.pop(context);
                                                      }),
                                                ],
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.edit)),
                                )),
                          )
                        : const SizedBox(),
                    (Platform.isAndroid) ? Divider() : SizedBox(),
                    (Platform.isAndroid)
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 18.0, right: 18),
                            child: Card(
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                color: photomallBgColor,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      children: [
                                        CommonText(
                                          text:
                                              '${S.of(context).studio_established} : ',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TimePickerSpinnerPopUp(
                                          mode: CupertinoDatePickerMode.date,
                                          initTime: DateTime.parse(
                                              '${model.studioEstablished.year ?? '1999'}-${model.studioEstablished.month.toString().padLeft(2, '0')}-${model.studioEstablished.date.toString().padLeft(2, '0')}'),
                                          maxTime: DateTime.now(),
                                          barrierColor: Colors.black12,
                                          //Barrier Color when pop up show
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 10, 12, 10),
                                          cancelText: S.of(context).cancel,
                                          confirmText: S.of(context).ok,
                                          pressType: PressType.singlePress,
                                          timeFormat: 'dd/MM/yyyy',
                                          // Customize your time widget
                                          // timeWidgetBuilder: (dateTime) {},
                                          onChange: (dateTime) async {
                                            await model
                                                .studioSettingsUpdateApi(map: {
                                              establishedYearKey:
                                                  dateTime.year.toString(),
                                              establishedMonthKey: dateTime
                                                  .month
                                                  .toString()
                                                  .padLeft(2, '0'),
                                              establishedDateKey: dateTime.day
                                                  .toString()
                                                  .padLeft(2, '0'),
                                            });
                                            showLog(
                                                ' DateTime === ${DateTime.now()}');
                                            // Implement your logic with select dateTime
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          )
                        : const SizedBox(),
                    (Platform.isAndroid) ? Divider() : SizedBox(),

                    (!Platform.isAndroid)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 28.0, right: 8),
                                child: Card(
                                    surfaceTintColor: Colors.transparent,
                                    color: photomallBodyColor,
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CommonText(
                                          text:
                                              '${S.of(context).studio_cover_image} ',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      subtitle: Skeletonizer(
                                        enabled: model
                                            .isStudioCoverImageLoading.value,
                                        child: SizedBox(
                                          height: 200,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: (model.selectedFile !=
                                                      null)
                                                  ? Image.file(File(model
                                                      .selectedFile!
                                                      .absolute
                                                      .path))
                                                  : CustomCachedNetworkImageWidget(
                                                      url:
                                                          '${model.publicPath}/${model.studioCoverImage}',
                                                      fitSize: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                          onPressed: () async {
                                            PickedFile? image =
                                                await ImagePicker.platform
                                                    .pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                            showLog(
                                                'PickedFile -- > image -->${image?.path}');

                                            {
                                              await model
                                                  .showImageCropAlertDialog(
                                                      image!, context);
                                            }
                                          },
                                          icon: const Icon(Icons.edit)),
                                    )),
                              )),
                              Expanded(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 18),
                                child: Card(
                                    surfaceTintColor: Colors.transparent,
                                    color: photomallBodyColor,
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CommonText(
                                          text:
                                              '${S.of(context).event_cover_image} ',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      subtitle: Skeletonizer(
                                        enabled: model
                                            .isEventCoverImageLoading.value,
                                        child: SizedBox(
                                          height: 200,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: (model.eventSelectedFile !=
                                                      null)
                                                  ? Image.file(File(model
                                                      .eventSelectedFile!
                                                      .absolute
                                                      .path))
                                                  : CustomCachedNetworkImageWidget(
                                                      isEventCover: true,
                                                      url:
                                                          '${model.publicPath}/${model.eventCoverImage}',
                                                      fitSize: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                          onPressed: () async {
                                            PickedFile? image =
                                                await ImagePicker.platform
                                                    .pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                            showLog(
                                                'PickedFile -- > image -->${image?.path}');

                                            await model
                                                .showImageCropAlertDialog(
                                                    image!, context,
                                                    isFromEvent: true);
                                          },
                                          icon: const Icon(Icons.edit)),
                                    )),
                              )),
                            ],
                          )
                        : const SizedBox(),
                    (Platform.isAndroid)
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 18.0, right: 18),
                            child: ListTile(
                              title: CommonText(
                                text: 'Control upload speed: $selectedSpeed',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle:
                                  const Text('Speed as per system capacity'),
                              trailing: PopupMenuButton<String>(
                                color: Colors.white,
                                icon: const Icon(Icons.edit),
                                onSelected: changeSpeed,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Default',
                                    child: Text('Default'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Fast',
                                    child: Text('Fast'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Ultra Fast',
                                    child: Text('Ultra Fast'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    (Platform.isAndroid) ? Divider() : SizedBox(),

                    (Platform.isAndroid)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Card(
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                color: photomallBgColor,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text:
                                          '${S.of(context).studio_cover_image} ',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  subtitle: Skeletonizer(
                                    enabled:
                                        model.isStudioCoverImageLoading.value,
                                    child: SizedBox(
                                      height: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: (model.selectedFile != null)
                                              ? Image.file(File(model
                                                  .selectedFile!.absolute.path))
                                              : CustomCachedNetworkImageWidget(
                                                  url:
                                                      '${model.publicPath}/${model.studioCoverImage}',
                                                  fitSize: BoxFit.contain,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        PickedFile? image = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        showLog(
                                            'PickedFile -- > image -->${image?.path}');

                                        await model.showImageCropAlertDialog(
                                            image!, context);
                                      },
                                      icon: const Icon(Icons.edit)),
                                )),
                          )
                        : const SizedBox(),
                    (Platform.isAndroid) ? Divider() : SizedBox(),

                    (Platform.isAndroid)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Card(
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                color: photomallBgColor,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text:
                                          '${S.of(context).event_cover_image} ',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  subtitle: Skeletonizer(
                                    enabled:
                                        model.isEventCoverImageLoading.value,
                                    child: SizedBox(
                                      height: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: (model.eventSelectedFile !=
                                                  null)
                                              ? Image.file(File(model
                                                  .eventSelectedFile!
                                                  .absolute
                                                  .path))
                                              : CustomCachedNetworkImageWidget(
                                                  isEventCover: true,
                                                  url:
                                                      '${model.publicPath}/${model.eventCoverImage}',
                                                  fitSize: BoxFit.contain,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        PickedFile? image = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        showLog(
                                            'PickedFile -- > image -->${image?.path}');

                                        await model.showImageCropAlertDialog(
                                            image!, context,
                                            isFromEvent: true);
                                      },
                                      icon: const Icon(Icons.edit)),
                                )),
                          )
                        : const SizedBox(),
                    (Platform.isAndroid) ? Divider() : SizedBox(),

                    Padding(
                      padding: EdgeInsets.only(
                          left: (Platform.isAndroid) ? 10 : 26.0,
                          right: (Platform.isAndroid) ? 10 : 20,
                          bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (Platform.isAndroid)
                              ? photomallBgColor
                              : Colors.transparent,
                        ),
                        child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: (Platform.isAndroid)
                                  ? (orientation == Orientation.portrait)
                                      ? 1
                                      : 2
                                  : 3,
                              // Number of columns
                              childAspectRatio: 3.5,
                              // Adjust this for aspect ratio
                              crossAxisSpacing: 0.0,
                              // Space between columns
                              mainAxisSpacing: 0.0, // Space between rows
                            ),
                            itemCount: settingsSwitches.length,
                            itemBuilder: (context, index) {
                              return SettingsSwitchCard(
                                settingsSwitch: settingsSwitches[index]!,
                              );
                            }),
                      ),
                    ),


                    Platform.isAndroid
                        ? Column(
                            children: [
                              model.appVersion == '1'
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.red,
                                                width:
                                                    1), // Set the border color and width
                                          ),
                                          child: Text(
                                            S.of(context).update,
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                          onPressed: () {
                                            var packageName =
                                                "in.photomall.app.photomallEventManager";
                                            showLog('packageName $packageName');

                                            LaunchReview.launch(
                                                androidAppId: packageName,
                                                iOSAppId: "");
                                          }),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                  height: 50,
                                  child: Text(
                                      "App version: $androidAppVersionCode",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(photomallYellow),
                                      ))),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return baseWidget!;
  }
}

class SettingsSwitch {
  final String title;
  final ValueNotifier<bool> controller;
  final bool initialValue;
  final String activeText;
  final String inactiveText;
  final Color activeColor;
  final Color inactiveColor;
  final Future<void> Function(bool) onChanged;

  SettingsSwitch({
    required this.title,
    required this.controller,
    required this.initialValue,
    required this.activeText,
    required this.inactiveText,
    required this.activeColor,
    required this.inactiveColor,
    required this.onChanged,
  });
}

class SettingsSwitchCard extends StatelessWidget {
  final SettingsSwitch settingsSwitch;

  const SettingsSwitchCard({
    required this.settingsSwitch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          surfaceTintColor: Colors.transparent,
          color: photomallBodyColor,
          elevation: Platform.isAndroid ? 0 : 2,
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonText(
                text: settingsSwitch.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            trailing: AdvancedSwitch(
              initialValue: settingsSwitch.initialValue,
              controller: settingsSwitch.controller,
              activeColor: settingsSwitch.activeColor,
              inactiveColor: settingsSwitch.inactiveColor,
              activeChild: Text(settingsSwitch.activeText),
              inactiveChild: Text(settingsSwitch.inactiveText),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              width: 70.0,
              height: 30.0,
              enabled: true,
              disabledOpacity: 0.5,
              onChanged: (res) async {
                await settingsSwitch.onChanged(res);
              },
            ),
          ),
        ),
        (Platform.isAndroid) ? Divider() : SizedBox(),

      ],
    );
  }
}

/* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 8),
                          child: Card(
                              child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonText(
                                text:
                                    '${S.of(context).photo_selection_download_status} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: AdvancedSwitch(
                              initialValue:
                                  model.photoSelectionDownloadStatusValue,
                              controller:
                                  model.photoSelectionDownloadStatusController,
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              activeChild: Text(S.of(context).on),
                              inactiveChild: Text(S.of(context).off),
                              // activeImage: AssetImage('assets/images/photomall_logo.png'),
                              //inactiveImage:
                              //AssetImage('assets/images/off.png'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              width: 70.0,
                              height: 30.0,
                              enabled: true,
                              disabledOpacity: 0.5,
                              onChanged: (res) async {
                                await model.studioSettingsUpdateApi(map: {
                                  photoSelectionDownloadableKey:
                                      (res) ? '1' : '0'
                                });
                                showLog(
                                    'onChanged photoSelectionDownloadStatusController $res');
                              },
                            ),
                          )),
                        )),
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 18),
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text: S
                                          .of(context)
                                          .show_photos_as_rounded_edge,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  trailing: AdvancedSwitch(
                                    initialValue:
                                        model.showPhotosAsRoundedEdgeValue,
                                    controller:
                                        model.showPhotosAsRoundedEdgeController,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    activeChild: Text(S.of(context).on),
                                    inactiveChild: Text(S.of(context).off),
                                    // activeImage: AssetImage('assets/images/photomall_logo.png'),
                                    //inactiveImage:
                                    //AssetImage('assets/images/off.png'),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    width: 70.0,
                                    height: 30.0,
                                    enabled: true,
                                    disabledOpacity: 0.5,
                                    onChanged: (res) async {
                                      await model.studioSettingsUpdateApi(map: {
                                        showPhotosAsRoundedEdgeKey:
                                            (res) ? '1' : '0'
                                      });
                                      showLog(
                                          'onChanged downloadWithIconController $res');
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 8),
                          child: Card(
                              child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonText(
                                text:
                                    '${S.of(context).download_with_watermark} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: AdvancedSwitch(
                              initialValue: model.downloadWithWaterMarkValue,
                              controller: model.downloadWithWaterMarkController,
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              activeChild: Text(S.of(context).on),
                              inactiveChild: Text(S.of(context).off),
                              // activeImage: AssetImage('assets/images/photomall_logo.png'),
                              //inactiveImage:
                              //AssetImage('assets/images/off.png'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              width: 70.0,
                              height: 30.0,
                              enabled: true,
                              disabledOpacity: 0.5,
                              onChanged: (res) async {
                                await model.studioSettingsUpdateApi(map: {
                                  downloadWithWaterMarkKey: (res) ? '1' : '0'
                                });
                                showLog(
                                    'onChanged photoSelectionDownloadStatusController $res');
                              },
                            ),
                          )),
                        )),
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 18),
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text:
                                          S.of(context).my_photos_downloadable,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  trailing: AdvancedSwitch(
                                    initialValue:
                                        model.myPhotoDownloadStatusValue,
                                    controller:
                                        model.myPhotoDownloadStatusController,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    activeChild: Text(S.of(context).on),
                                    inactiveChild: Text(S.of(context).off),
                                    // activeImage: AssetImage('assets/images/photomall_logo.png'),
                                    //inactiveImage:
                                    //AssetImage('assets/images/off.png'),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    width: 70.0,
                                    height: 30.0,
                                    enabled: true,
                                    disabledOpacity: 0.5,
                                    onChanged: (res) async {
                                      await model.studioSettingsUpdateApi(map: {
                                        myPhotosDownloadableKey:
                                            (res) ? '1' : '0'
                                      });
                                      showLog(
                                          'onChanged downloadWithIconController $res');
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 8),
                          child: Card(
                              child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonText(
                                text: '${S.of(context).hide_media_photos} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: AdvancedSwitch(
                              initialValue: model.hideMediaValue,
                              controller: model.hideMediaPhotosController,
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              activeChild: Text(S.of(context).on),
                              inactiveChild: Text(S.of(context).off),
                              // activeImage: AssetImage('assets/images/photomall_logo.png'),
                              //inactiveImage:
                              //AssetImage('assets/images/off.png'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              width: 70.0,
                              height: 30.0,
                              enabled: true,
                              disabledOpacity: 0.5,
                              onChanged: (res) async {
                                await model.studioSettingsUpdateApi(map: {
                                  hideMediaPhotosKey: (res) ? '1' : '0'
                                });
                                showLog(
                                    'onChanged photoSelectionDownloadStatusController $res');
                              },
                            ),
                          )),
                        )),
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 18),
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text: S.of(context).photos_print_status,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  trailing: AdvancedSwitch(
                                    initialValue: model.printPhotosStatusValue,
                                    controller:
                                        model.printPhotosStatusController,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    activeChild: Text(S.of(context).on),
                                    inactiveChild: Text(S.of(context).off),
                                    // activeImage: AssetImage('assets/images/photomall_logo.png'),
                                    //inactiveImage:
                                    //AssetImage('assets/images/off.png'),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    width: 70.0,
                                    height: 30.0,
                                    enabled: true,
                                    disabledOpacity: 0.5,
                                    onChanged: (res) async {
                                      await model.studioSettingsUpdateApi(map: {
                                        photosPrintStatusKey: (res) ? '1' : '0'
                                      });
                                      showLog(
                                          'onChanged downloadWithIconController $res');
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 8),
                          child: Card(
                              child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonText(
                                text: '${S.of(context).app_tour} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: AdvancedSwitch(
                              initialValue: model.appTourValue,
                              controller: model.appTourController,
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              activeChild: Text(S.of(context).on),
                              inactiveChild: Text(S.of(context).off),
                              // activeImage: AssetImage('assets/images/photomall_logo.png'),
                              //inactiveImage:
                              //AssetImage('assets/images/off.png'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              width: 70.0,
                              height: 30.0,
                              enabled: true,
                              disabledOpacity: 0.5,
                              onChanged: (res) async {
                                await model.studioSettingsUpdateApi(
                                    map: {appTourKey: (res) ? '1' : '0'});
                                showLog(
                                    'onChanged photoSelectionDownloadStatusController $res');
                              },
                            ),
                          )),
                        )),
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 18),
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text: S.of(context).download_with_icon,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  trailing: AdvancedSwitch(
                                    initialValue: model.downloadWithIconValue,
                                    controller:
                                        model.downloadWithIconController,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    activeChild: Text(S.of(context).on),
                                    inactiveChild: Text(S.of(context).off),
                                    // activeImage: AssetImage('assets/images/photomall_logo.png'),
                                    //inactiveImage:
                                    //AssetImage('assets/images/off.png'),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    width: 70.0,
                                    height: 30.0,
                                    enabled: true,
                                    disabledOpacity: 0.5,
                                    onChanged: (res) async {
                                      await model.studioSettingsUpdateApi(map: {
                                        downloadWithIconKey: (res) ? '1' : '0'
                                      });
                                      showLog(
                                          'onChanged downloadWithIconController $res');
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 8),
                          child: Card(
                              child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonText(
                                text:
                                    '${S.of(context).users_allowed_per_account_in_face_recognition} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: AdvancedSwitch(
                              initialValue:
                                  model.usersAllowedInFaceRecognitionValue,
                              controller:
                                  model.usersAllowedInFaceRecognitionController,
                              activeColor: Colors.green,
                              inactiveColor: Colors.grey,
                              activeChild: Text(S.of(context).on),
                              inactiveChild: Text(S.of(context).off),
                              // activeImage: AssetImage('assets/images/photomall_logo.png'),
                              //inactiveImage:
                              //AssetImage('assets/images/off.png'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              width: 70.0,
                              height: 30.0,
                              enabled: true,
                              disabledOpacity: 0.5,
                              onChanged: (res) async {
                                await model.studioSettingsUpdateApi(map: {
                                  usersAllowedInFaceRecognitionKey:
                                      (res) ? '1' : '0'
                                });
                                showLog(
                                    'onChanged photoSelectionDownloadStatusController $res');
                              },
                            ),
                          )),
                        )),
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 18),
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommonText(
                                      text: S
                                          .of(context)
                                          .doubt_image_clear_for_end_user,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  trailing: AdvancedSwitch(
                                    initialValue: model.doubtImageClearValue,
                                    controller: model.doubtImageClearController,
                                    activeColor: Colors.green,
                                    inactiveColor: Colors.grey,
                                    activeChild: Text(S.of(context).on),
                                    inactiveChild: Text(S.of(context).off),
                                    // activeImage: AssetImage('assets/images/photomall_logo.png'),
                                    //inactiveImage:
                                    //AssetImage('assets/images/off.png'),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    width: 70.0,
                                    height: 30.0,
                                    enabled: true,
                                    disabledOpacity: 0.5,
                                    onChanged: (res) async {
                                      await model.studioSettingsUpdateApi(map: {
                                        doubtImageClearKey: (res) ? '1' : '0'
                                      });
                                      showLog(
                                          'onChanged downloadWithIconController $res');
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),*/
