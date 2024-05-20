import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_video_player/app_enums.dart';

import 'player_widget/player_over_layout.dart';

class VideoContainer extends StatefulWidget {
  const VideoContainer(
      {super.key,
      required this.controller,
      required this.onFullScreen,
      required this.disableFullScreen});
  final VideoPlayerController controller;
  final VoidCallback onFullScreen;
  final VoidCallback disableFullScreen;

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  bool isSwitchScreen = false;
  VideoPlayerController get videoController {
    return widget.controller;
  }

  TappingSide tapSide = TappingSide.none;

  static const List<double> _examplePlaybackRates = <double>[
    0.5,
    1.0,
    1.5,
  ];

  Duration get totalDuration {
    return widget.controller.value.duration;
  }

  String get formattedTotalDuration {
    return "${totalDuration.inMinutes.toString().padLeft(2, '0')}:${totalDuration.inSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> screenDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      isSwitchScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var duration = Duration(
        milliseconds: videoController.value.position.inMilliseconds.round());
    String formattedDuration =
        "${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.toString().padLeft(2, '0')}";

    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        return Center(
          child: videoController.value.isInitialized
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      isSwitchScreen = true;
                    });
                    screenDelay();
                  },
                  onDoubleTapDown: (details) async {
                    var currentPosition = await videoController.position;
                    if (details.localPosition.direction > 1.0) {
                      if (currentPosition != null) {
                        isSwitchScreen = true;
                        tapSide = TappingSide.left;
                        await videoController.seekTo(
                            Duration(seconds: currentPosition.inSeconds - 10));

                        await Future.delayed(const Duration(seconds: 1));
                        tapSide = TappingSide.none;
                        screenDelay();
                      }
                    }
                    if (details.localPosition.direction < 1.0) {
                      if (currentPosition != null) {
                        isSwitchScreen = true;
                        tapSide = TappingSide.right;
                        await videoController.seekTo(
                            Duration(seconds: currentPosition.inSeconds + 10));
                        await Future.delayed(const Duration(seconds: 1));
                        tapSide = TappingSide.none;
                        screenDelay();
                      }
                    }
                  },
                  child: Stack(
                    fit: isPortrait ? StackFit.loose : StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: videoController.value.aspectRatio,
                        child: Stack(
                          children: [
                            VideoPlayer(widget.controller),
                            ClosedCaption(
                              text: videoController.value.caption.text,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            VideoOverLayout(
                                isSwitchScreen: isSwitchScreen,
                                videoController: videoController,
                                widget: widget,
                                isPortrait: isPortrait,
                                formattedDuration: formattedDuration,
                                formattedTotalDuration: formattedTotalDuration,
                                examplePlaybackRates: _examplePlaybackRates,
                                tapSide: tapSide),
                          ],
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {

                      //   },
                      // ),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
