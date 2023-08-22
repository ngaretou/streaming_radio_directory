import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ChannelAction {
  final String? address;
  final String? icon;

  ChannelAction({this.address, this.icon});

  factory ChannelAction.fromJson(Map<String, dynamic> json) {
    return ChannelAction(
      address: json['address'],
      icon: json['icon'],
    );
  }
}

class Channel {
  final String id;
  final String name;
  final String country;
  final String language;
  final List<ChannelAction> actions;
  final String image;
  final List<String> streams;

  Channel({
    required this.id,
    required this.name,
    required this.country,
    required this.language,
    required this.actions,
    required this.image,
    required this.streams,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      language: json['language'],
      actions: json['actions']
          .map<ChannelAction>((action) => ChannelAction.fromJson(action))
          .toList(),
      image: json['image'],
      streams:
          json['streams'].map<String>((stream) => stream.toString()).toList(),
    );
  }
}

class Channels with ChangeNotifier {
  List<Channel> channels = [];

  late Channel _currentChannel;

  Channel get currentChannel => _currentChannel;

  set setCurrentChannel(Channel channel) {
    _currentChannel = channel;
    saveCurrentChannel(channel.id);
  }

  Future<List<Channel>> getData({bool? force}) async {
    final directory = await getApplicationSupportDirectory();
    String appDataChannelsPath = '${directory.path}/channels.json';
    File appDataChannels = File(appDataChannelsPath);
    String appDataChannelsOldPath = '${directory.path}/channels-old.json';
    File appDataChannelsOld = File(appDataChannelsOldPath);
    String url = 'https://coreygarrett.org/channels.json';
    Box userPrefsBox = await Hive.openBox('userPrefs');
    late String channelsJSON; //the String of json
    List channelsData = []; //the data from channelsJSON
    int daysBetween = 0;

    //get data from web
    Future<bool> checkFileExists(File file) async {
      try {
        if (await file.exists()) {
          print('Found the file');

          return true;
        } else {
          return false;
        }
      } catch (e) {
        print('had an error checking if the file was there or not');
        return false;
      }
    }

    Future<void> downloadAndUseNewConfigFile() async {
      try {
        //get the file
        final http.Response r = await http.get(Uri.parse(url));

        //read last-modified and save it for later
        final rawWebFileTimeStamp = r.headers["last-modified"];
        userPrefsBox.put("last-modified", rawWebFileTimeStamp);

        //save the old one
        if (await checkFileExists(appDataChannels)) {
          await appDataChannels.copy(appDataChannelsOldPath);
        }

        try {
          //now save the new file to disk
          await appDataChannels.writeAsString(r.body);
          print('downloaded, now writing new web version to disk');
        } catch (e) {
          //if problem with this go back to the old file
          print('$e: problem saving new config file');
          await appDataChannelsOld.copy(appDataChannelsPath);
        }
      } catch (e) {
        print('$e: problem downloading and saving new config file');
      }
    }

    Future<void> useLocalConfigFile() async {
      print('using local file');
      try {
        channelsJSON = await appDataChannels.readAsString();
      } catch (e) {
        try {
          print('$e: problem using new file, rolling back to old one');
          channelsJSON = await appDataChannelsOld.readAsString();
        } catch (e) {
          print('$e: problem using new file, rolling back to asset file');
          channelsJSON = await rootBundle.loadString("assets/channels.json");
        }
      }
    }

    //begins here
    //get the last run time of this method
    String? lastRunAsString = userPrefsBox.get('getDataRunTime');
    //null check
    if (lastRunAsString != null) {
      var parsedDate = DateTime.parse(lastRunAsString);
      //is it more than one day since last time run?
      daysBetween = DateTime.now().difference(parsedDate).inDays;
    }

    //if so, or if there just is no lastRunAsString, then get from the web

    if ((lastRunAsString == null || daysBetween > 1) || force == true) {
      // if (true) {
      bool localFileExists = await checkFileExists(appDataChannels);

      try {
        //check if a channels.json exists in appdata
        if (localFileExists) {
          print('local file exists');
          //if channels.json exists in appdata, get the new time stamp from the web and compare.
          final http.Response r = await http.head(Uri.parse(url));
          String? webFileTimeStamp = r.headers["last-modified"];
          String? oldTimeStamp = userPrefsBox.get("last-modified");

          //if the webFileTimeStamp is null, something went wrong,
          //so watch for that.
          if (webFileTimeStamp != null) {
            //if it's not null, then compare. If not the same,  downloadAndUseNewConfigFile
            if (webFileTimeStamp != oldTimeStamp) {
              await downloadAndUseNewConfigFile();
            }
            //the absence of else here continues below at useLocalConfigFile
          }
        } else {
          print('local file does not exist');
          //if channels.json does not exist in appdata, just get the new
          await downloadAndUseNewConfigFile();
        }
      } catch (e) {
        print('$e: problem checking if local file exists');
      }
    }

    // Now use the file we've gotten - whether we've downloaded it anew or not

    await useLocalConfigFile();
    // final utf8Decoder = utf8.decoder;

    //much trying and catching here but this is the one that does the most
    try {
      //utf8.decode: json has accented characters so needs an extra unicode decoding, see:
      // https://stackoverflow.com/questions/51368663/flutter-fetched-japanese-character-from-server-decoded-wrong
      // List<int> codes = channelsJSON.codeUnits;
      // channelsData = json.decode(const Utf8Decoder().convert(codes));

      // var utf8version = utf8.decode(codes);
      // channelsData = json.decode(utf8version);
      // print(channelsData[0]);
      channelsData = json.decode((channelsJSON)) as List<dynamic>;
    } catch (e) {
      try {
        channelsJSON = await appDataChannelsOld.readAsString();
        // channelsData = json.decode(utf8.decode(channelsJSON.codeUnits));

        channelsData = json.decode(utf8.decode(channelsJSON.codeUnits));
//        // channelsData = json.decode((channelsJSON));
      } catch (e) {
        print('$e: getting info from assets 2');
        //if there's a problem just use the default from assets.
        channelsJSON = await rootBundle.loadString("assets/channels.json");

        channelsData = json.decode(utf8.decode(channelsJSON.codeUnits));
        // channelsData = json.decode((channelsJSON));
      }
    }

    //With the above accomplished,

    channels = channelsData
        .map((jsonchannel) => Channel.fromJson(jsonchannel))
        .toList();

    //get the last channel viewed - or use first if none stored
    String? storedChannel =
        userPrefsBox.get('currentChannel') ?? channels.first.id;

    //and put it as the currentchannel
    _currentChannel =
        channels.where((element) => element.id == storedChannel).first;

    //store last time this successfully run
    userPrefsBox.put('getDataRunTime', DateTime.now().toIso8601String());
    //this is in case of an update after open - triggered by refresh in channnels grid
    notifyListeners();
    return channels;
  }

  Future<void> saveCurrentChannel(String channelID) async {
    Box userPrefsBox = await Hive.openBox('userPrefs');
    userPrefsBox.put('currentChannel', channelID);
  }
}
