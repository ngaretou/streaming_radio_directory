import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:streaming_radio_directory/screens/channels_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/info.dart';
import '../providers/channels.dart';
import '../providers/theme.dart';
import '../widgets/fullscreen_dialog.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String subTitle = '';
  bool siri9style = true;
  bool waveActive = false;
  bool firstBuild = true;
  double amplitude = 0.0;
  final player = AudioPlayer();

  late SiriWaveController waveController;

  //an initial value
  Color accentColor = const Color(0x00EF5D77);
  //function to pull the accent color and set it in the display

  late Channel currentChannel;

  @override
  void initState() {
    waveController = SiriWaveController();

    init();
    super.initState();
  }

  Future<void> init() async {
    currentChannel =
        Provider.of<Channels>(context, listen: false).currentChannel;
    Box userPrefsBox = await Hive.openBox('userPrefs');
    userPrefsBox.put('currentChannel', currentChannel.id);

    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    //original version:
    player.playbackEventStream.listen((event) {
      // print(event);
    }, onError: (Object e, StackTrace stackTrace) {
      if (e is PlatformException) {
        print('PlatformException detected in init');
        return;
      }
      if (e is PlayerException) {
        print('PlayerException caught in init');
        return;
      }

      print('A stream error occurred, caught in init: $e');
    });

    changeAudioSource(currentChannel);
  }

  void setWaveAnimation(bool? playing, {bool? force}) {
    void setIt(bool set) {
      waveActive = set;

      if (waveActive) {
        if (siri9style) {
          waveController.setAmplitude(1);
        } else {
          waveController.setAmplitude(.4);
        }
      } else {
        waveController.setAmplitude(0);
      }
    }

    if (force == true) {
      setIt(playing!);
    } else if (playing != null) {
      if (playing != waveActive) {
        setIt(playing);
      }
    }
  }

  Future<void> changeAudioSource(Channel channel) async {
    bool wasPlaying = player.playing;
    if (wasPlaying) await player.stop();

    // Try to load audio from a source and catch any errors.
    try {
      await player.setAudioSource(
          AudioSource.uri(
            Uri.parse(channel.streams[0]),
            tag: MediaItem(
              // Specify a unique ID for each media item:
              id: channel.id,
              // Metadata to display in the notification:
              album: channel.name,
              title: channel.name,
              artUri: Uri.parse(channel.image),
            ),
          ),
          preload: false);
    } on PlatformException catch (e) {
      print('PlatformException $e');
    } on PlayerException catch (e) {
      print('PlayerException $e');
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var mediaQuery = MediaQuery.of(context);
    // print(mediaQuery.size.width);

    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);

    Color smallIconColor = Theme.of(context).colorScheme.primary;
    waveController.color = smallIconColor;

    //Colors and images
    CachedNetworkImage cachedStationArt = CachedNetworkImage(
      // cacheManager: ,
      imageUrl: currentChannel.image,
      imageBuilder: (context, imageProvider) => Image(image: imageProvider),
      placeholder: (context, url) => Image.memory(kTransparentImage),
      fit: BoxFit.scaleDown,
      errorWidget: (context, url, error) => const Icon(Icons.radio),
    );

    Future<void> setColor() async {
      // Image img = Image.network(currentChannel.image);

      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
              CachedNetworkImageProvider(currentChannel.image));

      //get same color no matter what brightness or...
      // accentColor = paletteGenerator.dominantColor!.color;

      //get different seed color depending on brightness
      try {
        if (themeModel.currentTheme!.brightness == Brightness.light) {
          accentColor = paletteGenerator.dominantColor!.color;
        } else {
          try {
            accentColor = paletteGenerator.darkVibrantColor!.color;
          } catch (e) {
            accentColor = paletteGenerator.dominantColor!.color;
          }
        }
      } catch (e) {
        accentColor = Colors.teal;
      }

      // await Future.delayed(const Duration(milliseconds: 50));

      themeModel.setTheme(color: accentColor, refresh: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstBuild) {
        firstBuild = false;
        waveController.setAmplitude(0);
        waveController.setFrequency(6);
      }
      setColor();
    });

    //set up icons
    Map<String, IconData> iconMapping = {
      'email': Icons.mail,
      'web': FontAwesomeIcons.globe,
      'facebook': FontAwesomeIcons.facebook,
      'messenger': FontAwesomeIcons.facebookMessenger,
      'twitter': FontAwesomeIcons.twitter,
      'whatsapp': FontAwesomeIcons.whatsapp,
      'instagram': FontAwesomeIcons.instagram,
      'youtube': FontAwesomeIcons.youtube,
    };

    //Action buttons - youtube, mail, etc
    Widget action(ChannelAction action) {
      return IconButton(
        icon: Icon(
          iconMapping[action.icon],
          size: 30,
          color: smallIconColor,
        ),
        onPressed: () async {
          late String composedUrl;
          bool isEmail = action.address!.contains('@');
          if (isEmail) {
            composedUrl = 'mailto:${action.address}';
          } else {
            composedUrl = action.address!;
          }

          if (await canLaunchUrl(Uri.parse(composedUrl))) {
            await launchUrl(Uri.parse(composedUrl),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $composedUrl';
          }
        },
      );
    }

    //Show the channel picker & settings screen
    void showMenu(BuildContext context) async {
      // show the modal dialog and pass some data to it
      var result = await Navigator.of(context)
          .push(FullScreenModal(child: const ChannelsScreen()));

      //you can just click the X after looking at the channels, in which case no change.
      if (result != null) {
        currentChannel = result;
        changeAudioSource(currentChannel);
        setState(() {});
      }
    }

    Future<void> playStreamError() async {
      await player.stop();
      if (!mounted) return;
      Translation translation = await getTranslation(context);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(translation.stationOffline)
            ],
          ),
        ));
      }
    }

    List<Widget> actions = List.generate(currentChannel.actions.length,
        (index) => action(currentChannel.actions[index]));

    //The button that opens gridview
    Widget menubutton = IconButton(
      icon: Icon(
        Icons.menu,
        size: 30,
        color: smallIconColor,
      ),
      onPressed: () {
        HapticFeedback.mediumImpact;
        showMenu(context);
      },
    );

    actions.insert(0, menubutton);

    Widget playbutton =
        ControlButtons(player, playStreamError, setWaveAnimation);

    late int playButtonIndex;
    //including and centering the play button

    //if the number of actions is even, no problem - play button goes in the middle below.
    //If it's odd, let's make it even by including a sized box.

    if (actions.length.isOdd) {
      late int middleIndex;
      if (actions.length == 1) {
        middleIndex = 1;
      } else {
        middleIndex = (actions.length / 2).floor().toInt();
      }

      //the SizedBox that centers the playbutton if we have odd number of actions
      actions.insert(
          middleIndex,
          //The actions Widgets are 48 wide
          const SizedBox(
            width: 48,
          ));
    }
    //https://dart.dev/tools/diagnostic-messages?utm_source=dartdev&utm_medium=redir&utm_id=diagcode&utm_content=division_optimization#division_optimization:~:text=/%20y).-,toInt,-()%3B
    // '~/' here is divide and make it an int
    // we know it's even cause we just made it even
    //actions here if it's 0 actions in the json is menubutton and sized box

    playButtonIndex = (actions.length ~/ 2);

    //insert play button
    actions.insert((playButtonIndex), playbutton);

    if (currentChannel.country != '' && currentChannel.language != '') {
      subTitle =
          '${currentChannel.country}  |  ${languageAbbreviations[currentChannel.language]}';
    } else if (currentChannel.country != '' && currentChannel.language == '') {
      subTitle = currentChannel.country;
    } else if (currentChannel.country == '' && currentChannel.language != '') {
      subTitle = languageAbbreviations[currentChannel.language]!;
    } else {
      subTitle = '';
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              accentColor,

              // accentColor,

              // Theme.of(context).colorScheme.,
              // Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
              // Theme.of(context).colorScheme.primary,
              // accentColor
            ],
          )),
          child: SafeArea(
            child: Padding(
              /*This is the initial somewhat limited responsive design. 
              Maybe in future versions some more creativity here. Yoonu Njub-type sidebar? */
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                              // maxWidth: 300,
                            ),
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(1.0, 6.0),
                                    blurRadius: 20.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            // width: 300,
                            // height: 300,
                            child: cachedStationArt),
                      ),
                    ),

                    //Wrap to make the station and dexcriptoin stick together despite the Column's spacebetween
                    Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            currentChannel.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            subTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ]),
                    // const SizedBox(height: 1),

                    GestureDetector(
                        onTap: () {
                          //change the style
                          // siri9style = !siri9style;
                          // setState(() {});
                          // //then set amplitude VIA the function
                          // if (waveActive) {
                          //   setWaveAnimation(true, force: true);
                          // } else {
                          //   setWaveAnimation(false, force: true);
                          // }
                        },
                        child: SiriWave(
                          controller: waveController,
                          style: siri9style
                              ? SiriWaveStyle.ios_9
                              : SiriWaveStyle.ios_7,
                          options: const SiriWaveOptions(
                              showSupportBar: true, width: double.infinity),
                        )),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: actions),
                    ),
                  ]),
            ),
            // (mediaQuery.size.width < 900)
            //     ?
            // normalPhonePlayerColumn()
            // : Row(
            //     mainAxisSize: MainAxisSize.max,
            //     children: [
            //       Container(
            //           width: (mediaQuery.size.width * .7),
            //           child: normalPhonePlayerColumn()),
            //       Container(
            //           width: mediaQuery.size.width * .3,
            //           child: const ChannelsGrid())
            //     ],
            //     // children: [Placeholder(), const Placeholder()],
            //   ),
          )),
    );
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final Future<void> Function() errorHandler;
  final void Function(bool?) playingReporter;

  const ControlButtons(this.player, this.errorHandler, this.playingReporter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> playWithErrorCheck(
        BuildContext context, AudioPlayer player) async {
      HapticFeedback.mediumImpact();
      try {
        var dur = await player.load();
        print(dur.toString());

        player.play();
      } on PlatformException catch (e) {
        // player.stop();
        print('PlatformException $e');
        errorHandler();
        return;
      } on PlayerException catch (e) {
        print('PlayerException ${e.runtimeType} $e');
        errorHandler();
        return;
      } catch (e) {
        // player.stop();
        print(e.runtimeType);
        print('runtimetype above');
        errorHandler();
        return;
      }
      print('end of playWithErrorCheck');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            playingReporter(playing);

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering ||
                (processingState == ProcessingState.buffering &&
                    playing == false)) {
              return const SizedBox(
                // margin: const EdgeInsets.all(8.0),
                width: 66.0,
                height: 66.0,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return playButtonColored(
                  icon: Icons.play_arrow,
                  onPressed: () => playWithErrorCheck(context, player));
            } else if (processingState != ProcessingState.completed) {
              return playButtonColored(
                icon: Icons.pause,
                onPressed: player.stop,
              );
            } else {
              return playButtonColored(
                icon: Icons.replay,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
      ],
    );
  }
}

Widget playButtonColored({required IconData icon, void Function()? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(8),
    ),
    child: Icon(
      icon,
      size: 50,
    ),
  );
}
