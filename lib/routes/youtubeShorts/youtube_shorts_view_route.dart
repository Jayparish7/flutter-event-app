/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photomall_studio_manager/routes/youtubeShorts/youtube_shorts_route_view_model.dart';
import 'package:pod_player/pod_player.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/youtube_explode_base.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

import '../../common_widgets/base_widget.dart';
import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_text.dart';
import '../../generated/l10n.dart';
import '../1.constants/common_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeShortsViewRoute extends StatefulWidget {
  const YoutubeShortsViewRoute({super.key});

  @override
  State<YoutubeShortsViewRoute> createState() => _YoutubeShortsViewRouteState();
}

class _YoutubeShortsViewRouteState extends State<YoutubeShortsViewRoute> {
  BaseWidget<YoutubeShortsRouteViewModel>? baseWidget;
  late final PodPlayerController controller;

  @override
  void initState() {
    // TODO: implement initState
    */
/* SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*//*

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    */
/*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*//*

  }
  double borderRadius = (Platform.isAndroid)?0:20;

  @override
  Widget build(BuildContext context) {
    baseWidget = BaseWidget(
      model: YoutubeShortsRouteViewModel(),
      onModelReady: (model) async {
        await model.getInitialData();
      },
      builder: (context, model, child) {
        return  PageViewForShorts(
          shortsURls: model.shortsUrls,
          model: model,
        );*/
/* Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFF003B73), Color(0xFFd2e6f7)]),

              //fit: BoxFit.contain,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: const CommonAppBar(
                title: 'Shorts',
                isCenterTitle: true,
                automaticallyImplyLeading: false,
              ),
              body: model.shortsUrls.isEmpty
                  ? Container(
                      decoration:  BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(borderRadius)),
                        color: photomallBodyColor,
                      ),
                      child: const Center(
                        child: LinearProgressIndicator(),
                      ),
                    )
                  : Container(
                      decoration:  BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(borderRadius)),
                        color: photomallBodyColor,
                      ),
                      child: Center(
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageViewForShorts(
                                            shortsURls: model.shortsUrls,
                                            model: model,
                                          )));
                            },
                            child: Card(
                              color: Colors.grey,
                              child: Container(
                                height: 50,
                                width: 100,
                                child: Icon(Icons.play_arrow),
                              ),
                            )),
                      ),
                    ),
            ));*//*

      },
    );
    return baseWidget!;
  }
}

class PageViewForShorts extends StatefulWidget {
  final List<String> shortsURls;
  final YoutubeShortsRouteViewModel model;

  const PageViewForShorts(
      {super.key, required this.shortsURls, required this.model});

  @override
  State<PageViewForShorts> createState() => _PageViewForShortsState();
}

class _PageViewForShortsState extends State<PageViewForShorts> {
  PageController pageViewController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  */
/*  SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*//*

    pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      */
/*appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),*//*

      body: PageView.builder(
        controller: pageViewController,
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        itemCount: widget.shortsURls.length,
        itemBuilder: (BuildContext context, int index) {
          showLog('widget.shortsURls ${widget.shortsURls[index]}');

          return Stack(
            children: [
              AspectRatio(
                aspectRatio: .5,
                child: ShortsView(
                  shortsURls: widget.shortsURls[index]
                      .replaceAll('https://youtube.com/shorts/', ''),
                ),
              ),
              Positioned(
                  bottom: 55,
                  left: 5,
                  child: FutureBuilder(
                      future:
                          widget.model.getVideoTitle(widget.shortsURls[index]),
                      builder: (context, snapshot) {
                        return Skeletonizer(
                            enabled: snapshot.connectionState ==
                                ConnectionState.waiting,
                            child: Text(
                              snapshot.data?.first ?? '',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,

                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1.0, 1.0), // Position of shadow
                                      blurRadius: 3.0,          // Blur effect
                                      color: Colors.grey.withOpacity(0.5), // Shadow color
                                    ),
                                    Shadow(
                                      offset: const Offset(-1.0, -1.0),
                                      blurRadius: 3.0,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ]),
                            ));
                      }))
            ],
          );
        },
      ),
    );
  }
}

class ShortsView extends StatefulWidget {
  final String shortsURls;

  const ShortsView({super.key, required this.shortsURls});

  @override
  State<ShortsView> createState() => _ShortsViewState();
}

class _ShortsViewState extends State<ShortsView> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    // TODO: implement initState

    controller = YoutubePlayerController(
      initialVideoId: widget.shortsURls,
      flags: const YoutubePlayerFlags(
          autoPlay: true,
          enableCaption: false,
          mute: false,
          hideControls: true,
          showLiveFullscreenButton: false,
          forceHD: true,
          loop: true),
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    */
/*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*//*

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: const ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
    );
  }
}

class YouTubeService {
  final String apiKey;

  YouTubeService(this.apiKey);

  getVideoTitle(String? videoId) async {
    var yt = YoutubeExplode();

    try {
      // YouTube video URL
      var videoUrl = 'https://www.youtube.com/watch?v=$videoId';

      // Get video metadata
      var video = await yt.videos.get(videoUrl);

      // Print video title
      print('Title: ${video.title}');
    } catch (e) {
      print('Error: $e');
    } finally {
      // Close the YoutubeExplode instance to free up resources
      yt.close();
    }
  }

  // Fetch videos and filter Shorts

// Method to resolve custom handle to channelId
  Future<String?> getChannelIdFromHandle(String handle) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$handle&part=snippet&type=channel';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final channelId = data['items']?.first['snippet']['channelId'];

      return channelId;
    } else {
      print('Error resolving channelId: ${response.body}');
      return null;
    }
  }

  Future<List<String>> fetchShorts(String channelId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&type=video&order=date&maxResults=50';
    showLog('url ==>$url');
    final response = await http.get(Uri.parse(url));
    showLog('response body :${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List videos = data['items'];

      final List<String> shortsUrls = [];

      for (var video in videos) {
        final videoId = video['id']['videoId'];
        final videoDetails = await fetchVideoDetails(videoId);

        if (videoDetails != null && videoDetails['duration'] <= 60) {
          if (shortsUrls.length == 10) {
            return shortsUrls;
          }
          //shortsUrls.add('https://youtube.com/shorts/$videoId');
          shortsUrls.add('$videoId');
        }
      }
      return shortsUrls;
    } else {
      print('Error fetching videos: ${response.body}');
      throw Exception('Failed to fetch videos');
    }
  }

  */
/* Future<List<String>> fetchRecentShorts(String channelId) async {
    // URL to fetch the most recent videos, sorted by date
    final url =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&type=video&order=date&maxResults=50';

    print('url ==>$url');

    List<String> allShortsUrls = [];
    String? nextPageToken;

    // Loop to handle pagination and fetch all results
    do {
      // If there is a nextPageToken, append it to the URL for pagination
      final requestUrl = nextPageToken == null ? url : '$url&pageToken=$nextPageToken';

      // Send the HTTP request to fetch the search results
      final response = await http.get(Uri.parse(requestUrl));

      print('response body :${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List videos = data['items'];

        // Iterate through the fetched videos and filter out the Shorts
        for (var video in videos) {
          final videoId = video['id']['videoId'];

          // Fetch video details for each video
          final videoDetails = await fetchVideoDetails(videoId);

          if (videoDetails != null && videoDetails['duration'] <= 60) {
            allShortsUrls.add('https://youtube.com/shorts/$videoId');
          }
        }

        // Check if there is a nextPageToken to fetch the next page of results
        nextPageToken = data['nextPageToken'];
      } else {
        print('Error fetching videos: ${response.body}');
        throw Exception('Failed to fetch videos');
      }
    } while (nextPageToken != null);  // Continue fetching if there's a nextPageToken

    // Return the list of URLs for all Shorts
    return allShortsUrls;
  }*//*


  // Fetch video details for duration filtering
  Future<Map<String, dynamic>?> fetchVideoDetails(String videoId) async {
    final url =
        'https://www.googleapis.com/youtube/v3/videos?key=$apiKey&id=$videoId&part=contentDetails';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final video = data['items']?.first;

      if (video != null) {
        final duration = parseDuration(video['contentDetails']['duration']);
        return {'duration': duration};
      }
    }
    return null;
  }

  // Parse ISO 8601 duration format (e.g., "PT1M30S")
  int parseDuration(String duration) {
    final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    final minutes = int.parse(match?.group(1) ?? '0');
    final seconds = int.parse(match?.group(2) ?? '0');

    return (minutes * 60) + seconds;
  }
}
*/
