import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import '../providers/channels.dart';

class StreamControls extends StatefulWidget {
  final Channel channel;
  const StreamControls({Key? key, required this.channel}) : super(key: key);

  @override
  State<StreamControls> createState() => _StreamControlsState();
}

class _StreamControlsState extends State<StreamControls>
    with WidgetsBindingObserver {
  final player = AudioPlayer();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    init();
    super.initState();
  }

  Future<void> init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await player.setAudioSource(
          AudioSource.uri(Uri.parse(widget.channel.streams[0])));
    } catch (e) {
      print("Error loading audio source: $e");
      print(widget.channel.streams[0]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 64.0,
            height: 64.0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 64.0,
            onPressed: () {
              // streamInit();
              player.play();
            },
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 64.0,
            onPressed: player.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            iconSize: 64.0,
            onPressed: () => player.seek(Duration.zero),
          );
        }
      },
    );
  }
}
