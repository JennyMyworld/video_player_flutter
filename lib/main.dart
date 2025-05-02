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
    // 示例数据 - 这里使用一些随机数据作为图表数据
    final List<double> chartData = List.generate(100, (index) => (index % 20) * 5.0);

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