
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/alert_dialog.dart';
import '../../common_widgets/file_info_card.dart';
import '../../generated/l10n.dart';
import '../../utils/permission_util.dart';
import '../1.constants/common_constants.dart';
import 'dashBoard_view_model.dart';

class DashboardView extends StatefulWidget {
  final bool? isMultiStudio;

  const DashboardView({super.key, this.isMultiStudio});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  BaseWidget<DashBoardViewModel>? baseWidget;
  Map<String, PreviewData> datas = {};
  Map<String, PreviewData> appData = {};

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: DashBoardViewModel(
          progressController: Get.put(ProgressController()), context: context),
      onModelReady: (model) async {
        model.isMultiStudio = widget.isMultiStudio ?? false;
        await model.getInitialData(context);
        (Platform.isAndroid) ? await requestStoragePermission() : null;
      },
      builder: (context, model, child) {
        final qrData = model.domainUrls.first;
        final appQrData = model.playStoreUrl;
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(!Platform.isAndroid ? 20 : 0)),
              color: photomallBodyColor
              /*gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerLeft,
                colors: [Color(0xFF003B73), Color(0xFFd2e6f7)]),*/

              //fit: BoxFit.contain,
              ),
          child: Scaffold(
            backgroundColor: photomallBgColor,
            appBar: CommonAppBar(
              title: S.of(context).dashboard,
              isCenterTitle: false,
              automaticallyImplyLeading: false,
            ),
            body: (model.isLoading)
                ? MouseRegion(
                    cursor: SystemMouseCursors.wait,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: photomallBodyColor,
                      ),
                      child: const PhotomallProgress(),
                    ),
                  )
                : Skeletonizer(
                    enabled: model.isLoading,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: photomallBodyColor,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: FileInfoCardGridView(
                                data: model.dashboardData,
                              ),
                            ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 300,
                                      width: (Platform.isAndroid) ? 500 : 600,
                                      child: Card(
                                        shadowColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        color: photomallBgColor,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25.0, top: 10),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.globe,
                                                    size: 35,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      S.of(context).website,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            LinkPreview(
                                              onLinkPressed: (link) {
                                                showMenu(
                                                  context: context,
                                                  position: const RelativeRect
                                                      .fromLTRB(
                                                      225.0, 225.0, 225.0, 200),
                                                  items: [
                                                    PopupMenuItem<String>(
                                                      value: 'copy',
                                                      onTap: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: link));
                                                      },
                                                      child: Text(S
                                                          .of(context)
                                                          .copy_link),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'open',
                                                      onTap: () {
                                                        // Handle opening the link in a browser
                                                        launchUrl(
                                                            Uri.parse(link));
                                                      },
                                                      child: Text(S
                                                          .of(context)
                                                          .open_in_browser),
                                                    ),
                                                  ],
                                                );
                                              },
                                              padding: const EdgeInsets.all(25),
                                              enableAnimation: true,
                                              hideImage: true,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              animationDuration:
                                                  const Duration(seconds: 1),
                                              onPreviewDataFetched: (data) {
                                                setState(() {
                                                  datas = {
                                                    ...datas,
                                                    model.domainUrls.first:
                                                        data,
                                                  };
                                                });
                                              },
                                              previewData:
                                                  datas[model.domainUrls.first],
                                              text: model.domainUrls.first,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              imageBuilder: (previewData) {
                                                showLog(
                                                    'previewData $previewData');
                                                // Custom image builder
                                                return Image.network(
                                                  previewData,
                                                  height: 100.0,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : SizedBox(
                                    width: (Platform.isAndroid) ? 25 : 125,
                                  ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Card(
                                      shadowColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      color: photomallBgColor,
                                      child: Center(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: (!Platform.isAndroid)
                                                ? MouseRegion(
                                                    onEnter: (_) {
                                                      setState(() {
                                                        model.isHovered = true;
                                                      });
                                                    },
                                                    onExit: (_) {
                                                      setState(() {
                                                        model.isHovered = false;
                                                      });
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        QrImageView(
                                                          backgroundColor:
                                                              Colors.white,
                                                          // White background for QR code
                                                          data: qrData,
                                                          version:
                                                              QrVersions.auto,
                                                          size: 150.0,
                                                        ),
                                                        if (model.isHovered)
                                                          Positioned.fill(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black54
                                                                      .withValues(
                                                                          alpha:
                                                                              0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      S
                                                                          .of(context)
                                                                          .download_qr_code,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return getDownloadDialog(model, qrData, context, '${model.studioName}-${S.of(context).website}');
                                                                            });
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .download,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      // Show download dialog when QR code is tapped
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return getDownloadDialog(
                                                              model,
                                                              qrData,
                                                              context,
                                                              '${model.studioName}-${S.of(context).website}');
                                                        },
                                                      );
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        QrImageView(
                                                          backgroundColor:
                                                              Colors.white,
                                                          // White background for QR code
                                                          data: qrData,
                                                          version:
                                                              QrVersions.auto,
                                                          size: 150.0,
                                                        ),
                                                        if (model.isHovered)
                                                          Positioned.fill(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black54
                                                                      .withValues(
                                                                          alpha:
                                                                              0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      S
                                                                          .of(context)
                                                                          .download_qr_code,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return getDownloadDialog(model, qrData, context, '${model.studioName}-${S.of(context).website}');
                                                                            });
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .download,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  )),
                                      ),
                                    ),
                                  ),
                            (Platform.isAndroid)
                                ? const SizedBox()
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(30.0),
                                                child: SizedBox(
                                                  height: 280,
                                                  width: 450,
                                                  child: Card(
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    color: photomallBodyColor,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 25.0,
                                                                  top: 10),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                FontAwesomeIcons
                                                                    .globe,
                                                                size: 35,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text(
                                                                  S
                                                                      .of(context)
                                                                      .website,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          35,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        LinkPreview(
                                                          onLinkPressed:
                                                              (link) {
                                                            showMenu(
                                                              context: context,
                                                              position:
                                                                  const RelativeRect
                                                                      .fromLTRB(
                                                                      225.0,
                                                                      225.0,
                                                                      225.0,
                                                                      200),
                                                              items: [
                                                                PopupMenuItem<
                                                                    String>(
                                                                  value: 'copy',
                                                                  onTap: () {
                                                                    Clipboard.setData(
                                                                        ClipboardData(
                                                                            text:
                                                                                link));
                                                                  },
                                                                  child: Text(S
                                                                      .of(context)
                                                                      .copy_link),
                                                                ),
                                                                PopupMenuItem<
                                                                    String>(
                                                                  value: 'open',
                                                                  onTap: () {
                                                                    // Handle opening the link in a browser
                                                                    launchUrl(Uri
                                                                        .parse(
                                                                            link));
                                                                  },
                                                                  child: Text(S
                                                                      .of(context)
                                                                      .open_in_browser),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(25),
                                                          enableAnimation: true,
                                                          hideImage: true,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                          animationDuration:
                                                              const Duration(
                                                                  seconds: 1),
                                                          onPreviewDataFetched:
                                                              (data) {
                                                            setState(() {
                                                              datas = {
                                                                ...datas,
                                                                model.domainUrls
                                                                        .first:
                                                                    data,
                                                              };
                                                            });
                                                          },
                                                          previewData: datas[
                                                              model.domainUrls
                                                                  .first],
                                                          text: model
                                                              .domainUrls.first,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          imageBuilder:
                                                              (previewData) {
                                                            showLog(
                                                                'previewData $previewData');
                                                            // Custom image builder
                                                            return Image
                                                                .network(
                                                              previewData,
                                                              height: 100.0,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 45,
                                                right: 45,
                                                child: SizedBox(
                                                  height: 100,
                                                  width: 100,
                                                  child: Card(
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    color: const Color(
                                                        photomallYellow),
                                                    child: Center(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: (!Platform
                                                                  .isAndroid)
                                                              ? MouseRegion(
                                                                  onEnter: (_) {
                                                                    setState(
                                                                        () {
                                                                      model.isHovered =
                                                                          true;
                                                                    });
                                                                  },
                                                                  onExit: (_) {
                                                                    setState(
                                                                        () {
                                                                      model.isHovered =
                                                                          false;
                                                                    });
                                                                  },
                                                                  child: Stack(
                                                                    children: [
                                                                      QrImageView(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        // White background for QR code
                                                                        data:
                                                                            qrData,
                                                                        version:
                                                                            QrVersions.auto,
                                                                        size:
                                                                            150.0,
                                                                      ),
                                                                      if (model
                                                                          .isHovered)
                                                                        Positioned
                                                                            .fill(
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.black54.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                Center(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    S.of(context).download_qr_code,
                                                                                    style: const TextStyle(color: Colors.white),
                                                                                  ),
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return getDownloadDialog(model, qrData, context, '${model.studioName}-${S.of(context).website}');
                                                                                          });
                                                                                    },
                                                                                    icon: const Icon(
                                                                                      Icons.download,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    // Show download dialog when QR code is tapped
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return getDownloadDialog(
                                                                            model,
                                                                            qrData,
                                                                            context,
                                                                            '${model.studioName}-${S.of(context).website}');
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Stack(
                                                                    children: [
                                                                      QrImageView(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        // White background for QR code
                                                                        data:
                                                                            qrData,
                                                                        version:
                                                                            QrVersions.auto,
                                                                        size:
                                                                            150.0,
                                                                      ),
                                                                      if (model
                                                                          .isHovered)
                                                                        Positioned
                                                                            .fill(
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.black54.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                Center(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    S.of(context).download_qr_code,
                                                                                    style: const TextStyle(color: Colors.white),
                                                                                  ),
                                                                                  IconButton(
                                                                                    onPressed: () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return getDownloadDialog(model, qrData, context, '${model.studioName}-${S.of(context).website}');
                                                                                          });
                                                                                    },
                                                                                    icon: const Icon(
                                                                                      Icons.download,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                )),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        (model.playStoreUrl != '' &&
                                                !Platform.isAndroid)
                                            ? SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              30.0),
                                                      child: SizedBox(
                                                        height: 280,
                                                        width: 500,
                                                        child: Card(
                                                          surfaceTintColor:
                                                              Colors
                                                                  .transparent,
                                                          color:
                                                              photomallBodyColor,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            25.0,
                                                                        top:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      FontAwesomeIcons
                                                                          .googlePlay,
                                                                      size: 35,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        S
                                                                            .of(context)
                                                                            .android_application,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                35,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              LinkPreview(
                                                                onLinkPressed:
                                                                    (link) {
                                                                  showMenu(
                                                                    context:
                                                                        context,
                                                                    position: const RelativeRect
                                                                        .fromLTRB(
                                                                        170.0,
                                                                        225.0,
                                                                        50.0,
                                                                        0.0),
                                                                    items: [
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'copy',
                                                                        onTap:
                                                                            () {
                                                                          Clipboard.setData(
                                                                              ClipboardData(text: link));
                                                                        },
                                                                        child: Text(S
                                                                            .of(context)
                                                                            .copy_link),
                                                                      ),
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        value:
                                                                            'open',
                                                                        onTap:
                                                                            () {
                                                                          // Handle opening the link in a browser
                                                                          launchUrl(
                                                                              Uri.parse(model.playStoreUrl));
                                                                        },
                                                                        child: Text(S
                                                                            .of(context)
                                                                            .open_in_browser),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        25),
                                                                enableAnimation:
                                                                    true,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge,
                                                                animationDuration:
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                onPreviewDataFetched:
                                                                    (data) {
                                                                  setState(() {
                                                                    appData = {
                                                                      ...appData,
                                                                      model.playStoreUrl:
                                                                          data,
                                                                    };
                                                                  });
                                                                },
                                                                previewData:
                                                                    appData[model
                                                                        .playStoreUrl],
                                                                text: model
                                                                    .playStoreUrl,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                imageBuilder:
                                                                    (previewData) {
                                                                  showLog(
                                                                      'previewData');
                                                                  // Custom image builder
                                                                  return GestureDetector(
                                                                    onSecondaryTap:
                                                                        () {
                                                                      // This will handle right-click events
                                                                      showMenu(
                                                                        context:
                                                                            context,
                                                                        position: const RelativeRect
                                                                            .fromLTRB(
                                                                            100.0,
                                                                            100.0,
                                                                            0.0,
                                                                            0.0),
                                                                        items: [
                                                                          PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'copy',
                                                                            onTap:
                                                                                () {
                                                                              Clipboard.setData(ClipboardData(text: model.playStoreUrl));
                                                                            },
                                                                            child:
                                                                                Text(S.of(context).copy_link),
                                                                          ),
                                                                          PopupMenuItem<
                                                                              String>(
                                                                            value:
                                                                                'open',
                                                                            onTap:
                                                                                () {
                                                                              // Handle opening the link in a browser
                                                                              launchUrl(Uri.parse(model.playStoreUrl));
                                                                            },
                                                                            child:
                                                                                Text(S.of(context).open_in_browser),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                    child: Image
                                                                        .network(
                                                                      previewData,
                                                                      height:
                                                                          100.0,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 45,
                                                      right: 45,
                                                      child: SizedBox(
                                                        height: 100,
                                                        width: 100,
                                                        child: Card(
                                                          surfaceTintColor:
                                                              Colors
                                                                  .transparent,
                                                          color: const Color(
                                                              photomallYellow),
                                                          child: Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: (!Platform
                                                                      .isAndroid)
                                                                  ? MouseRegion(
                                                                      onEnter:
                                                                          (_) {
                                                                        setState(
                                                                            () {
                                                                          model.isHovered1 =
                                                                              true;
                                                                        });
                                                                      },
                                                                      onExit:
                                                                          (_) {
                                                                        setState(
                                                                            () {
                                                                          model.isHovered1 =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          QrImageView(
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            // White background for QR code
                                                                            data:
                                                                                appQrData,
                                                                            version:
                                                                                QrVersions.auto,
                                                                            size:
                                                                                150.0,
                                                                          ),
                                                                          if (model
                                                                              .isHovered1)
                                                                            Positioned.fill(
                                                                              child: Container(
                                                                                decoration: BoxDecoration(color: Colors.black54.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        S.of(context).download_qr_code,
                                                                                        style: const TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (context) {
                                                                                                return getDownloadDialog(model, appQrData, context, '${model.studioName}-${S.of(context).android_app}');
                                                                                              });
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.download,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // Show download dialog when QR code is tapped
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return getDownloadDialog(
                                                                                model,
                                                                                appQrData,
                                                                                context,
                                                                                '${model.studioName}-${S.of(context).android_app}');
                                                                          },
                                                                        );
                                                                      },
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          QrImageView(
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            // White background for QR code
                                                                            data:
                                                                                appQrData,
                                                                            version:
                                                                                QrVersions.auto,
                                                                            size:
                                                                                150.0,
                                                                          ),
                                                                          if (model
                                                                              .isHovered1)
                                                                            Positioned.fill(
                                                                              child: Container(
                                                                                decoration: BoxDecoration(color: Colors.black54.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        S.of(context).download_qr_code,
                                                                                        style: const TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      IconButton(
                                                                                        onPressed: () {
                                                                                          showDialog(
                                                                                              context: context,
                                                                                              builder: (context) {
                                                                                                return getDownloadDialog(model, appQrData, context, '${model.studioName}-${S.of(context).android_app}');
                                                                                              });
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.download,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
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
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 320,
                                      width: 500,
                                      child: Card(
                                        shadowColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        color: photomallBgColor,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25.0, top: 10),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    FontAwesomeIcons.googlePlay,
                                                    size: 35,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .android_application,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            LinkPreview(
                                              onLinkPressed: (link) {
                                                showMenu(
                                                  context: context,
                                                  position: const RelativeRect
                                                      .fromLTRB(
                                                      170.0, 225.0, 50.0, 0.0),
                                                  items: [
                                                    PopupMenuItem<String>(
                                                      value: 'copy',
                                                      onTap: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: link));
                                                      },
                                                      child: Text(S
                                                          .of(context)
                                                          .copy_link),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'open',
                                                      onTap: () {
                                                        // Handle opening the link in a browser
                                                        launchUrl(Uri.parse(
                                                            model
                                                                .playStoreUrl));
                                                      },
                                                      child: Text(S
                                                          .of(context)
                                                          .open_in_browser),
                                                    ),
                                                  ],
                                                );
                                              },
                                              padding: const EdgeInsets.all(25),
                                              enableAnimation: true,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              animationDuration:
                                                  const Duration(seconds: 1),
                                              onPreviewDataFetched: (data) {
                                                setState(() {
                                                  appData = {
                                                    ...appData,
                                                    model.playStoreUrl: data,
                                                  };
                                                });
                                              },
                                              previewData:
                                                  appData[model.playStoreUrl],
                                              text: model.playStoreUrl,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              imageBuilder: (previewData) {
                                                showLog('previewData');
                                                // Custom image builder
                                                return GestureDetector(
                                                  onSecondaryTap: () {
                                                    // This will handle right-click events
                                                    showMenu(
                                                      context: context,
                                                      position:
                                                          const RelativeRect
                                                              .fromLTRB(100.0,
                                                              100.0, 0.0, 0.0),
                                                      items: [
                                                        PopupMenuItem<String>(
                                                          value: 'copy',
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: model
                                                                        .playStoreUrl));
                                                          },
                                                          child: Text(S
                                                              .of(context)
                                                              .copy_link),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          value: 'open',
                                                          onTap: () {
                                                            // Handle opening the link in a browser
                                                            launchUrl(Uri.parse(
                                                                model
                                                                    .playStoreUrl));
                                                          },
                                                          child: Text(S
                                                              .of(context)
                                                              .open_in_browser),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  child: Image.network(
                                                    previewData,
                                                    height: 100.0,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : const SizedBox(
                                    width: 25,
                                  ),
                            (!Platform.isAndroid)
                                ? const SizedBox()
                                : SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Card(
                                      surfaceTintColor: Colors.transparent,
                                      color: photomallBgColor,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: (!Platform.isAndroid)
                                              ? MouseRegion(
                                                  onEnter: (_) {
                                                    setState(() {
                                                      model.isHovered1 = true;
                                                    });
                                                  },
                                                  onExit: (_) {
                                                    setState(() {
                                                      model.isHovered1 = false;
                                                    });
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      QrImageView(
                                                        backgroundColor:
                                                            Colors.white,
                                                        // White background for QR code
                                                        data: appQrData,
                                                        version:
                                                            QrVersions.auto,
                                                        size: 150.0,
                                                      ),
                                                      if (model.isHovered1)
                                                        Positioned.fill(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black54
                                                                    .withValues(
                                                                        alpha:
                                                                            0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    S
                                                                        .of(context)
                                                                        .download_qr_code,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return getDownloadDialog(
                                                                                model,
                                                                                appQrData,
                                                                                context,
                                                                                '${model.studioName}-${S.of(context).android_app}');
                                                                          });
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .download,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    // Show download dialog when QR code is tapped
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return getDownloadDialog(
                                                            model,
                                                            appQrData,
                                                            context,
                                                            '${model.studioName}-${S.of(context).android_app}');
                                                      },
                                                    );
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      QrImageView(
                                                        backgroundColor:
                                                            Colors.white,
                                                        // White background for QR code
                                                        data: appQrData,
                                                        version:
                                                            QrVersions.auto,
                                                        size: 150.0,
                                                      ),
                                                      if (model.isHovered1)
                                                        Positioned.fill(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black54
                                                                    .withValues(
                                                                        alpha:
                                                                            0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    S
                                                                        .of(context)
                                                                        .download_qr_code,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return getDownloadDialog(
                                                                                model,
                                                                                appQrData,
                                                                                context,
                                                                                '${model.studioName}-${S.of(context).android_app}');
                                                                          });
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .download,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
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
                      ),
                    ),
                  ),
          ),
        );
      },
    );
    return baseWidget!;
  }

  getDownloadDialog(
      DashBoardViewModel model, qrData, BuildContext context, String qrName) {
    return CommonAlertDialog(
      title: S.of(context).download_qr_code,
      contentWidget: Column(
        children: [
          DropdownSearch<String>(
            onChanged: (value) async {
              if (value != null) {
                showLog("Download Qr code size ${model.downloadSize}");

                model.downloadSize = [value];
                // Splitting the first element of the list
                List<String> splitValues =
                    model.downloadSize.first.split(' x ');

                // Removing duplicates
                Set<String> uniqueValues = splitValues.toSet();

                // Updating model.downloadSize with unique values joined back into a string
                model.downloadSize = [uniqueValues.join(' x ')];

                showLog('model.downloadSize.first ${model.downloadSize.first}');
                // Log the results
                showLog(
                    "downloadSize after split and deduplication: ${model.downloadSize.first}");
              }
            },
            selectedItem: model.sizeList.first,
            items: model.sizeList,
            //const ["jpeg", "pdf", "png"],
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                  labelText: S.of(context).choose_height_width,
                  filled: true,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20),
                          right: Radius.circular(20)))),
            ),
            popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                //  disabledItemFn: (int i) => i <= 3,
                ),
          ),
        ],
      ),
      actions: [
        CustomPrimaryButton(
          onPressed: () async {
            showLog('model.downloadSize.first ${model.downloadSize.first}');
            await model.downloadQrCode(
                qrData, int.parse(model.downloadSize.first), qrName);
            Navigator.pop(context);
          },
          text: S.of(context).download,
        ),
        CustomPrimaryButton(
          onPressed: () => Navigator.pop(context),
          text: S.of(context).cancel,
        ),
      ],
    );
  }
}
