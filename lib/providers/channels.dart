import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';
import 'dart:async';
import 'dart:convert';

class Action {
  final String address;
  final String icon;

  Action({required this.address, required this.icon});

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action(
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
  final List<Action> actions;
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
          .map<Action>((action) => Action.fromJson(action))
          .toList(),
      image: json['image'],
      streams:
          json['streams'].map<String>((stream) => stream.toString()).toList(),
    );
  }
}

class Channels with ChangeNotifier {
  List<Channel> channels = [];

  // List<Channel> get channels {
  //   return [..._channels];
  // }

  Channel? _currentChannel;

  Channel get currentChannel {
    if (_currentChannel != null) {
      _currentChannel = channels[0];
    }
    return _currentChannel!;
  }

  set currentChannel(Channel incomingChannel) {
    _currentChannel = incomingChannel;
  }

  Future<List<Channel>> getData() async {
    //TODO get data from web
    //get json list from web
    //check to see if the time/date stamp is different than the last time
    //if it is different, save it to the documents directory
    //now get the data from the json file in the documents directory
    String channelsJSON = await rootBundle.loadString("assets/channels.json");
    List channelsData = json.decode(channelsJSON);
    channels = channelsData
        .map((jsonchannel) => Channel.fromJson(jsonchannel))
        .toList();

    // notifyListeners();
    return channels;
  }
}
