import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:univent/components/buttons/rounded_button.dart';
import 'package:univent/screens/add_ical_link_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class HowToScreen extends StatefulWidget {
  static const String id = 'howto_screen';

  const HowToScreen({super.key});

  @override
  State<HowToScreen> createState() => _HowToScreenState();
}

class _HowToScreenState extends State<HowToScreen> {
  late String email;
  late String password;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://github.com/Univent-io/video-storage/blob/761271940800e0f0ff925da680d845a1a853e8e1/how_to_add_icalendar_link.MP4?raw=true',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('univent',
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Do not skip this page!',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              height: MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).padding.top + kToolbarHeight),
              child: Chewie(
                  controller: ChewieController(
                videoPlayerController: _controller,
                aspectRatio: 9 / 16,
                autoInitialize: true,
                autoPlay: false,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              )),
            ),
            RoundedButton(
              title: const Text('Get Started'),
              action: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                }
                Navigator.pushNamedAndRemoveUntil(
                    context, AddIcalLinkScreen.id, (r) => false);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 128.0),
              child: Text(
                'If you have any issues with the app, please email us at hq@univent.io or call 801-343-3304',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
