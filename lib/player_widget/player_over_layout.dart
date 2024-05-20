import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../app_enums.dart';
import '../video_player_container.dart';

class VideoOverLayout extends StatelessWidget {
  const VideoOverLayout({
    super.key,
    required this.isSwitchScreen,
    required this.videoController,
    required this.widget,
    required this.isPortrait,
    required this.formattedDuration,
    required this.formattedTotalDuration,
    required List<double> examplePlaybackRates,
    required this.tapSide,
  }) : _examplePlaybackRates = examplePlaybackRates;

  final bool isSwitchScreen;
  final VideoPlayerController videoController;
  final VideoContainer widget;
  final bool isPortrait;
  final String formattedDuration;
  final String formattedTotalDuration;
  final List<double> _examplePlaybackRates;
  final TappingSide tapSide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
                        padding: isPortrait
                            ? const EdgeInsets.only(bottom: 8.0)
                            : const EdgeInsets.only(bottom: 16),
                        child: VideoProgressIndicator(widget.controller,
                            allowScrubbing: true),
                      ),
                    ),
                    Padding(
                      padding: isPortrait
                          ? const EdgeInsets.only(bottom: 12.0)
                          : const EdgeInsets.only(bottom: 20, right: 16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: isPortrait
                              ? () {
                                  widget.onFullScreen();
                                }
                              : () {
                                  widget.disableFullScreen();
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
                      padding: isPortrait
                          ? const EdgeInsets.only(bottom: 16.0, left: 10)
                          : const EdgeInsets.only(bottom: 20, left: 20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "$formattedDuration / $formattedTotalDuration",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (videoController.value.volume == 1.0) {
                                videoController.setVolume(0.0);
                              } else {
                                videoController.setVolume(1.0);
                              }
                            },
                            icon: Icon(
                              videoController.value.volume == 1.0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                            )),
                        PopupMenuButton<double>(
                          initialValue: videoController.value.playbackSpeed,
                          tooltip: 'Playback speed',
                          onSelected: (value) {
                            videoController.setPlaybackSpeed(value);
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuItem<double>>[
                              for (final double speed in _examplePlaybackRates)
                                PopupMenuItem<double>(
                                  value: speed,
                                  child: Text('${speed}x'),
                                )
                            ];
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Text(
                              '${videoController.value.playbackSpeed}x',
                              style: const TextStyle(color: Colors.white),
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (tapSide == TappingSide.right)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '+ 10 seconds',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                  ],
                ),
              )
            : const SizedBox.shrink());
  }
}
