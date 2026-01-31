import 'dart:io';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photomall_studio_manager/common_widgets/common_cached_network_image.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_progress.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/common_widgets/show_fullscreen_image.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;

import 'package:cross_scroll/cross_scroll.dart';
import 'package:flutter/material.dart';

import '../database/object_box_model/object_box_models.dart';
import '../routes/1.constants/common_constants.dart';
import '../routes/albumDetail/album_detail_view_model.dart';

class DualScroll extends StatelessWidget {
  final Widget child;

  const DualScroll({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrossScroll(
      child: child,
    );
  }
}

class PaginatedImageGridView extends StatefulWidget {
  final List<OrderImage> allImages;
  final AlbumDetailedController model;

  const PaginatedImageGridView(
      {Key? key, required this.allImages, required this.model})
      : super(key: key);

  @override
  _PaginatedImageGridViewState createState() => _PaginatedImageGridViewState();
}

class _PaginatedImageGridViewState extends State<PaginatedImageGridView> {
  List<OrderImage> displayedImages = [];
  final TextEditingController _pageController = TextEditingController();
  int imagesPerPage = 15; // Number of images per page
  int currentPage = 1;
  int totalPages = 1;
  int page = Platform.isAndroid ? 1 : 5;

  @override
  void initState() {
    super.initState();

    totalPages = (widget.allImages.length / imagesPerPage).ceil();
    _loadPage(currentPage);
  }

  /// Loads a specific page
  void _loadPage(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
      int startIndex = (pageNumber - 1) * imagesPerPage;
      int endIndex =
          (startIndex + imagesPerPage).clamp(0, widget.allImages.length);
      displayedImages = widget.allImages.sublist(startIndex, endIndex);
    });
  }

  /// Jump to Page using Input Field
  void _jumpToPage() {
    int enteredPage = int.tryParse(_pageController.text) ?? 1;
    if (enteredPage >= 1 && enteredPage <= totalPages) {
      _loadPage(enteredPage);
    }
    _pageController.clear();
  }

  @override
  void didUpdateWidget(covariant PaginatedImageGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.model.imagesCount = widget.allImages.length.toString();

    showLog("Images received: ${widget.allImages.length}");
    showLog("Current page: $currentPage / $totalPages");
    if (widget.allImages != oldWidget.allImages) {
      totalPages = (widget.allImages.length / imagesPerPage).ceil();
      currentPage = 1;
      //_loadPage(currentPage);
      setState(() {
        _loadPage(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.model.pendingImagesForUpload==[] && widget.model.isLoading ==false
        ? const SizedBox(
            child: Center(
                child: Text(
              "No Images Found in the selected Folder",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            )),
          )
        : Column(
            children: [
              // Page Navigation Controls
              Padding(
                padding: const EdgeInsets.only(
                    top: 28.0, left: 8, right: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous Button
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 1
                          ? () => _loadPage(currentPage - 1)
                          : null,
                    ),

                    // Page Number Buttons (Only show 5 at a time)
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          totalPages > page ? page : totalPages,
                          // Show only 5 pages at a time
                          (index) {
                            int pageNumber =
                                (currentPage - 1) ~/ 5 * 5 + index + 1;
                            if (pageNumber > totalPages)
                              return const SizedBox(); // Hide extra buttons

                            return ElevatedButton(
                              onPressed: () => _loadPage(pageNumber),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (pageNumber == currentPage)
                                    ? Colors.black
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: Text(
                                Platform.isAndroid
                                    ? "$currentPage"
                                    : "$pageNumber",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Next Button
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages
                          ? () => _loadPage(currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),

              // "Go to Page" Input
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Go to Page:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CustomPrimaryButton(onPressed: _jumpToPage, text: "Go"),
                    ],
                  ),
                ),
              ),
              // Masonry Grid View
              displayedImages.isNotEmpty
                  ? Expanded(
                      child: CustomMaterialIndicator(
                        onRefresh: () async {
                          await widget.model.getInitialValues(
                              widget.model.albumCode,
                              widget.model.studioCode,
                              "",
                              "");
                        }, // Your refresh logic
                        backgroundColor: Colors.white,

                        indicatorBuilder: (context, controller) {
                          return const PhotomallProgress();
                        },
                        child: MasonryGridView.builder(
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Platform.isAndroid ? 2 : 5,
                          ),
                          itemCount: displayedImages.length,
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  Platform.isAndroid
                                      ? null
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenView(
                                                    index: index,
                                                    key: UniqueKey(),
                                                    title:
                                                        displayedImages[index]
                                                            .name!,
                                                    imagePath:
                                                        displayedImages[index]
                                                            .path!,
                                                    imagePathsForAlbum:
                                                        displayedImages,
                                                    bgColor: Colors.transparent,
                                                    largeScreenFitType:
                                                        FitType.contained,
                                                  )));
                                },
                                child: _buildImageTile(displayedImages[index]));
                          },
                        ),
                      ),
                    )
                  : const Center(child: PhotomallProgress()),
            ],
          );
  }

  Color colorByCompressionStatus(OrderImage image) {
    int compressionStatus = image.compressionStatus ?? 0;
    showLog("colorByCompressionStatus $compressionStatus");
    if (compressionStatus == 0) {
      return const Color(photomallYellow);
    } else if (compressionStatus == 2) {
      return Colors.yellow;
    } else if (compressionStatus == 0) {
      return Colors.orange;
    } else if (compressionStatus == 1) {
      return Colors.green;
    } else if (compressionStatus == 3 || compressionStatus ==4) {
      return Colors.red;
    }
    return const Color(photomallYellow);
  }

  Widget _buildImageTile(OrderImage image) {
    return Column(
      children: [
        /* ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomCachedNetworkImageWidget(
                url: "$publicPath${image.screenDisplay2ImageUrl}")),*/
        Image.file(
          File(image.path!),
          //width: 100,
          height: 100,
          //cacheWidth: 200,  // reduce memory use
          cacheHeight: 200,
          fit: BoxFit.cover,
        ),

        // Image name overlay
        // Upload status indicator
        Row(
          children: [
            Tooltip(
              decoration: toolTipDecoration,
              message: image.compressionStatus == 5
                  ? "Status: Compression Failed"
                  : image.uploaded!
                      ? 'Status: Uploaded'
                      : 'Status: Uploading...',
              child: Card(
                shape: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: colorByCompressionStatus(image), width: .5),
                    borderRadius: BorderRadius.circular(100)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    image.uploaded! ? Icons.check : Icons.timelapse_outlined,
                    color: image.compressionStatus == 5
                        ? Colors.red
                        : image.uploaded!
                            ? Colors.green
                            : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Text(
                image.name ?? "",
                style: const TextStyle(
                    color: Color(photomallYellow),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
