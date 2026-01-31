/*
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/routes/youtubeShorts/youtube_shorts_view_route.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/youtube_explode_base.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

import '../../utils/permission_util.dart';
import '../1.constants/common_constants.dart';

class YoutubeShortsRouteViewModel extends BaseObserver {
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  List<String> shortsUrls = [
    'p85x3BXdxns',
    '4has7AwErIM',
    '2MFlB3E1_GM',
    'VPQj6U4FON4',
    'Z8yKgQM3-LY',
    'uxg4lAdzvtI',
    'VQgK71wn7Ig',
    'oxQuHR-ZXnU',
    '-i3gE1fBCLY',
    'NYQPZBzd2Bg',
    'z4rBR5yPydU',
    'sb1vwDGYxXk',
    'pkktInHDed4',
    'nm230JpxNPM',
    'ya3U4ux_fxM',
    'g_eAJUjJtkg',
  ];
  late YoutubePlayerController controller;

  bool isLoading = false;

  getInitialData() async {
    isLoading = true;
   // await getShortsVideo();

    isLoading = false;
    notifyListeners();

    */
/*controller = ShortsController(
      youtubeVideoSourceController: VideosSourceController.fromUrlList(
        videoIds: ['jy4B87uVug4'],
      ),
    );*//*

  }

  Future<List<String>>getVideoTitle(String ? videoId) async {
    var yt = YoutubeExplode();
    List<String> details = [];
    try {
      // YouTube video URL

      var videoUrl = 'https://www.youtube.com/watch?v=$videoId';

      // Get video metadata
      var video = await yt.videos.get(videoUrl);
      details.add(video.title);
      details.add(video.description);
      // Print video title
      showLog('Title: ${video.title}');
      return details;
    } catch (e) {
      showLog('Error: $e');
      return details;

    } finally {
      // Close the YoutubeExplode instance to free up resources
      yt.close();
    }
  }

  getShortsVideo() async {
    const apiKey =
        'AIzaSyAO9GrCVjqBwDuumK__4WkgUegMdj2_EKA'; // Replace with your YouTube Data API key
    const handle = '@photomall'; // Replace with the YouTube handle
    final service = YouTubeService(apiKey);

    // Get channelId from handle
    final channelId = await service.getChannelIdFromHandle(handle);
    showLog('channelId is $channelId');
    try {
      shortsUrls =
          await service.fetchShorts(channelId ?? 'RuuXzTIr0OoDqI4S0RU6n4FqKEM');

      showLog('Found Shorts URLs:');
      for (var url in shortsUrls) {
        showLog(url);
      }
    } catch (e) {
      showLog('Error: $e');
    }
  }
}
*/
