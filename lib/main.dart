import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                          fontFamily: 'Lato'),
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
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final mediaQuery = MediaQuery.of(context).size;
    final bool isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;
    if (isPhone) {
      //only allow portrait mode, not landscape on phones
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }
    //The top of the app is mostly dark so make the status bar icon color always white
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, //Android
        statusBarBrightness: Brightness.dark //iOS
        ));
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
