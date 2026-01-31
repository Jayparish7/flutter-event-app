import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../api/apiResponseModels/google_api_response_model.dart';
import '../api/apiResponseModels/google_drive_files_api_response_model.dart';
import '../routes/1.constants/common_constants.dart';
import '../routes/login/login_form.dart';

class GoogleDriveUtils {
  Future<GoogleDriveApiResponseModel?> loginToDrive() async {
    //await googleSignIn.signOut();

    final account = await googleSignIn.signIn();

    final accessToken = account?.accessToken;

    showLog("accessToken loginToDrive $accessToken");
    if (accessToken != null && accessToken != '') {
      driveAccessToken = accessToken;
      return await fetchAllGoogleDriveFolders(accessToken);
    } else {
      showLog("accessToken loginToDrive is empty");
    }
    return null;
  }

  Future<GoogleDriveApiResponseModel> fetchAllGoogleDriveFolders(
      String accessToken) async {
    final url = Uri.parse(
        "https://www.googleapis.com/drive/v3/files?q=mimeType='application/vnd.google-apps.folder'&fields=files(id,name)");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      showLog("fetchAllFolders drive $data");
      // final folders = data['files'] as List<dynamic>;

      return compute(googleDriveApiResponseModelFromJson, response.body);
    } else {
      if (response.statusCode == 401) {
        await googleSignIn.signOut();
        loginToDrive();
      }

      throw Exception('Failed to fetch folders: ${response.body}');
    }
  }


  Future<GoogleDriveFilesApiResponseModel> getFilesInFolder({
    required String folderId,
    required http.Client client,
  }) async {
    final uri = Uri.parse("https://www.googleapis.com/drive/v3/files"
        "?q='$folderId'+in+parents"
        "&fields=files(id,name,mimeType,size)");

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      showLog("response.body ${response.body}");
      return compute(googleDriveFilesApiResponseModelFromJson, response.body);
    } else {
      throw Exception("Failed to load files: ${response.body}");
    }
  }

  drive.DriveApi getDriveApiWithAccessToken(String accessToken) {
    final client = GoogleHttpClient(accessToken);
    return drive.DriveApi(client);
  }

  /// Function to get file content as bytes from Google Drive by fileId
  Future<Uint8List> getDriveFileContent({
    required String fileId,
    required String accessToken,
  }) async {
    final driveApi = getDriveApiWithAccessToken(accessToken);

    // Get media stream of the file content
    final media = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    List<int> dataBytes = [];

    // Listen to the stream and collect bytes
    await media.stream.forEach((chunk) {
      dataBytes.addAll(chunk);
    });

    return Uint8List.fromList(dataBytes);
  }
}

class GoogleHttpClient extends http.BaseClient {
  final String accessToken;
  final http.Client _client = http.Client();

  GoogleHttpClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _client.send(request);
  }
}
