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
    final List<double> chartData = [
      2, 2, 2, 2, 2,
      5, 5, 5,    
      3, 3,    
      6, 6, 6, 6, 
      4, 4, 4,   
      2, 2, 2
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