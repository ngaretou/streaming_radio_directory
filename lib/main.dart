import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '/screens/player_screen.dart';
import 'providers/channels.dart';
import 'providers/theme.dart';

void main() async {
  //https://pub.dev/packages/just_audio_background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Channels(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> init;

  @override
  void initState() {
    init = Provider.of<ThemeModel>(context, listen: false).setupTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData? currentTheme =
        Provider.of<ThemeModel>(context, listen: true).currentTheme;

    return FutureBuilder(
      future: init,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Radio',
                  theme: currentTheme ??
                      ThemeData(
                          brightness: Brightness.light,
                          colorSchemeSeed: Colors.teal,
                          fontFamily: 'Andika'),
                  home: const MyHomePage(title: 'Streaming Radio'),
                ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<void> init;

  @override
  void initState() {
    init = Provider.of<Channels>(context, listen: false).getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButton: Builder(
        //   builder: (context) {
        //     return FloatingActionButton(
        //       onPressed: () => showMenu(context),
        //       mini: true,
        //       shape: const RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(
        //           Radius.circular(10),
        //         ),
        //       ),
        //       child: const Icon(Icons.menu),
        //     );
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        body: FutureBuilder(
            future: init,
            builder: (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : const PlayerScreen()));
  }
}
