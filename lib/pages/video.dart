import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motosekur_academia/func/export.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class Video extends StatefulWidget {
  final String videoUrl;
  final bool
  isNetwork; // true si c'est une URL, false si c'est un asset/local file

  const Video({super.key, required this.videoUrl, required this.isNetwork});

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isNetwork) {
      _downloadAndPlay();
    } else {
      _playLocalAsset(widget.videoUrl);
    }
  }

  // Télécharger depuis le réseau et lire
  Future<void> _downloadAndPlay() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cached_video.mp4');

      if (!file.existsSync()) {
        await Dio().download(widget.videoUrl, file.path);
      }

      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      _startListener();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Lire un fichier local ou asset
  Future<void> _playLocalAsset(String path) async {
    try {
      _controller = VideoPlayerController.asset("assets/images/MOTOSEKUR.mp4");
      await _controller!.initialize();
      _startListener();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startListener() {
    _controller!.addListener(() {
      setState(() {});
    });
    setState(() {
      _isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => back(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        actions: [
          if (_controller != null && _controller!.value.isPlaying)
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Center(
                child: Text(
                  "${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text("Erreur : $_error")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      // Barre de progression
                      if (_controller!.value.isInitialized)
                        Positioned(
                          bottom: 0,
                          child: SizedBox(
                            width: width(context, 1),
                            child: Slider(
                              min: 0,
                              max: _controller!.value.duration.inSeconds
                                  .toDouble(),
                              value: _controller!.value.position.inSeconds
                                  .toDouble()
                                  .clamp(
                                    0.0,
                                    _controller!.value.duration.inSeconds
                                        .toDouble(),
                                  ),
                              onChanged: (value) {
                                _controller!.seekTo(
                                  Duration(seconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                        ),
                      // Play/Pause overlay
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
