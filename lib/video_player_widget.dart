import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoPath;
  final List<double>? chartData;

  const CustomVideoPlayer({
    Key? key,
    required this.videoPath,
    this.chartData,
  }) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _totalDuration = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoPath);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        showControls: false,
      );

      _videoPlayerController!.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _videoPlayerController!.value.position.inMilliseconds.toDouble();
            _totalDuration = _videoPlayerController!.value.duration.inMilliseconds.toDouble();
            _isPlaying = _videoPlayerController!.value.isPlaying;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _saveFrame() async {
    if (!_isInitialized || _videoPlayerController == null) return;
    
    try {
      // 暂停视频以确保获取准确的当前帧
      final wasPlaying = _videoPlayerController!.value.isPlaying;
      if (wasPlaying) {
        await _videoPlayerController!.pause();
      }

      // 获取视频元素
      final videoElement = html.document.querySelector('video') as html.VideoElement?;
      if (videoElement != null) {
        // 创建 canvas 元素
        final canvas = html.CanvasElement(
          width: videoElement.videoWidth,
          height: videoElement.videoHeight,
        );
        
        // 在 canvas 上绘制视频帧
        final ctx = canvas.context2D;
        ctx.drawImage(videoElement, 0, 0);
        
        // 将 canvas 转换为 Blob
        final blob = await canvas.toBlob('image/png');
        if (blob != null) {
          // 创建下载链接
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'frame_${DateTime.now().millisecondsSinceEpoch}.png')
            ..click();
          
          // 清理 URL
          html.Url.revokeObjectUrl(url);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('截图已保存')),
            );
          }
        }
      }

      // 如果之前是播放状态，恢复播放
      if (wasPlaying) {
        await _videoPlayerController!.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('截图失败: $e')),
        );
      }
    }
  }

  void _seekToPosition(double position) {
    if (_videoPlayerController != null) {
      final Duration duration = Duration(milliseconds: position.toInt());
      _videoPlayerController!.seekTo(duration);
      
      // 如果视频是暂停状态，seek 后自动播放一小段然后暂停，以更新画面
      if (!_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.play();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_videoPlayerController != null) {
            _videoPlayerController!.pause();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _videoPlayerController == null || _chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final duration = _videoPlayerController!.value.duration.inMilliseconds.toDouble();
    final position = _videoPlayerController!.value.position.inMilliseconds.toDouble();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
          const SizedBox(height: 20),
          // 播放控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    if (_videoPlayerController!.value.isPlaying) {
                      _videoPlayerController!.pause();
                    } else {
                      _videoPlayerController!.play();
                    }
                  });
                },
                iconSize: 32,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final newPosition = position - 10000; // 后退10秒
                  _seekToPosition(newPosition.clamp(0, duration));
                },
                iconSize: 32,
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final newPosition = position + 10000; // 前进10秒
                  _seekToPosition(newPosition.clamp(0, duration));
                },
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度条控制
          Column(
            children: [
              Slider(
                value: position.clamp(0.0, duration),
                min: 0.0,
                max: duration,
                onChanged: (value) {
                  setState(() {
                    _currentPosition = value;
                  });
                  _seekToPosition(value);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_videoPlayerController!.value.position),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      _formatDuration(_videoPlayerController!.value.duration),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.chartData != null) ...[
            const SizedBox(height: 20),
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.chartData!.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(details.globalPosition);
                      final relativeX = localPosition.dx / box.size.width;
                      final timePosition = (relativeX * duration).clamp(0.0, duration);
                      _seekToPosition(timePosition);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _saveFrame,
            child: const Text('Save Current Image'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
} 