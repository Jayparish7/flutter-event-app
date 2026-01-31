import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../generated/l10n.dart';
import '../routes/1.constants/route_constants.dart';
import '../routes/sideMenu/side_menu_bar.dart';
import '../routes/studioDetail/event_argument_model.dart';

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    Key? key,
    required this.info,
  }) : super(key: key);

  final CloudStorageInfo info;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (info.title == S.of(context).events) {
          showLog("onTap: ${info.title}");
          Navigator.pop(context);
          Navigator.pushNamed(context, RoutePaths.sideMenuView,
              arguments: SideMenuArguments(Platform.isAndroid ? 1 : 2));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,

          /* border: Border.fromBorderSide(BorderSide(
              color: Colors.black,
              width: .2,
              strokeAlign: BorderSide.strokeAlignInside)),*/
          borderRadius: const BorderRadius.all(Radius.circular(
              10)), /*image: DecorationImage(image: AssetImage(info.svgSrc??"",))*/
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: (Platform.isAndroid)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Tooltip(
                message: info.title!,
                decoration: toolTipDecoration,
                child: Row(
                  spacing: 3,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(defaultPadding * 0.50),
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: info.color?.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Image.asset(
                        info.svgSrc ?? "",
                      ),
                    ),
                    Flexible(
                      child: Text(
                        info.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${info.numOfFiles}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: info.color!),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color?.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage??1 / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}*/
class CloudStorageInfo {
  final String? svgSrc, title, totalStorage;
  final int? numOfFiles, percentage;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}

const primaryColor = Color(0xFF2697FF);
var secondaryColor = Colors.grey.withValues(alpha: 0.1);
/*const bgColor = Color(0xFF212332);*/

const defaultPadding = 16.0;

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 2.0,
    required this.data,
  }) : super(key: key);

  final int crossAxisCount;
  final List<CloudStorageInfo> data;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (Platform.isAndroid)
            ? (orientation == Orientation.portrait)
                ? 2
                : 4
            : crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: (Platform.isAndroid) ? 1.5 : childAspectRatio,
      ),
      itemBuilder: (context, index) =>
          FadeInLeft(animate: true, child: FileInfoCard(info: data[index])),
    );
  }
}
