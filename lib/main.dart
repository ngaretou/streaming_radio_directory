import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/player_screen.dart';
import 'providers/channels.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Channels(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Streaming Radio'),
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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
      body: PlayerScreen(),
    );
  }
}
