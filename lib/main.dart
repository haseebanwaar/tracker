// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatefulWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> _startStreaming() async {
    await _initializeControllerFuture;

    setState(() {
      _isStreaming = true;
    });

    final stream = _controller!.startImageStream((CameraImage image) {
      // Process the video frame here if needed before sending it to the backend.
      // Example: Convert the CameraImage to a base64-encoded byte array.
      List<int> imageBytes = getImageBytes(image);

      // Send the video frame to the backend.
      sendVideoStream(imageBytes);
    });

    // You can choose to stop the streaming after a certain duration or condition.
    // _controller!.stopImageStream(stream);
  }

  void _stopStreaming() {
    _controller!.stopImageStream();
    setState(() {
      _isStreaming = false;
    });
  }

  void sendVideoStream(List<int> imageBytes) async {
    // final url = Uri.parse('https://ee96-39-32-174-161.ngrok-free.app/video');
    final url = Uri.parse('https://192.168.100.29/video');

    try {
      final response = await http.post(url,
          body: imageBytes, headers: {'ngrok-skip-browser-warning': 'asd'});

      // Handle the response from the backend if needed.
      print('Response from backend: ${response.body}');
    } catch (error) {
      print('Error sending video stream: $error');
    }
  }

  List<int> getImageBytes(CameraImage image) {
    // Convert the CameraImage to a byte array in a suitable format for sending.
    // Implement the conversion logic based on your requirements.
    // Here's an example using the U8 format:
    return image.planes.map((plane) {
      return plane.bytes;
    }).toList()[0];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Streaming App'),
        ),
        body: Column(
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            FilledButton(
                onPressed: () async {
                  final url = Uri.parse('http://192.168.100.29:3063/text');

                  final text = "sample text";

                  try {
                    final response = await http.post(url, body: {'text': text});

                    // Handle the response from the backend if needed.
                    print('Response from backend: ${response.body}');
                  } catch (error) {
                    print('Error sending text: $error');
                  }
                },
                child: Text('Press')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
          onPressed: _isStreaming ? _stopStreaming : _startStreaming,
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
//
// void main() async {
//   // Ensure that Flutter has access to the device's cameras.
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   final firstCamera = cameras.first;
//
//   runApp(MyApp(camera: firstCamera));
// }
//
// class MyApp extends StatefulWidget {
//   final CameraDescription camera;
//
//   const MyApp({Key? key, required this.camera}) : super(key: key);
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(widget.camera, ResolutionPreset.medium);
//     _initializeControllerFuture = _controller!.initialize();
//   }
//
//   @override
//   void dispose() {
//     _controller!.dispose();
//     super.dispose();
//   }
//
//   void _startStreaming() async {
//     await _initializeControllerFuture;
//
//     final stream = _controller!.startImageStream((CameraImage image) {
//       // Process the video frame here if needed before sending it to the backend.
//
//       // Convert the CameraImage to a base64-encoded byte array.
//       List<int> imageBytes = getImageBytes(image);
//
//       // Send the video frame to the backend.
//       sendVideoStream(imageBytes);
//     });
//
//     // You can choose to stop the streaming after a certain duration or condition.
//     // _controller!.stopImageStream(stream);
//   }
//
//   void sendVideoStream(List<int> imageBytes) async {
//     // Specify the backend API endpoint to receive the video stream.
//     final url = Uri.parse('http://127.0.0.1:5000/video');
//
//     try {
//       // Send the video frame data to the backend using a POST request.
//       final response = await http.post(url, body: imageBytes);
//
//       // Handle the response from the backend if needed.
//       print('Response from backend: ${response.body}');
//     } catch (error) {
//       // Handle any errors that occur during the HTTP request.
//       print('Error sending video stream: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Video Streaming App'),
//         ),
//         body: FutureBuilder<void>(
//           future: _initializeControllerFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return CameraPreview(_controller!);
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.camera),
//           onPressed: _startStreaming,
//         ),
//       ),
//     );
//   }
//
//   List<int> getImageBytes(CameraImage image) {
//     // Convert the CameraImage to a byte array in a suitable format for sending.
//     // Implement the conversion logic based on your requirements.
//     // Here's an example using the U8 format:
//     return image.planes.map((plane) {
//       return plane.bytes;
//     }).toList()[0];
//   }
// }
