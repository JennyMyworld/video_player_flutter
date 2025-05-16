import 'package:flutter/material.dart';
import 'video_player_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoPlayerDemo(),
    );
  }
}

class VideoPlayerDemo extends StatelessWidget {
  const VideoPlayerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // mock data
    final List<ChartDataPoint> chartData = [
      ChartDataPoint(2, const Duration(milliseconds: 0)),
      ChartDataPoint(2, const Duration(milliseconds: 500)),
      ChartDataPoint(3, const Duration(milliseconds: 1000)),
      ChartDataPoint(3, const Duration(milliseconds: 1500)),
      ChartDataPoint(5, const Duration(milliseconds: 2000)),
      ChartDataPoint(5, const Duration(milliseconds: 2500)),
      ChartDataPoint(4, const Duration(milliseconds: 3000)),
      ChartDataPoint(4, const Duration(milliseconds: 3500)),
      ChartDataPoint(6, const Duration(milliseconds: 4000)),
      ChartDataPoint(6, const Duration(milliseconds: 4500)),
      ChartDataPoint(3, const Duration(milliseconds: 5000)),
      ChartDataPoint(3, const Duration(milliseconds: 5500)),
      ChartDataPoint(2, const Duration(milliseconds: 6000)),
      ChartDataPoint(2, const Duration(milliseconds: 6500)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomVideoPlayer(
          // demo video URL
          videoPath: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          chartData: chartData,
        ),
      ),
    );
  }
} 