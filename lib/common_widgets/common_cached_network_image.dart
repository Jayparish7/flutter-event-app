import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_progress.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/cache_utils.dart';

import '../generated/l10n.dart';

class CustomCachedNetworkImageWidget extends StatefulWidget {
  final String url;
  final BoxFit? fitSize;
  final int? memCacheHeight;
  final bool? isError;
  final bool isEventCover;

  const CustomCachedNetworkImageWidget(
      {Key? key, required this.url, this.fitSize, this.memCacheHeight, this.isError, this.isEventCover=false})
      : super(key: key);

  @override
  State<CustomCachedNetworkImageWidget> createState() =>
      _CustomCachedNetworkImageWidgetState();
}

class _CustomCachedNetworkImageWidgetState
    extends State<CustomCachedNetworkImageWidget> {
  CacheUtil cacheUtil = CacheUtil();
  CachedNetworkImageProvider? image;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    image = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    showLog("image loading ..${widget.url}");
  }

  @override
  Widget build(BuildContext context) {
    CachedNetworkImage image = CachedNetworkImage(
        memCacheHeight: widget.memCacheHeight,
        fit: widget.fitSize,
        cacheManager: cacheUtil.customCachedManager,
        imageUrl: widget.url,
        errorWidget: (context, url, error) {
          showLog("Error : $url");
          return FittedBox(
            child:(widget.isError == false)? const SizedBox(): Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              (!widget.isEventCover) ?   const Icon(
                  Icons.image,
                  color: Colors.black,
                  size: 40,
                ):const SizedBox(),
                (!widget.isEventCover) ?
                const CommonText(
                  text: "",
                 isLabel: true,
                ):CommonText(text: S.of(context).add_event_cover_image_text,)
              ],
            ),
          );
        },
        placeholder: (
            a,
            b,
            ) {
          return const FittedBox(child: CommonCircularProgress());
        });
    return image;
  }
}