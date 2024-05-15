import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_video_player/app_enums.dart';

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
                  child: AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: Stack(
                      fit: isPortrait ? StackFit.expand : StackFit.loose,
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(widget.controller),
                        ClosedCaption(
                          text: videoController.value.caption.text,
                          textStyle: const TextStyle(color: Colors.white),
                        ),

                        AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 200),
                            child: isSwitchScreen
                                ? ColoredBox(
                                    color: Colors.black26,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap: () {
                                              videoController.value.isPlaying
                                                  ? videoController.pause()
                                                  : videoController.play();
                                            },
                                            child: Icon(
                                              videoController.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 100.0,
                                              semanticLabel: 'Play',
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: VideoProgressIndicator(
                                                widget.controller,
                                                allowScrubbing: true),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: GestureDetector(
                                              onTap: isPortrait
                                                  ? () {
                                                      widget.onFullScreen();
                                                    }
                                                  : () {
                                                      widget
                                                          .disableFullScreen();
                                                    },
                                              child: isPortrait
                                                  ? const Icon(
                                                      Icons.fullscreen,
                                                      color: Colors.white,
                                                    )
                                                  : const Icon(
                                                      Icons.fullscreen_exit,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "$formattedDuration / $formattedTotalDuration",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  if (videoController
                                                          .value.volume ==
                                                      1.0) {
                                                    videoController
                                                        .setVolume(0.0);
                                                  } else {
                                                    videoController
                                                        .setVolume(1.0);
                                                  }
                                                },
                                                icon: Icon(
                                                  videoController
                                                              .value.volume ==
                                                          1.0
                                                      ? Icons.volume_up
                                                      : Icons.volume_off,
                                                  color: Colors.white,
                                                )),
                                            PopupMenuButton<double>(
                                              initialValue: videoController
                                                  .value.playbackSpeed,
                                              tooltip: 'Playback speed',
                                              onSelected: (value) {
                                                videoController
                                                    .setPlaybackSpeed(value);
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return <PopupMenuItem<double>>[
                                                  for (final double speed
                                                      in _examplePlaybackRates)
                                                    PopupMenuItem<double>(
                                                      value: speed,
                                                      child: Text('${speed}x'),
                                                    )
                                                ];
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                                child: Text(
                                                  '${videoController.value.playbackSpeed}x',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (tapSide == TappingSide.left)
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '- 10 seconds',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        if (tapSide == TappingSide.right)
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '+ 10 seconds',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink()),
                        // GestureDetector(
                        //   onTap: () {

                        //   },
                        // ),
                      ],
                    ),
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
