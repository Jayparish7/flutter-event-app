import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/studioDetail/studio_profile_model.dart';
import 'package:selectable/selectable.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common_widgets/base_widget.dart';
import '../../common_widgets/common_appbar.dart';
import '../../generated/l10n.dart';

class StudioProfile extends StatefulWidget {
  final List<String> url;

  const StudioProfile({super.key, required this.url});

  @override
  State<StudioProfile> createState() => _StudioProfileState();
}

class _StudioProfileState extends State<StudioProfile> {
  BaseWidget<StudioProfileModel>? baseWidget;
  Map<String, PreviewData> datas = {};

  List<String> get urls => widget.url;

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget<StudioProfileModel>(
      model: StudioProfileModel(),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: photomallBodyColor,
          appBar:  CommonAppBar(
            title: S.of(context).profile,appBarWithLogo: true,
          ),
          body: Skeletonizer(
            enabled: model.isLoading,
            child: SingleChildScrollView(
                    child: Selectable(
                      selectWordOnDoubleTap: true,
                      selectWordOnLongPress: true,
                      selectionColor: Colors.grey.withOpacity(.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: urls.length,
                              itemBuilder: (context, index) {
                                return LinkPreview(
                                  padding: const EdgeInsets.all(25),
                                  enableAnimation: true,
                                  animationDuration: const Duration(seconds: 1),
                                  onPreviewDataFetched: (data) {
                                    setState(() {
                                      datas = {
                                        ...datas,
                                        urls[index]: data,
                                      };
                                    });
                                  },
                                  previewData: datas[urls[index]],
                                  text: urls[index],
                                  width: MediaQuery.of(context).size.width,
                                  imageBuilder: (previewData) {
                                    showLog('previewData $previewData');
                                    // Custom image builder
                                    return Image.network(
                                      previewData,
                                      height: 100.0,
                                    );
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  ),
          )

        );
      },
    );
    return baseWidget!;
  }
}
