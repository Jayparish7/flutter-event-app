import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_cached_network_image.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import 'google_review_view_model.dart';

class GoogleReviewViewRoute extends StatefulWidget {
  const GoogleReviewViewRoute({super.key});

  @override
  State<GoogleReviewViewRoute> createState() => _GoogleReviewViewRouteState();
}

class _GoogleReviewViewRouteState extends State<GoogleReviewViewRoute> {
  BaseWidget<GoogleReviewViewModel>? baseWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: GoogleReviewViewModel(),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: CommonAppBar(
            title: S.of(context).reviews,
            isCenterTitle: true,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.transparent,
          body: (model.reviews.isNotEmpty)
              ? Container(
                  padding: const EdgeInsets.only(top: 25.0),
                  decoration: const BoxDecoration(

                      color: photomallBodyColor),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1),
                      itemCount: model.reviews.length,
                      itemBuilder: (context, index) {
                        DateTime dateTime = DateTime.parse(
                            model.reviews[index].time!.toString());
                        String formattedDate =
                            DateFormat('dd-MMM-yyyy').format(dateTime);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntrinsicHeight(
                            child: SizedBox(
                              width: 200,
                              child: Card(elevation: 3,
                                surfaceTintColor: Colors.transparent,
                                color: photomallBodyColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              radius: 35,
                                              child:
                                                  CustomCachedNetworkImageWidget(
                                                      url: model
                                                          .reviews[index]
                                                          .profilePhotoUrl!),
                                            ),
                                          ),
                                          Flexible(
                                              child: CommonText(
                                            text: model
                                                .reviews[index].authorName!,
                                            style: const TextStyle(
                                                color: Color(photomallYellow),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          PannableRatingBar(
                                            spacing: 2,
                                            rate: ((model.reviews[index]
                                                        .rating!) /
                                                    10)
                                                .toDouble(),
                                            items: List.generate(
                                                5,
                                                (index) => const RatingWidget(
                                                      selectedColor: Color(
                                                          photomallYellow),
                                                      unSelectedColor:
                                                          Colors.grey,
                                                      child: Icon(
                                                        Icons.star,
                                                        size: 18,
                                                      ),
                                                    )),
                                            onChanged: (value) {
                                              // the rating value is updated on tap or drag.
                                            },
                                          ),
                                          Opacity(
                                            opacity: .5,
                                            child: CommonText(
                                              text: formattedDate,
                                              style: const TextStyle(
                                                color: Color(photomallYellow),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Flexible(
                                          flex: 2,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(28.0),
                                            child: CommonText(
                                              text: model
                                                  .reviews[index].review!
                                                  .replaceAll('\n', ''),
                                              style: const TextStyle(
                                                  color:
                                                      Color(photomallYellow),
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                )
              : Container( decoration: const BoxDecoration(

              color: photomallBodyColor),
                child: Center(
                    child: CommonText(
                      text: S.of(context).no_review_found,
                    ),
                  ),
              ),
        );
      },
    );
    return baseWidget!;
  }
}
