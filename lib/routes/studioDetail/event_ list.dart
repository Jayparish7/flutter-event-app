import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_hover_card.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/eventSubView/event_sub_view_arguments.dart';
import 'package:photomall_studio_manager/routes/studioDetail/event_list_view_model.dart';

import '../../common_widgets/common_cached_network_image.dart';
import '../../common_widgets/common_elevated_button.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../1.constants/key_constants.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;

class EventListView extends StatefulWidget {
  final String studioCode;

  const EventListView({Key? key, required this.studioCode}) : super(key: key);

  @override
  State<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  BaseWidget<EventListViewModel>? baseWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLog("Event detailed view ${widget.studioCode}");
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      setStudioCode(widget.studioCode);
      ShowCaseWidget.of(context).startShowCase([addEventKey]);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    baseWidget = BaseWidget<EventListViewModel>(
      model: EventListViewModel(context: context),
      onModelReady: (model) async => await model.getInitialValues(),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            showLog("poping");
            Navigator.pop(context);
            return true;
          },
          child: Scaffold(
            backgroundColor: photomallBodyColor,

            appBar: CommonAppBar(
              title: S.of(context).events,
              isCenterTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: model.isLoading
                ? Container(
                    decoration: const BoxDecoration(
                      color: photomallBodyColor,
                    ),
                    child: const PhotomallProgress())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: photomallBodyColor,
                      ),
                      child: Column(children: [
                        model.events.isNotEmpty /*&& !Platform.isAndroid*/
                            ? SizedBox(
                                width: Platform.isAndroid
                                    ? size.width * .9
                                    : size.width * .3,
                                child: AnimatedSearchBar(
                                    label: 'Search by Event name',
                                    labelAlignment: Alignment.center,
                                    controller: model.searchController,
                                    labelStyle: const TextStyle(fontSize: 16),
                                    searchStyle:
                                        const TextStyle(color: photomallColor),
                                    cursorColor: photomallColor,
                                    textInputAction: TextInputAction.done,
                                    autoFocus: false,
                                    searchDecoration: InputDecoration(
                                      errorText: model.errorText,
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      hintText: 'Search',
                                      alignLabelWithHint: true,
                                      fillColor: photomallColor,
                                      focusColor: photomallColor,
                                      hintStyle: const TextStyle(
                                          color: photomallColor),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    onChanged: (value) async {
                                      showLog('value on Change $value ');

                                      model.searchText = value;
                                      await model.searchByEvents();
                                    },
                                    closeIcon: IconButton(
                                        onPressed: () {
                                          model.clearSearchEvents();
                                        },
                                        icon: const Icon(Icons.close)),
                                    onFieldSubmitted: (value) {
                                      showLog('value on Field Submitted');

                                      model.searchText = value;
                                    }),
                              )
                            : const SizedBox.shrink(),
                        (model.events.isEmpty)
                            ? SizedBox(
                                height: size.height * .30,
                              )
                            : const SizedBox.shrink(),
                        showEventListView(model),
                        (model.events.length < 10)
                            ? SizedBox(
                                height: size.height * .45,
                              )
                            : const SizedBox.shrink(),
                        (model.events.isNotEmpty && model.searchEvents.isEmpty)
                            ? Padding(
                                padding:  EdgeInsets.only(
                                    left: (Platform.isAndroid) ? 5:0.0,
                                    right: (Platform.isAndroid) ? 5 : 75),
                                child: NumberPagination(
                                  buttonRadius:(Platform.isAndroid) ?5: 100,
                                  fontSize: 14,
                                  buttonElevation: 2,

                                  selectedButtonColor: photomallColor,
                                  firstPageIcon: const Icon(
                                    Icons.first_page,
                                    color: photomallColor,
                                  ),
                                  previousPageIcon: const Icon(
                                      Icons.keyboard_arrow_left,
                                      color: photomallColor),
                                  nextPageIcon: const Icon(
                                      Icons.keyboard_arrow_right,
                                      color: photomallColor),
                                  lastPageIcon: const Icon(Icons.last_page,
                                      color: photomallColor),
                                  onPageChanged: (int index) async {
                                    model.currentPage = index;

                                    model.skip = index == 1
                                        ? (index) * 0
                                        : (index - 1) * 10;

                                    showLog(
                                        "NumberPagination ${model.skip} $index");
                                    //if(!context.mounted)return;
                                    await model.getInitialValues(
                                        dbSkip: model.skip);
                                    // handle page change...
                                  },
                                  visiblePagesCount: 5,
                                  totalPages:
                                      (model.eventsCount! / 10).ceil() ?? 2,
                                  currentPage: model.currentPage,
                                  // enableInteraction: false,
                                ),
                              )
                            : const SizedBox.shrink(),
                         SizedBox(
                          height: Platform.isAndroid ? size.height*.1: 25,
                        ),

                      ]),
                    ),
                  ),
            floatingActionButton: !model.isLoading
                ? Wrap(
                    spacing: 10,
                    children: [
                      CustomPrimaryButton(
                        isLeadingIcon: true,
                        height: 45,
                        onPressed: () async {
                          try {
                            showLog('FloatingActionButton - add event');

                            await model.getEventCode(context);
                          } catch (e) {
                            showLog('FloatingActionButton $e');
                          }
                        },
                        text: S.of(context).add_event,
                        // ),
                        icon: Icons.add,
                      ),
                      CustomPrimaryButton(
                        isLeadingIcon: true,
                        height: 45,
                        onPressed: () async {
                          try {
                            showLog('FloatingActionButton - add event');

                            await model.createEvent();
                          } catch (e) {
                            showLog('FloatingActionButton $e');
                          }
                        },
                        text: S.of(context).createEvent,
                        // ),
                        icon: Icons.create,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        );
      },
    );
    return baseWidget!;
  }

  title(EventListViewModel model) {
    return Wrap(
      children: List.generate(model.events.length, (index) {
        return CommonAppBar(title: model.events[index].categoryName);
      }),
    );
  }

  showEventListView(EventListViewModel model) {
    showLog('showEventListView ${model.events.length}');
    bool isMobile = MediaQuery.of(context).size.width < 700;
    int eventLength = model.searchEvents.isEmpty
        ? model.events.length
        : model.searchEvents.length;
    List<Events> events =
        model.searchEvents.isEmpty ? model.events : model.searchEvents;
    return (model.events.isNotEmpty && !model.isLoading)
        ? GridView.builder(
            padding: const EdgeInsets.only(bottom: 25),
            shrinkWrap: true,
            physics: ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (Platform.isAndroid) ? 1 : 3,
                childAspectRatio: (Platform.isAndroid) ? 2 : 2.0),
            itemCount: eventLength,
            itemBuilder: (context, index) {
              return FadeInLeft(
                animate: true,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.eventSubView,
                      arguments: EventSubViewArguments(
                          eventCode: events[index].code,
                          studioCode: events[index].studioCode,
                          eventName: events[index].name),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, top: 25),
                    child: Commonhovercard(
                      child: Stack(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        //  mainAxisSize: MainAxisSize.max,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.stretch, //add this
                        children: <Widget>[
                          events[index].coverImage != null
                              ? Positioned(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFF003B73),
                                              Color(0xFFd2e6f7),
                                            ])),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CustomCachedNetworkImageWidget(
                                        url:
                                            '${model.publicPath}/${events[index].coverImage}',
                                        fitSize: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 170,
                                  child: Image.asset(
                                      fit: BoxFit.fitWidth,
                                      'assets/images/forest.jpg')),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: UniqueText(
                              text: events[index].name,
                              isTitle: true,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 5,
                            child: UniqueText(
                              text:
                                  '${S.of(context).category} :${events[index].categoryName}',
                              isTitle: true,
                            ),
                          )

                          /* (model.events[index].userName!=null)? UniqueText(
                        text: model.events[index].userName!,
                        isTitle: true,
                      ):const SizedBox.shrink()*/
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
        : Center(
            child: CommonText(
              text: '             ${S.of(context).no_events}',
            ),
          );
  }

  void setStudioCode(String studioCodes) async {
    await PreferenceHelper.setString(eventCodePreferenceKey, studioCodes);
  }
}
