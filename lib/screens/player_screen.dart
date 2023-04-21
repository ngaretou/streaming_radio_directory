import 'package:flutter/material.dart';
import 'package:streaming_radio_directory/screens/channels_screen.dart';
import 'package:provider/provider.dart';
import '../providers/channels.dart';
import '../widgets/circle_button.dart';
import '../widgets/fullscreen_dialog.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  //Show the channel picker & settings screen
  dynamic showMenu(BuildContext context) async {
    // show the modal dialog and pass some data to it
    final result = await Navigator.of(context)
        .push(FullScreenModal(child: const ChannelsScreen()));

    // print the data returned by the modal if any
    debugPrint(result.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Channels>(context, listen: false).getData(),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleButton(
                            onPressed: () => showMenu(context),
                            icon: const Icon(Icons.settings_input_antenna),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            border: Border.all(
                              color: Colors.red,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        width: 300,
                        height: 300,
                      ),
                      Container(
                          color: Colors.redAccent,
                          width: 300,
                          height: 50,
                          child: const Center(child: Text('Visualizer'))),
                      const Icon(
                        Icons.play_arrow,
                        size: 150,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleButton(
                            onPressed: () {},
                            icon: const Icon(Icons.public),
                          ),
                          CircleButton(
                            onPressed: () {},
                            icon: const Icon(Icons.face),
                          ),
                          CircleButton(
                            onPressed: () {},
                            icon: const Icon(Icons.photo),
                          ),
                          CircleButton(
                            onPressed: () {},
                            icon: const Icon(Icons.watch),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
    );
  }
}
