import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photomall_studio_manager/api/apiRequestModels/add_event_request_model.dart'
    as request;
import 'package:photomall_studio_manager/api/apiResponseModels/add_event_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart'
    as transporter;
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/controllers/event_data_controller.dart';
import 'package:photomall_studio_manager/database/dao/event_dao.dart';
import 'package:photomall_studio_manager/database/dao/photo_selection_dao.dart';
import 'package:photomall_studio_manager/database/dao/photomall_studio_info.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/studioList/add-event.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/apiResponseModels/add_user_response_model.dart';
import '../../api/apiResponseModels/country_model.dart';
import '../../api/apiResponseModels/event_create_response_model.dart';
import '../../api/apiResponseModels/event_store_response_model.dart';
import '../../api/apiResponseModels/photo_selection_confirm_index.dart';
import '../../api/apiResponseModels/studio_events_api_call.dart';
import '../../api/apiResponseModels/studio_users_search_response_model.dart';
import '../../common_widgets/common_countrycode_picker.dart';
import '../../common_widgets/common_text_field.dart';
import '../../controllers/photo_selection_controller.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../objectbox.g.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../../utils/common_utils.dart';

class EventListViewModel extends BaseObserver {
  int skip = 0;
  String ?errorText ;
  transporter.TransporterResponse? studioData;
  bool isLoading = false;
  String routePath = '';
  BuildContext context;
  Api? apiRepo;
  ApiHelper? apiHandler;
  String studioCode = "";
  String publicPath = "";
  final eventModelDao = objectBox.eventModelDao;
  List<Events> events = [];
  List<Events> searchEvents = [];
  String searchText = "";
  var usersSearchResult = [].obs;
  var userRandomIdList = [].obs;
  String userRandomId = '';
  final TextEditingController searchController =
      TextEditingController(text: '');


  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailOrMobileController = TextEditingController();
  TextEditingController adduserNameController = TextEditingController();
  TextEditingController eventNameTextEditingController =
      TextEditingController();
  TextEditingController newCategoryTextEditingController =
      TextEditingController();
  ScrollController scrollController = ScrollController();
  PhotoSelectionController photoSelectionController =
      PhotoSelectionController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addUserFormKey = GlobalKey<FormState>();
  Rx<Country> dropDownValue = Rx<Country>(
      Country(id: 108, shortCode: "IN", name: "india", code: "+91"));
  var isPhoneNumber = false.obs;
  List<transporter.EventCategory> eventCategories = [];
  List<PlanEventPlan> eventPlans = [];
  EventCreateResponseModel? eventCreateResponse;
  String? selectedCategoryValue;
  String? selectedEventPlanValue;
  var isNewCategory = false.obs;
  var isPlanSelected = false.obs;
  var planIndexValue = 0.obs;
 int? eventsCount ;
 int currentPage = 1 ;
  EventListViewModel({
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  getInitialValues({int dbSkip = 0}) async {
    isLoading = true;
    setBusy(false);

    studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    eventsCount = await PreferenceHelper.getInt(eventsCountPreferenceKey);
    bool isEventAvailable = await upsertEvents(skip: dbSkip.toString());
    if (isEventAvailable == false) {
      skip = skip - 10;
      showLog("isEventAvailable  $skip ");
      await ToastUtil.showSnackBarAtCurrentState("No Event Available");
      isLoading = false;
      setBusy(false);
      return;
    }
    events.clear();

    events =
        await eventModelDao.getEventWhereStudioCode(studioCode, offset: dbSkip);
    List<Events> allEvents=  await eventModelDao.getEvents();
    showLog("events length allEvents ${allEvents.length} $dbSkip ${events.length}");
    await getPublicPath();
    await getStudioData();
    //await checkUpdateAvailableForLocalEvents(events);
    isLoading = false;
    setBusy(false);

    showLog('EventCategory $eventCategories');
    // await photoSelectionController.upsertPhotoSelection(null, studioCode,
    //  events: events);
    showLog('upsertPhotoSelection 1 $studioCode');

    setBusy(false);
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  searchByEvents() async {
    searchEvents = await eventModelDao.getEventBySearch(
        code: studioCode, searchQuery: searchText);
    if (searchEvents.isNotEmpty) {
      errorText = null;
      notifyListeners();
    }else{
      errorText = "No events found";
      searchEvents.clear();
      notifyListeners();

    }
    showLog("searchByEvents $events");
  }

  clearSearchEvents() {
    errorText = null;
    searchEvents.clear();
    searchController.text = '';
    notifyListeners();
    showLog("clearSearchEvents $searchEvents");
  }

  getStudioData() async {
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    showLog('prefsStudioData is $prefsStudioData');

    studioData = prefsStudioData != ''
        ? transporter.transporterResponseFromJson(prefsStudioData)
        : null;
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!
            .studiosData![studioIndex].data!.eventCategories!.isNotEmpty) {
      List<transporter.EventCategory> dataList =
          studioData!.studiosData![studioIndex].data!.eventCategories!;
      eventCategories = dataList;
    }
  }

  getEventCode(BuildContext context) async {
    Platform.isAndroid
        ? await addEventForAndroid(
            context,
            (eventCode) async {
              int lastUpdated = await getLastUpdate(eventCode);
              List<request.Event> events = [
                request.Event(
                    code: eventCode,
                    lastUpdatedAt: 0,
                    confirmedLastUpdated_at: lastUpdated)
              ];
              request.AddEventRequest addEventRequest = request.AddEventRequest(
                  studioCode: studioCode, events: events);
              List<AddEventResponse>? eventResponse =
                  await apiRepo!.addEventApiCall(addEventRequest.toJson());
              showLog('eventResponse request.AddEventRequest');
              if (eventResponse != null && eventResponse.isNotEmpty) {
                if (eventResponse[0].status == 1) {
                  EventController eventController = EventController();
                  await eventController.insertEventWhereAddedByUser(
                      eventResponse, studioCode);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } else {
                  String? message = eventResponse[0].message;
                  if (message != null) {
                    if (context.mounted) {
                      showLog("Error ErrorError ");
                      Navigator.pop(context);
                      ToastUtil.getToast(context, 'Error', message);
                    }
                  }
                }
              }
              //   Navigator.pop(context);
            },
          )
        : await addEvent(
            context,
            (eventCode) async {
              int lastUpdated = await getLastUpdate(eventCode);
              List<request.Event> events = [
                request.Event(
                    code: eventCode,
                    lastUpdatedAt: 0,
                    confirmedLastUpdated_at: lastUpdated)
              ];
              request.AddEventRequest addEventRequest = request.AddEventRequest(
                  studioCode: studioCode, events: events);
              List<AddEventResponse>? eventResponse =
                  await apiRepo!.addEventApiCall(addEventRequest.toJson());
              showLog('eventResponse request.AddEventRequest');
              if (eventResponse != null && eventResponse.isNotEmpty) {
                if (eventResponse[0].status == 1) {
                  EventController eventController = EventController();
                  await eventController.insertEventWhereAddedByUser(
                      eventResponse, studioCode);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } else {
                  String? message = eventResponse[0].message;
                  if (message != null) {
                    if (context.mounted) {
                      showLog("Error ErrorError ");
                      Navigator.pop(context);
                      ToastUtil.getToast(context, 'Error', message);
                    }
                  }
                }
              }
              //   Navigator.pop(context);
            },
          );
    await getInitialValues();
  }

  getEvent({required String eventCode}) async {
    int lastUpdated = await getLastUpdate(eventCode);
    List<request.Event> events = [
      request.Event(
          code: eventCode,
          lastUpdatedAt: 0,
          confirmedLastUpdated_at: lastUpdated)
    ];
    request.AddEventRequest addEventRequest =
        request.AddEventRequest(studioCode: studioCode, events: events);
    List<AddEventResponse>? eventResponse =
        await apiRepo!.addEventApiCall(addEventRequest.toJson());
    showLog('eventResponse request.AddEventRequest');
    if (eventResponse != null && eventResponse.isNotEmpty) {
      if (eventResponse[0].status == 1) {
        EventController eventController = EventController();
        await eventController.insertEventWhereAddedByUser(
            eventResponse, studioCode);
        if (!context.mounted) return;
        ToastUtil.showMessage(context, "Event Created Successfully", false);
      } else {
        String? message = eventResponse[0].message;
        if (message != null) {
          if (context.mounted) {
            showLog("Error ErrorError ");
            Navigator.pop(context);
            ToastUtil.getToast(context, 'Error', message);
          }
        }
      }
    }
    await getInitialValues();
  }

  Future<bool> upsertEvents({String skip = "0"}) async {
    showLog("upsertEvents $skip");
    StudioEventsResponseModel? response =
        await apiRepo?.studioEventsApiCall(skip: skip);
    if (response == null) {
      return false;
    }
  int pageNum = int.parse(skip)~/10+1;
    List<String> eventCodes =
        response.photomallEventCodes?.map((e) => e.eventCode ?? '').toList() ??
            [];
    if (eventCodes.isEmpty) {
      return false;
    }
showLog("upsertEvents ${response.photomallEventCodes}");
    List<request.Event> events = [];
    for (String event in eventCodes) {
      events.add(request.Event(
          code: event, lastUpdatedAt: 0, confirmedLastUpdated_at: 0));
      showLog("upsertEvents photomallEventCodes ${event}");

    }
    request.AddEventRequest addEventRequest =
        request.AddEventRequest(studioCode: studioCode, events: events);
    List<AddEventResponse>? eventResponse =
        await apiRepo!.addEventApiCall(addEventRequest.toJson());
    showLog('eventResponse request.AddEventRequest');
    if (eventResponse != null && eventResponse.isNotEmpty) {
      showLog('eventResponse : ${eventResponse.length}');

     // if (eventResponse[0].status == 1) {
        EventController eventController = EventController();
        await eventController.insertEventWhereAddedByUser(
            eventResponse, studioCode,
            isFromEventsPage: true);
        for (PhotomallEventCode event in response.photomallEventCodes ?? []) {
          await eventModelDao.updateCreatedAtWhereEvent(
            page: pageNum,
              createdAt: DateFormat('MM/dd/yyyy hh:mm a')
                  .parse(event.eventCreatedAt ?? ""),
              eventCode: event.eventCode ?? "",

          );
        }
     // }
    }
    return true;
  }

  /* Future<void> checkUpdateAvailableForLocalEvents(
    List<appDb.Event> events,
  ) async {
    if (events.isNotEmpty) {
      List<request.Event> eventApiList = [];
      for (appDb.Event event in events) {
        int lastUpdated = await getLastUpdate(event.code);
        eventApiList.add(request.Event(
            code: event.code,
            lastUpdatedAt: event.lastUpdatedAt,
            confirmedLastUpdated_at: event.lastUpdatedAt));
      }
      if (eventApiList.isNotEmpty) {
        request.AddEventRequest addEventRequest = request.AddEventRequest(
            studioCode: studioCode, events: eventApiList);
        List<AddEventResponse>? eventResponse =
            await apiRepo!.addEventApiCall(addEventRequest.toJson());
        if (eventResponse != null) {
          EventController eventController = EventController();
          await eventController.upsertEvent(eventResponse, studioCode);
        }
      }
    } else {
      showLog("no event available in db ...");
    }
  }*/

  getPublicPath() async {
    final photoMallStudioInfoDao = objectBox.photoMallStudioInfoDao;
    PhotomallStudioInfo? studioInfoData =
        await photoMallStudioInfoDao.getStudioInfoWhereCode(studioCode);
    showLog("getPublicPath objectBox: ${studioInfoData?.code}");
    if (studioInfoData != null) {
      transporter.Data studiosDatum =
          transporter.Data.fromJson(json.decode(studioInfoData.value));
      publicPath = studiosDatum.publicStoragePath!;
    }
  }

  Future<int> getLastUpdate(String eventCode) async {
    // get photo selection row
    final photoSelectionDao = objectBox.photoSelectionDao;

    PhotoSelection? photoSelection =
        await photoSelectionDao.getPhotoSelectionWhereEventCode(eventCode);
    if (photoSelection == null) {
      return 0;
    } else {
      return photoSelection.confirmedLastUpdatedAt;
    }
  }

  createEvent() async {
    usersSearchResult.clear();
    userRandomIdList.clear();
    userNameTextEditingController.clear();
    eventNameTextEditingController.clear();
    newCategoryTextEditingController.clear();
    selectedCategoryValue = null;
    selectedEventPlanValue = null;
    isNewCategory.value = false;
    isPlanSelected.value = false;
    try {
      await createEventApiCall();
    } catch (e) {
      showLog('exception in eventCreateUrlApiCall $e');
    }

    if (context.mounted && eventCreateResponse != null) {
      await showDialog(
          context: context,
          builder: ((context) => CommonAlertDialog(
                title: S.of(context).createEvent,
                contentWidget: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 700,
                    child: Column(
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPrimaryButton(
                                isLeadingIcon: true,
                                height: 45,
                                onPressed: () async {
                                  try {
                                    await CommonUtils.setCountriesValue();
                                    if (!context.mounted) return;
                                    await addUserDialog(context);
                                    showLog('add user btn - add event');
                                  } catch (e) {
                                    showLog('add user btn $e');
                                  }
                                },
                                text: " ${S.of(context).addUser}",
                                // ),
                                icon: Icons.person_add,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                            onChanged: (text) async {
                              showLog('search text is $text');
                              await getStudioUsersSearchApi(text);
                            },
                            validator: (String? value) {
                              if (value == null || value == '') {
                                return "Please Enter User Name";
                              }
                            },
                            controller: userNameTextEditingController,
                            autofocus: true,
                            decoration: CommonTextField.getTextFieldDecoration(
                                null,
                                hintText: S.of(context).selectUserName,
                                labelText: S.of(context).userName)),
                        Obx(() {
                          return usersSearchResult.isNotEmpty
                              ? Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                        controller: scrollController,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: usersSearchResult.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: CommonText(
                                              text: usersSearchResult[index],
                                              isBody: true,
                                            ),
                                            onTap: () {
                                              userRandomId =
                                                  userRandomIdList[index];
                                              userNameTextEditingController
                                                      .text =
                                                  usersSearchResult[index];
                                              usersSearchResult.clear();
                                              userRandomIdList.clear();
                                              notifyListeners();
                                            },
                                          );
                                        }),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),
                        DropdownButtonFormField<String>(
                          borderRadius: dropdownButtonFormField,
                          dropdownColor: Colors.white,
                          decoration: CommonTextField.getTextFieldDecoration(
                              null,
                              hintText: S.of(context).selectEventPlan,
                              labelText: S.of(context).eventPlan),
                          value: selectedEventPlanValue,
                          hint: Text(S.of(context).selectEventPlan),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              showLog('newValue $newValue');
                              planIndexValue.value =
                                  getEventPlanForUi(newValue);
                            }
                            showLog('selectedEventPlanValue');
                            selectedEventPlanValue = newValue;
                            isPlanSelected.value = true;
                            notifyListeners();
                          },
                          validator: (String? value) {
                            if (value == null) {
                              return 'Please select an Event Plan';
                            }
                          },
                          items:
                              eventPlans.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value.eventPlan?.code ?? '',
                              child: Text(value.eventPlan?.name ?? ""),
                            );
                          }).toList(),
                        ),
                        Obx(
                          () => isPlanSelected.value == true
                              ? Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10, // Add some spacing between items
                                  runSpacing: 10,
                                  children: [
                                    _buildInfoTile(
                                        S.of(context).price,
                                        (eventPlans[planIndexValue.value]
                                                    .eventPlan!
                                                    .attributes!
                                                    .price! /
                                                100)
                                            .toInt()
                                            .toString()),
                                    _buildInfoTile(
                                        "Ai status",
                                        eventPlans[planIndexValue.value]
                                                    .eventPlan!
                                                    .attributes!
                                                    .aiEnabled
                                                    .toString() ==
                                                "1"
                                            ? "Enabled"
                                            : "Disabled"),
                                    _buildInfoTile(
                                        "Photos Count",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .photoAlbumImageCount
                                            .toString()),
                                    _buildInfoTile(
                                        "Photos Validity",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .photoAlbumValidity
                                            .toString()),
                                    _buildInfoTile(
                                        "Photo Selection Image Count",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .photoSelectionImageCount
                                            .toString()),
                                    _buildInfoTile(
                                        "Photo Selection Validity",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .photoSelectionValidity
                                            .toString()),
                                    _buildInfoTile(
                                        "e-Album Image Count",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .ePhotobookImageCount
                                            .toString()),
                                    _buildInfoTile(
                                        "E-Album Validity",
                                        eventPlans[planIndexValue.value]
                                            .eventPlan!
                                            .attributes!
                                            .ePhotobookValidity
                                            .toString()),
                                    _buildInfoTile(
                                        "Album Downloadable",
                                        eventPlans[planIndexValue.value]
                                                    .eventPlan!
                                                    .attributes!
                                                    .albumDownload
                                                    .toString() ==
                                                "1"
                                            ? "Enabled"
                                            : "Disabled"),
                                    _buildInfoTile(
                                        "Photo Selection Downloadable",
                                        eventPlans[planIndexValue.value]
                                                    .eventPlan!
                                                    .attributes!
                                                    .photoSelectionDownload
                                                    .toString() ==
                                                "1"
                                            ? "Enabled"
                                            : "Disabled"),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        DropdownButtonFormField<String>(
                          borderRadius: dropdownButtonFormField,
                          dropdownColor: Colors.white,
                          decoration: CommonTextField.getTextFieldDecoration(
                              null,
                              hintText: S.of(context).selectEventCategory,
                              labelText: S.of(context).eventCategory),
                          value: selectedCategoryValue,
                          hint: Text(S.of(context).selectEventCategory),
                          onChanged: (String? newValue) {
                            selectedCategoryValue = newValue;
                            if (newValue == 'gseyssci') {
                              isNewCategory.value = true;
                            } else {
                              isNewCategory.value = false;
                            }
                            notifyListeners();
                          },
                          validator: (String? value) {
                            if (value == null) {
                              return 'Please select an Event category';
                            }
                            if (value == 'gseyssci') {
                              selectedCategoryValue = value;
                              isNewCategory.value = true;
                              showLog('values is $value');
                            }
                          },
                          items: eventCategories.map<DropdownMenuItem<String>>(
                              (transporter.EventCategory value) {
                            return DropdownMenuItem<String>(
                              value: value.code,
                              child: Text(value.name ?? ""),
                            );
                          }).toList(),
                        ),
                        Obx(
                          () => isNewCategory.value == true
                              ? TextFormField(
                                  controller: newCategoryTextEditingController,
                                  onChanged: (text) {},
                                  validator: (String? value) {
                                    if (value == null || value == '') {
                                      return 'Please enter Category Name';
                                    }
                                  },
                                  decoration:
                                      CommonTextField.getTextFieldDecoration(
                                          null,
                                          hintText:
                                              S.of(context).addNewCategory,
                                          labelText:
                                              S.of(context).addNewCategory))
                              : const SizedBox.shrink(),
                        ),
                        TextFormField(
                          controller: eventNameTextEditingController,
                          decoration: CommonTextField.getTextFieldDecoration(
                              null,
                              hintText: S.of(context).eventName,
                              labelText: S.of(context).eventName),
                          validator: (String? value) {
                            if (value == null || value == '') {
                              return 'Please enter Event Name';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  CustomPrimaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                      usersSearchResult.clear();
                    },
                    text: S.of(context).close,
                  ),
                  CustomPrimaryButton(
                    onPressed: () async {
                      showLog("selectedCategoryValue $selectedEventPlanValue");
                      if (_formKey.currentState!.validate()) {
                        try {
                          isLoading = true;
                          notifyListeners();
                          Navigator.pop(context);
                          EventStoreResponseModel? response =
                              await apiRepo?.eventsStoreApiCall(
                                  eventName:
                                      eventNameTextEditingController.text,
                                  newCategoryName: isNewCategory.value
                                      ? newCategoryTextEditingController.text
                                      : '',
                                  eventCategoryCode: isNewCategory.value
                                      ? "0"
                                      : selectedCategoryValue!,
                                  eventPlanCode: selectedEventPlanValue!,
                                  userRandomId: userRandomId);
                          if (response != null &&
                              response.photomallEventCode != null) {
                            await getEvent(
                                eventCode: response.photomallEventCode!);
                          } else {
                            await Future.delayed(const Duration(seconds: 2));
                            ToastUtil.showSnackBarAtCurrentState(
                                response?.errorMessage ??
                                    "Failed to create Event",
                                isError: true,
                                seconds: 5);
                          }
                          isLoading = false;
                          notifyListeners();
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastUtil.showMessage(
                              context, "Failed to create Event", true);
                        }
                      }
                    },
                    text: S.of(context).submit,
                  ),
                ],
              )));
    }
  }

  createEventApiCall() async {
    eventCreateResponse = null;
    eventPlans.clear();
    try {
      eventCreateResponse = await apiRepo?.eventCreateUrlApiCall();
      if (eventCreateResponse != null) {
        eventPlans = eventCreateResponse!.studioPlan!.plan!.planEventPlans!;
        showLog("eventPlans ${eventPlans}");
      }
    } catch (e) {
      showLog('createEventApiCall $e');
    }
  }

  getStudioUsersSearchApi(String text) async {
    StudioUsersSearchResponseModel? response =
        await apiRepo?.eventStudioUsersSearchApiCall(searchString: text);
    if (response != null && response.studioUsers!.isNotEmpty) {
      usersSearchResult.clear();
      userRandomIdList.clear();
      for (int i = 0; i < response.studioUsers!.length; i++) {
        String id = response.studioUsers![i].userRandomId.toString();
        String name = response.studioUsers![i].name.toString();
        String emails = response.studioUsers![i].emails.toString();
        List<String>? phones = [];
        for (int j = 0; j < response.studioUsers![i].phones!.length; j++) {
          //phones.add(response.studioUsers![i].phones![j].countryId.toString());
          phones
              .add(response.studioUsers![i].phones![j].phoneNumber.toString());
        }
        usersSearchResult.add(name + emails + phones.toString());
        userRandomIdList.add(id);
      }
    }
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      width: Platform.isAndroid ? 100 : 150, // Adjust width as needed
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(text: title, isBody: true),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  int getEventPlanForUi(String newValue) {
    int i;
    for (i = 0; i < eventPlans.length; i++) {
      if (newValue == eventPlans[i].eventPlan?.code) {
        showLog('getEventPlanForUi $i');
        return i;
      }
    }
    return i;
  }

  addUserDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: ((context) => CommonAlertDialog(
              title: S.of(context).addUser,
              contentWidget: SizedBox(
                width: 700,
                child: Column(
                  spacing: 5,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        cursorColor: Colors.blueGrey,
                        controller: adduserNameController,
                        decoration: InputDecoration(
                          labelText: "${S.of(context).name}(Optional)",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(photomallYellow), width: 1.0)),
                        ),
                      ),
                    ),
                    Obx(() {
                      return isPhoneNumber.value
                          ? Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shadowColor: photomallBodyColor,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 0.5,
                                      color: Color(photomallYellow)),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CustomCountryPicker(
                                  dropDownValue: dropDownValue.value.id!,
                                  onchangeDropDown: (int id) async {
                                    Country? value =
                                        CommonUtils.getObjectByCountryId(id);
                                    dropDownValue.value = value!;
                                    if (emailOrMobileController
                                        .text.isNotEmpty) {
                                      if (emailOrMobileController.text[0] ==
                                          "+") {
                                        Country list = await CommonUtils
                                                .separatePhoneAndDialCode(
                                                    emailOrMobileController
                                                        .text)!
                                            .object!;

                                        String countryCode = list.code!;
                                        emailOrMobileController.text =
                                            emailOrMobileController.text
                                                .replaceAll(
                                                    countryCode, value!.code!);
                                      }
                                    }
                                  },
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                    Form(
                      key: _addUserFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextFormField(
                          cursorColor: Colors.blueGrey,

                          validator: (value) {
                            bool isPhoneValid = RegExp(r'^\+?[0-9]{7,15}$')
                                .hasMatch(value ?? "");
                            showLog("isPhoneValid mail $isPhoneValid");

                            if (value == null ||
                                value.isEmpty ||
                                (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                        .hasMatch(value) &&
                                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value))) {
                              return S
                                  .of(context)
                                  .please_enter_a_valid_phone_number_or_email;
                            }
                            return null;
                          },

                          onChanged: (value) {
                            bool isOnlyNumbers =
                                RegExp(r'^\d+$').hasMatch(value ?? "");

                            showLog(
                                'onChanged isPhoneValid $isOnlyNumbers $value:${emailOrMobileController.text}');
                            if (isOnlyNumbers) {
                              isPhoneNumber.value = true;
                            } else {
                              isPhoneNumber.value = false;
                            }
                            // _validateInput(value);
                          },
                          //onSubmitted: (value) {},
                          controller: emailOrMobileController,
                          decoration: InputDecoration(
                            labelText: S.of(context).phone_email_address,
                            labelStyle: const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(photomallYellow), width: 1.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CustomPrimaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: S.of(context).close,
                ),
                CustomPrimaryButton(
                  onPressed: () async {
                    if (_addUserFormKey.currentState!.validate()) {
                      showLog('_addUserFormKey ${emailOrMobileController.text} '
                          '\n code ${dropDownValue.value.id} \n ${adduserNameController.text}');

                      AddUserResponseModel? response =
                          await apiRepo?.addUserApiCall(
                              emailOrPhone: emailOrMobileController.text,
                              name: adduserNameController.text,
                              country: dropDownValue.value.id);
                      if (response != null && response.user != null) {
                        showLog("response ${response.message}");
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ToastUtil.showMessage(
                            context, "User added Successfully", false);
                      }
                    }
                  },
                  text: S.of(context).submit,
                ),
              ],
            )));
  }
}
