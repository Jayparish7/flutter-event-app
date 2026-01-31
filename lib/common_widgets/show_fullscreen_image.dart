import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';


import '../database/object_box_model/object_box_models.dart';
import '../routes/1.constants/common_constants.dart';

class ShowImageFullScreen extends StatelessWidget {
  final String imagePath;
  final List<String>? imagePaths;
  final Color bgColor;
  final FitType largeScreenFitType;
  final String title;
  final int? index;

  const ShowImageFullScreen(
      {Key? key,
      required this.imagePath,
      required this.bgColor,
      required this.largeScreenFitType,
      required this.title,
      this.imagePaths,
      this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Colors.white, Colors.white])),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CommonAppBar(title: title),
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Image.file(
                    File(imagePaths![index]),
                  ),
                );
              },
              itemCount: imagePaths?.length,
              pageController: controller,
            ),
            ElevatedButton(
                onPressed: () {
                  controller.jumpToPage(index! + 3);
                },
                child: const Icon(Icons.navigate_next))
          ],
        ),
      ),
    );
  }

  ImageProvider get _getPerfectImage {
    return FileImage(File(imagePath));
  }

  BoxFit? get _getPerfectFit {
    switch (largeScreenFitType) {
      case FitType.normal:
        return null;
      case FitType.covered:
        return BoxFit.cover;
      case FitType.filled:
        return BoxFit.fill;
      case FitType.contained:
        return BoxFit.contain;
      case FitType.coverWidth:
        return BoxFit.fitWidth;
      case FitType.coverHeight:
        return BoxFit.fitHeight;
    }
  }
}

enum FitType { normal, covered, filled, contained, coverWidth, coverHeight }

enum ImgType { network, file, asset }

class FullScreenView extends StatefulWidget {
  final String imagePath;
  final List<PhotoSelectionImage>? imagePaths;
  final List<OrderImage>? imagePathsForAlbum;
  final Color bgColor;
  final FitType largeScreenFitType;
  final String title;
  final int? index;
  const FullScreenView(
      {super.key,
      required this.imagePath,
      this.imagePaths,
      required this.bgColor,
      required this.largeScreenFitType,
      required this.title,
      this.index,
      this.imagePathsForAlbum});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  PageController controller = PageController();
  List<String> imagesList = [];
  @override
  void initState() {
    showLog("the data index ${widget?.title}, ");

    super.initState();
    (widget.imagePaths != null)
        ? getImages(widget.imagePaths!)
        : getImagesForAlbum(widget.imagePathsForAlbum!);
    showLog('imagesList $imagesList');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpToPage(widget.index!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(backgroundColor: Colors.black,iconTheme: const IconThemeData(color: Colors.white),),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions.customChild(
                initialScale: PhotoViewComputedScale.contained * 0.8,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.8,
                child: /*Image.file(
                  File(imagesList[index]),
                ),*/
                    Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20.0), // Adjust the border radius as needed
                      image: DecorationImage(
                        image: FileImage(File(imagesList[index])),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: imagesList.length,
            pageController: controller,
          ),
          (Platform.isAndroid)?const SizedBox():Positioned(
            top: 250,
            left: 0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(photomallYellow),
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20.0), // Adjust the value as needed
                ),
              ),
              onPressed: () {
                showLog('previous index is ${widget.index}');

                //if ((widget.index ?? 0) > 0) {
                controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                //}
              },
              child: const Icon(
                Icons.navigate_before,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          (Platform.isAndroid)?const SizedBox():Positioned(
            top: 250,
            right: 0,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(photomallYellow),
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust the value as needed
                  ),
                ),
                onPressed: () {
                  if ((widget.index ?? 0) < (imagesList.length - 1)) {
                    showLog('indexx is ${widget.index}');
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: const Icon(
                  Icons.navigate_next,
                  size: 25,
                  color: Colors.white,
                )),
          )
        ],
      ),
    );
  }

  getImages(List<PhotoSelectionImage> images) {
    if (images != null) {
      for (PhotoSelectionImage image in images) {
        imagesList.add(image.path!);
      }
    }
  }

  getImagesForAlbum(List<OrderImage> images) {
    if (images != null) {
      for (OrderImage image in images) {
        imagesList.add(image.path!);
      }
    }
  }
}
