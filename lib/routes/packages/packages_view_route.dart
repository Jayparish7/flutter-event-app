import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import '../1.constants/common_constants.dart';
import 'package_route_view_model.dart';

class PackagesViewRoute extends StatefulWidget {
  const PackagesViewRoute({super.key});

  @override
  State<PackagesViewRoute> createState() => _PackagesViewRouteState();
}

class _PackagesViewRouteState extends State<PackagesViewRoute> {
  BaseWidget<PackageRouteViewModel>? baseWidget;

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: PackageRouteViewModel(),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        return Scaffold(
          //backgroundColor: Colors.transparent,
          appBar: CommonAppBar(
            title: S.of(context).packages,
            isCenterTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: (model.packages.isEmpty)
              ? Container(
                  decoration: const BoxDecoration(
                    color: photomallBodyColor,
                  ),
                  child: Center(
                    child: CommonText(
                      text: S.of(context).no_package_found,
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(

                    color: photomallBodyColor,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: model.packages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (Platform.isAndroid) ? 2 : 3),
                    itemBuilder: (context, index) {
                      return packagesCardWidget(model, index);
                    },
                  ),
                ),
        );
      },
    );
    return baseWidget!;
  }

  Widget packagesCardWidget(PackageRouteViewModel model, int index) {
    double? price = (model.packages[index]?.price)! / 100;
    double? discount = (model.packages[index]?.discount?.value ?? 0) / 100;
    return FadeInLeft(
      animate: true,
      child: Container(
        color: Colors.transparent,
        height: 150,
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Skeletonizer(
                enabled: model.isLoading.value,
                child: Card(elevation: 3,
                  surfaceTintColor: Colors.transparent,
                  color: Colors.white,
                  shadowColor: photomallBgColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (model.packages[index]!.jvtFileConnectors!.isNotEmpty)
                          ? SizedBox(
                              height: 90,
                              width: 200,
                              child: CustomCachedNetworkImageWidget(
                                  url:
                                      '${model.publicPath}/${model.packages[index]?.jvtFileConnectors?[0].jvtFile?.name}'),
                            )
                          : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: CommonText(
                          text: model.packages[index]?.name ?? '',
                          isHeading: true,
                        ),
                      ),
                      Row(
                        mainAxisAlignment:
                            (model.packages[index]?.discount?.value != null)
                                ? MainAxisAlignment.spaceEvenly
                                : MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CommonText(
                                  text: '${S.of(context).price}:',
                                  isBody: true,
                                ),
                                CommonText(
                                  text: price.toString() ?? '',
                                  isSubHeading: true,
                                ),
                              ],
                            ),
                          ),
                          (model.packages[index]?.discount?.value != null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CommonText(
                                        text: '${S.of(context).discount}:',
                                        isBody: true,
                                      ),
                                      CommonText(
                                        text: discount.toString() ?? '',
                                        isSubHeading: true,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      (model.packages[index]?.priorityScore != null)
                          ? Column(
                              children: [
                                CommonText(
                                  text: '${S.of(context).priority_score}:',
                                  isBody: true,
                                ),
                                CommonText(
                                  text: model.packages[index]?.priorityScore
                                          .toString() ??
                                      '',
                                  isSubHeading: true,
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                      height: 35,
                      width: 100,
                      decoration: BoxDecoration(
                          color: (model.packages[index]?.published == 1)
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: CommonText(
                          text: (model.packages[index]?.published == 1)
                              ? S.of(context).published
                              : S.of(context).unPublished,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
