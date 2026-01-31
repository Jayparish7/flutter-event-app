import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';

import '../api/apiResponseModels/google_api_response_model.dart';
import '../routes/1.constants/common_constants.dart';
import '../utils/google_drive_utils.dart';

class DriveFolderPicker extends StatefulWidget {
  final void Function(String folderId, String folderName,) onFolderSelected;

  const DriveFolderPicker({required this.onFolderSelected, super.key});

  @override
  State<DriveFolderPicker> createState() => _DriveFolderPickerState();
}

class _DriveFolderPickerState extends State<DriveFolderPicker> {
  //GoogleDriveApiResponseModel? folders;

  FileElement? selectedFolder;
  GoogleDriveUtils googleDriveUtils = GoogleDriveUtils();

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<GoogleDriveApiResponseModel?> _loadFolders() async {
    final fetchedFolders = await googleDriveUtils.loginToDrive();

      //folders = fetchedFolders;
      return fetchedFolders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: photomallBodyColor,
      appBar: const CommonAppBar(title: "Google Drive Folders"),
      body: FutureBuilder<GoogleDriveApiResponseModel?>(
        future: _loadFolders(),
        builder: (context,snapShot) {
          if(snapShot.connectionState ==ConnectionState.waiting){
            return const PhotomallProgress();
          }if(snapShot.hasData&& snapShot.data?.files!=null) {
            final folders =snapShot.data;
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders?.files!.length,
                  itemBuilder: (context, index) {
                    var folder = folders?.files![index];
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.folder),
                          title: CommonText(
                            text: folder!.name!,
                            isBody: true,
                          ),
                          onTap: () {
                            widget.onFolderSelected(folder.id!, folder.name!);
                          },
                        ),
                        const Divider()
                      ],
                    );
                  });
            }else{
            return const Text("No drive folders Found");
          }
          }
      ),
    );
  }
}
