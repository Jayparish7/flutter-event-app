import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_progress.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import 'inbox_route_view_model.dart';

class InboxViewRoute extends StatefulWidget {
  final bool isSideMenuOpen;

  const InboxViewRoute({super.key, required this.isSideMenuOpen});

  @override
  State<InboxViewRoute> createState() => _InboxViewRouteState();
}

class _InboxViewRouteState extends State<InboxViewRoute> {
  BaseWidget<InboxRouteViewModel>? baseWidget;
  double borderRadius = (Platform.isAndroid) ? 0 : 20;

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: InboxRouteViewModel(),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerLeft,
                colors: [Color(0xFF003B73), Color(0xFFd2e6f7)]),

            //fit: BoxFit.contain,
          ),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CommonAppBar(
                title: S.of(context).inbox,
                isCenterTitle: true,
                automaticallyImplyLeading: false,
              ),
              body: Skeletonizer(
                enabled: model.isLoading,
                child: (model.inbox.isEmpty)
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(borderRadius)),
                          color: photomallBodyColor,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: CommonText(
                              text:
                                  S.of(context).all_messages_from_photomall ?? '',
                              isBody: true,
                            ),
                          ),
                        ),
                      )
                    : /*ListView.builder(
                        shrinkWrap: true,
                        itemCount: model.inbox.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Card(
                            child: ListTile(
                              title: Text(
                                model.inbox[index].notification!
                                    .replaceAll(RegExp(r"\s*-\d+\s*"), ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ));
                        },
                      )*/
                    Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(borderRadius)),
                          color: photomallBodyColor,
                        ),
                        child: ExpandableListTile(
                          model,
                          isSideMenuOpen: widget.isSideMenuOpen,
                        ),
                      ),
              )),
        );
      },
    );
    return baseWidget!;
  }
}

class ExpandableListTile extends StatefulWidget {
  final InboxRouteViewModel model;
  final bool isSideMenuOpen;

  const ExpandableListTile(this.model,
      {super.key, required this.isSideMenuOpen});

  @override
  _ExpandableListTileState createState() => _ExpandableListTileState();
}

class _ExpandableListTileState extends State<ExpandableListTile> {
  @override
  Widget build(BuildContext context) {
    // Replace model.inbox[index] with your data source
    return ListView.builder(
      itemCount: widget.model.inbox.length,
      itemBuilder: (context, index) {
        final reversedIndex = widget.model.inbox.length - 1 - index;

        return Column(
          children: [
            ExpansionTile(
              iconColor: const Color(photomallYellow),
              onExpansionChanged: (value) => widget.model
                  .updateReadStatus(widget.model.inbox[reversedIndex].id),
              shape: const Border(),
              leading: DotBadgeIcon(
                icon: Icons.info_outline,
                readStatus: widget.model.inbox[reversedIndex].readStatus!,
              ),
              subtitle: Text(
                formatDateTime(widget.model.inbox[reversedIndex].createdAt ??
                    DateTime.now()),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              expansionAnimationStyle: AnimationStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              title: Text(
                // Remove `- number` from the string
                '${widget.model.eventNotificationResponse[reversedIndex].data!.eventName}-${widget.model.inbox[reversedIndex].notification!.replaceAll(RegExp(r"\s*-\d+\s*"), "")}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                // Additional widgets shown when expanded
                OrientationBuilder(builder: (context, orientation) {
                  return Column(
                    children: [
                      // Example Image widget
                      (widget.model.inbox[reversedIndex].notification!
                              .contains('expired'))
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8),
                              child: Text(
                                // Remove `- number` from the string
                                '${S.of(context).photoSelectionFor} ${widget.model.eventNotificationResponse?[reversedIndex].data!.eventName} ${S.of(context).eventHasBeenConfirmed}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                      Padding(
                        padding: EdgeInsets.only(
                            left: Platform.isAndroid ? 0 : 45.0,
                            top: 20,
                            bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  width: Platform.isAndroid
                                      ? 150
                                      : (widget.isSideMenuOpen)
                                          ? 250
                                          : 350,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomCachedNetworkImageWidget(
                                        url:
                                            '${widget.model.publicPath}/${widget.model.imageUrls[reversedIndex]}',
                                        // Your image URL from the model
                                      ),
                                    ),
                                  ),
                                ),
                                (widget.model.inbox[reversedIndex]
                                                .confirmStatus !=
                                            false &&
                                        (!widget.model.inbox[reversedIndex]
                                            .notification!
                                            .contains('expired')))
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomPrimaryButton(

                                          onPressed: () async {
                                            await widget.model
                                                .reverseConfirmationApi(
                                                    eventCode:
                                                        widget
                                                            .model
                                                            .inbox[reversedIndex]
                                                            .eventCode!,
                                                    studioCode:
                                                        widget.model.studioCode,
                                                    id: widget.model
                                                        .inbox[reversedIndex].id);
                                          },
                                          text: (widget.model.isBtnLoading !=
                                                  true)
                                              ? S
                                              .of(context)
                                              .reverse_confirmation
                                              : "Please wait",
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 10,
                                      ),
                              ],
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: Platform.isAndroid ? 0 : 12.0,
                                        bottom: 5),
                                    child: Text(
                                      widget
                                          .model
                                          .eventNotificationResponse[
                                              reversedIndex]
                                          .data!
                                          .eventName!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: CommonText(
                                        isBody: true,
                                        text:
                                            '${S.of(context).total_number_of_images} : ${widget.model.eventNotificationResponse[reversedIndex].data!.totalImages!.toString()}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: CommonText(
                                        isBody: true,
                                        text:
                                            '${S.of(context).selected_images} : ${widget.model.eventNotificationResponse[reversedIndex].data!.selectedImages!.toString()}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: CommonText(
                                        isBody: true,
                                        text:
                                            '${S.of(context).rejected_images} : ${widget.model.eventNotificationResponse[reversedIndex].data!.rejectedImages!.toString()}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: CommonText(
                                        isBody: true,
                                        text:
                                            '${S.of(context).undecided_images} : ${widget.model.eventNotificationResponse[reversedIndex].data!.undecidedImages!.toString()}'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      // Example additional text or any other widgets

                      // Add more widgets as needed
                    ],
                  );
                })
              ],
            ),
            Divider()
          ],
        );
      },
    );
  }

  String formatDateTime(DateTime dateTime) {
    // Define the desired format
    final DateFormat formatter = DateFormat('MMM d, yyyy HH:mm');
    return formatter.format(dateTime);
  }
}

class DotBadgeIcon extends StatelessWidget {
  final IconData icon; // Icon to be displayed
  final bool readStatus; // Count of unread messages

  const DotBadgeIcon({
    Key? key,
    required this.icon,
    this.readStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(icon, size: 30), // The main icon
        if (readStatus ==
            false) // Only show the dot if there are unread messages
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
