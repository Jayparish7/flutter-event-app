import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/shareView/share_view_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:selectable/selectable.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/common_appbar.dart';
import '../../generated/l10n.dart';
import '../1.constants/common_constants.dart';

class ShareView extends StatefulWidget {
  final String eventCode;
  final String eventName;

  const ShareView(
      {super.key, required this.eventCode, required this.eventName});

  @override
  State<ShareView> createState() => _ShareViewState();
}

class _ShareViewState extends State<ShareView> {
  BaseWidget<ShareViewModel>? baseWidget;
  Map<String, PreviewData> datas = {};
  TextEditingController sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
        model: ShareViewModel(),
        onModelReady: (model) async {
          await model.getInitialData();
        },
        builder: (context, model, child) {
          final qrData =
              '${model.domainLink}/${model.shortUrl}/${widget.eventCode}';

          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
              color: photomallBodyColor,
            ),
            child: Scaffold(
              appBar: CommonAppBar(
                title: S.of(context).share,
                isCenterTitle: true,
                appBarWithLogo: false,automaticallyImplyLeading: false,
              ),
              backgroundColor: Colors.transparent,
              body: FadeInRight(
                animate: true,
                child: Selectable(
                  selectWordOnDoubleTap: true,
                  selectWordOnLongPress: true,
                  selectionColor: Colors.grey.withOpacity(.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CommonText(
                          text: widget.eventName,
                          isTitle: true,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      (Platform.isAndroid)
                          ? Column(
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: Card(
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
                                                                      .withOpacity(
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
                                                                                  qrData,
                                                                                  context,
                                                                                  widget.eventName);
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
                                                              widget.eventName);
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
                                                                      .withOpacity(
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
                                                                                  qrData,
                                                                                  context,
                                                                                  widget.eventName);
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
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: Card(
                                        child: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CommonText(
                                                text:
                                                    '${S.of(context).event_key} :',
                                                isSubHeading: true),
                                            CommonText(
                                                text: widget.eventCode,
                                                isHeading: true),
                                          ],
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(35.0),
                                  child: SizedBox(
                                    height: 150,
                                    width: 105.w,
                                    child: Card(
                                      child: Center(
                                          child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CommonText(
                                              text: '${S.of(context).event_link} :',
                                              isSubHeading: true),
                                          LinkPreview(
                                            onLinkPressed: (link) {
                                              showMenu(
                                                context: context,
                                                position:
                                                    const RelativeRect.fromLTRB(
                                                        225.0, 225.0, 0.0, 0),
                                                items: [
                                                  PopupMenuItem<String>(
                                                    value: 'copy',
                                                    onTap: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: link));
                                                    },
                                                    child: Text(
                                                        S.of(context).copy_link),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'open',
                                                    onTap: () {
                                                      // Handle opening the link in a browser
                                                      launchUrl(Uri.parse(link));
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
                                                .headlineMedium,
                                            animationDuration:
                                                const Duration(seconds: 1),
                                            onPreviewDataFetched: (data) {
                                              setState(() {
                                                datas = {
                                                  ...datas,
                                                  '${model.domainLink}/${model.shortUrl}/${widget.eventCode}':
                                                      data,
                                                };
                                              });
                                            },
                                            previewData: datas[
                                                '${model.domainLink}/${model.shortUrl}/${widget.eventCode}'],
                                            text:
                                                '${model.domainLink}/${model.shortUrl}/${widget.eventCode}',
                                            width:
                                                MediaQuery.of(context).size.width,linkStyle: TextStyle(fontSize: 18,),
                                            imageBuilder: (previewData) {
                                              showLog(
                                                  'previewData ${'${model.domainLink}/${model.shortUrl}/${widget.eventCode}'}');
                                              // Custom image builder
                                              return Image.network(
                                                previewData,
                                                height: 100.0,
                                              );
                                            },
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: Card(
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
                                                                      .withOpacity(
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
                                                                                  qrData,
                                                                                  context,
                                                                                  widget.eventName);
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
                                                              widget.eventName);
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
                                                                      .withOpacity(
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
                                                                                  qrData,
                                                                                  context,
                                                                                  widget.eventName);
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
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: Card(
                                        child: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CommonText(
                                                text:
                                                    '${S.of(context).event_key} :',
                                                isSubHeading: true),
                                            CommonText(
                                                text: widget.eventCode,
                                                isHeading: true),
                                          ],
                                        )),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    SizedBox(
                                      height: 150,
                                      width: 105.w,
                                      child: Card(
                                        child: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CommonText(
                                                text:
                                                    '${S.of(context).event_link} :',
                                                isSubHeading: true),
                                            LinkPreview(
                                              onLinkPressed: (link) {
                                                showMenu(
                                                  context: context,
                                                  position:
                                                      const RelativeRect.fromLTRB(
                                                          225.0, 225.0, 0.0, 0),
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
                                                  .headlineMedium,
                                              animationDuration:
                                                  const Duration(seconds: 1),
                                              onPreviewDataFetched: (data) {
                                                setState(() {
                                                  datas = {
                                                    ...datas,
                                                    '${model.domainLink}/${model.shortUrl}/${widget.eventCode}':
                                                        data,
                                                  };
                                                });
                                              },
                                              previewData: datas[
                                                  '${model.domainLink}/${model.shortUrl}/${widget.eventCode}'],
                                              text:
                                                  '${model.domainLink}/${model.shortUrl}/${widget.eventCode}',
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              imageBuilder: (previewData) {
                                                showLog(
                                                    'previewData ${'${model.domainLink}/${model.shortUrl}/${widget.eventCode}'}');
                                                // Custom image builder
                                                return Image.network(
                                                  previewData,
                                                  height: 100.0,
                                                );
                                              },
                                            ),
                                          ],
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
    return baseWidget!;
  }

  getDownloadDialog(
      ShareViewModel model, qrData, BuildContext context, String qrName) {
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
        ElevatedButton(
          onPressed: () {
            model.downloadQrCode(
                qrData, int.parse(model.downloadSize.first), qrName);
            Navigator.pop(context);
          },
          child: Text(S.of(context).download),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }
}
