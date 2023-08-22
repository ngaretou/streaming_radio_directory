// import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/channels.dart';
import '../providers/theme.dart';
import '../providers/info.dart';
import 'filter_button.dart';
import 'sliver_header.dart';
import 'circle_button.dart';

class ChannelsGrid extends StatefulWidget {
  const ChannelsGrid({Key? key}) : super(key: key);

  @override
  State<ChannelsGrid> createState() => _ChannelsGridState();
}

class _ChannelsGridState extends State<ChannelsGrid> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final stationSearchController = TextEditingController();
  ValueNotifier<String> searchTerm = ValueNotifier("");

  List<Channel> allChannels = [];
  List<Channel> channelsToDisplay = [];
  String? currentChannelID;
  late Channels channelsProvider;
  late bool grid;

  //for channel filtering
  String? filterCountry;
  String? filterLanguage;

  //for interface display
  String? selectedInterfaceLang;
  // channelGridDisplayTranslation as opposed to the dialog display translation below
  late Translation channelGridDisplayTranslation;
  late ThemeModel themeModel;

  late Future<void> init;
  late Box userPrefsBox;

  @override
  void initState() {
    grid = true;
    themeModel = Provider.of<ThemeModel>(context, listen: false);

    init = setTranslation();

    super.initState();
  }

  Future<void> setTranslation() async {
    channelGridDisplayTranslation = await getTranslation(context);
    userPrefsBox = await Hive.openBox('userPrefs');
    currentChannelID = userPrefsBox.get('currentChannel');
  }

  @override
  Widget build(BuildContext context) {
    channelsProvider = Provider.of<Channels>(context, listen: true);
    allChannels = channelsProvider.channels;
    // final mediaQuery = MediaQuery.of(context).size;
    // final bool isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;

    //handle filters
    if (filterCountry != null && filterLanguage == null) {
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
      channelsToDisplay
          .removeWhere((element) => element.country != filterCountry);
    } else if (filterCountry == null && filterLanguage != null) {
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
      channelsToDisplay
          .removeWhere((element) => element.language != filterLanguage);
    } else if (filterCountry != null && filterLanguage != null) {
      channelsToDisplay = [];
      for (var channel in allChannels) {
        if (channel.language == filterLanguage &&
            channel.country == filterCountry) {
          channelsToDisplay.add(channel);
        }
      }
    } else {
      //showing all channels
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
    }

    void sendNewStationToPlayer(Channel newChannel) {
      HapticFeedback.mediumImpact();
      channelsProvider.setCurrentChannel = newChannel;
      Navigator.of(context).pop(newChannel);
    }

    void filterStationsByName(String? nameFragment) {
      // In all cases setState(() {}); is done on the listview by valuelistenablebuilder
      if (nameFragment == '') //search box is empty
      {
        //reset the list
        channelsToDisplay = [];
        //add all users
        channelsToDisplay.addAll(allChannels);
      } else {
        //compare by lower case is important
        String nameFragmentLowerCase = nameFragment!.toLowerCase();
        RegExp exp = RegExp(nameFragmentLowerCase);
        //reset the list
        channelsToDisplay = [];
        //for each user get the info we're interested in apart and check for the info
        for (var channel in allChannels) {
          String nameToLowerCase = channel.name.toLowerCase();
          if (exp.hasMatch(nameToLowerCase)) {
            //if it's there, add to the list
            channelsToDisplay.add(channel);
          }
        }
        // print(channelsToDisplay[0].name);
      }
    }

    void showFilterOptions() {
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            List<String> allCountryEntries = [];
            List<String> allLanguageEntries = [];

            // Grab all the languages and countries
            for (var channel in allChannels) {
              //only add country if it has content
              if (channel.country != "") {
                allCountryEntries.add(channel.country);
              }
              allLanguageEntries.add(channel.language);
            }
            //Get rid of duplicates
            var countrySet = allCountryEntries.toSet();
            //return to list
            var countryList = countrySet.toList();
            //sort the list
            countryList.sort((a, b) => a.compareTo(b));

            //same for languages
            var langSet = allLanguageEntries.toSet();
            var langList = langSet.toList();
            langList.sort((a, b) => a.compareTo(b));

            List<DropdownMenuItem<String>> countryDropDowns =
                List.generate(countryList.length, ((index) {
              return DropdownMenuItem<String>(
                value: countryList[index],
                // onTap: () {},
                child: Text(
                  countryList[index],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }));

            // The
            List<DropdownMenuItem<String>> languageDropDowns = [];

            for (var i = 0; i < langList.length; i++) {
              //return the user-friendly language name from the languageAbbreviations map
              String? languageName = languageAbbreviations[langList[i]];

              if (languageName != null) {
                var entry = DropdownMenuItem<String>(
                  value: langList[i],
                  child: Text(
                    languageName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
                languageDropDowns.add(entry);
              }
            }
            // List.generate(langList.length, ((index) {

            // }));

            return Dialog(
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  //two States exist now - the dialog and the underlying channel screen.
                  //the clear filter button needs the dialog state to build/rebuild so the
                  //user can clear the filter. Here we set state on both states at different times.
                  // https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 300,
                        // width: 700,
                        decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButtonFormField(
                                value: filterCountry,
                                items: countryDropDowns,
                                onChanged: (i) {
                                  setState(() {
                                    filterCountry = i;
                                  });
                                  setDialogState(() {});
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  border: const OutlineInputBorder(),
                                  labelText:
                                      channelGridDisplayTranslation.country,
                                ),
                              ),
                              DropdownButtonFormField(
                                value: filterLanguage,
                                items: languageDropDowns,
                                onChanged: (i) {
                                  setState(() {
                                    filterLanguage = i;
                                  });
                                  setDialogState(() {});
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  border: const OutlineInputBorder(),
                                  labelText:
                                      channelGridDisplayTranslation.language,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                      onPressed: filterCountry != null ||
                                              filterLanguage != null
                                          ? () {
                                              filterCountry = null;
                                              filterLanguage = null;
                                              setState(() {});
                                              setDialogState(() {});
                                            }
                                          : null,
                                      child: Icon(
                                        Icons.filter_alt_off,
                                        color: filterCountry == null &&
                                                filterLanguage == null
                                            ? Colors.grey
                                            : Colors.red,
                                      )),
                                  const Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        });
                                      },
                                      child: Text(
                                          channelGridDisplayTranslation.oK)),
                                  OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                          channelGridDisplayTranslation.cancel))
                                ],
                              )
                            ])),
                  );
                },
              ),
            );
          });
    }

    void showAbout(BuildContext context) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text(packageInfo.appName),
              content: SingleChildScrollView(
                  child: ListBody(children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/icon.png',
                      fit: BoxFit.cover,
                      width: 52,
                      // filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            packageInfo.appName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                            'Version ${packageInfo.version} (${packageInfo.buildNumber})'),
                        const Text('© 2023 SIM'),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      text:
                          "All channel streams are the copyright of their respective owners. Responsibility for streamed content including managing the copyrights of the content remains that of the respective owners. \n\nTo add a new radio station to the app, ",
                    ),
                    TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                        text: "click here.",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url = 'https://forms.gle/s7YLtsAXUeJb2SmSA';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }),
                  ],
                )),
              ])),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('Licenses'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showLicenses(context,
                        appName: packageInfo.appName,
                        appVersion:
                            '${packageInfo.version} (${packageInfo.buildNumber})');
                  },
                ),
                OutlinedButton(
                  child: Text(channelGridDisplayTranslation.oK),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    Widget radioBadge(String path) {
      return CachedNetworkImage(
        // cacheManager: ,
        imageUrl: path,
        placeholder: (context, url) => Image.memory(kTransparentImage),
        fit: BoxFit.scaleDown,
        // progressIndicatorBuilder: (context, url, downloadProgress) =>
        //     CircularProgressIndicator(
        //         value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.radio),
      );
    }

    Widget listView(List<Channel> data) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => sendNewStationToPlayer(data[index]),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.rectangle),
                  height: 75,
                  child: Row(
                    children: [
                      Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: radioBadge(data[index].image)),
                      const SizedBox(width: 30),
                      Text(data[index].name,
                          style: Theme.of(context).textTheme.titleMedium)
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: data.length,
        ),
      );
    }

    Widget gridView(List<Channel> data) {
      return SliverGrid.extent(
        childAspectRatio: .65,
        // crossAxisCount: isPhone ? 3 : 6,
        maxCrossAxisExtent: 150,
        children: List.generate(data.length, (index) {
          return GestureDetector(
            onTap: () => sendNewStationToPlayer(data[index]),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: radioBadge(data[index].image)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Flex(direction: Axis.horizontal, children: [
                    Expanded(
                      child: Center(
                        child: Text(data[index].name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  // fontSize: 20,
                                  color: Colors.white,
                                  overflow: TextOverflow.fade,
                                ),
                            maxLines: 2,
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }),
      );
    }

    //
    print('channels grid build');
    return FutureBuilder(
      future: init,
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          //this is actually where the business happens; HTML just takes the data and renders it
          //SelectableHtml makes it selectable but you lose some formatting
          : RefreshIndicator(
              onRefresh: () async {
                await channelsProvider.getData(force: true);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          // top row of control buttons
                          CircleButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.close)),
                          const Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: 10,
                              )),

                          //This is the context menu for language
                          PopupMenuButton(
                            itemBuilder: (context) {
                              //This is the user selected value
                              String? selectedLanguage =
                                  userPrefsBox.get('selectedLanguage');

                              // ignore: prefer_conditional_assignment
                              if (selectedLanguage == null) {
                                selectedLanguage = 'auto';
                              }

                              List<CheckedPopupMenuItem> allLanguageEntries =
                                  [];

                              var currentChannelLanguageCode = allChannels
                                  .where((element) =>
                                      element.id == currentChannelID)
                                  .first
                                  .language;
                              var currentChannelLanguageName =
                                  languageAbbreviations[
                                      currentChannelLanguageCode];

                              languageAbbreviations.forEach((key, value) {
                                late String label;
                                if (key == 'auto') {
                                  label =
                                      '$value ($currentChannelLanguageName)';
                                } else {
                                  label = value;
                                }

                                allLanguageEntries.add(CheckedPopupMenuItem(
                                    value: key,
                                    checked: selectedLanguage == key,
                                    child: Text(label)));
                              });

                              return allLanguageEntries;
                            },
                            onSelected: (value) async {
                              setUsersChosenInterfaceLanguage(value);
                              channelGridDisplayTranslation =
                                  await getTranslation(context);
                              setState(() {});
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Icon(
                                Icons.translate,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleButton(
                              onPressed: () {
                                ThemeModel themeProvider =
                                    Provider.of<ThemeModel>(context,
                                        listen: false);

                                var brightnessToSet =
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Brightness.light
                                        : Brightness.dark;
                                themeProvider.setTheme(
                                    brightness: brightnessToSet, refresh: true);
                              },
                              child: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Icon(Icons.light_mode)
                                  : const Icon(Icons.dark_mode)),
                        ],
                      ),
                    ),
                  ])),
                  SliverPersistentHeader(
                      pinned: true,
                      delegate: MySliverPersistentHeaderDelegate(
                        Column(
                          children: [
                            Form(
                              key: formKey,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: Colors.white70),
                                      controller: stationSearchController,
                                      onChanged: (value) {
                                        if (value.length > 2 || value.isEmpty) {
                                          filterStationsByName(
                                              stationSearchController.text);
                                          searchTerm.value = value;
                                          // setState(() {});
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            255, 74, 74, 74),
                                        hintText: channelGridDisplayTranslation
                                            .enterName,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(color: Colors.white70),
                                        border: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.red),
                                        ),

                                        suffixIcon: ValueListenableBuilder(
                                            valueListenable: searchTerm,
                                            builder: (context, val, child) {
                                              if (val.isNotEmpty) {
                                                return IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      stationSearchController
                                                          .clear();
                                                      channelsToDisplay = [];
                                                      searchTerm.value = '';
                                                    });
                                                  },
                                                  icon: const Icon(Icons.clear),
                                                );
                                              } else {
                                                return const SizedBox(
                                                    width: 20);
                                              }
                                            }),

                                        // The validator receives the text that the user has entered.
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  FilterButton(
                                      onPressed: () {
                                        setState(() {
                                          grid = !grid;
                                        });
                                      },
                                      icon: grid
                                          ? const Icon(Icons.view_list)
                                          : const Icon(Icons.grid_view)),
                                  const SizedBox(width: 10),
                                  FilterButton(
                                      onPressed: showFilterOptions,
                                      // if no filters are selected make the icon filter off
                                      icon: filterCountry == null &&
                                              filterLanguage == null
                                          ? const Icon(Icons.filter_alt_off)
                                          : const Icon(Icons.filter_alt)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),

                  //This rebuilds every time the searchTerm value changes
                  ValueListenableBuilder(
                      valueListenable: searchTerm,
                      builder: (context, val, child) {
                        //this is in the case some combination of filters results in no stations displayed
                        if (channelsToDisplay.isEmpty) {
                          return SliverList(
                              delegate: SliverChildListDelegate([
                            const Center(
                                child: Icon(Icons.sentiment_dissatisfied,
                                    size: 150, color: Colors.white))
                          ]));
                        } else {
                          //choose here between grid and list view
                          return grid
                              ? gridView(channelsToDisplay)
                              : listView(channelsToDisplay);
                        }
                      }),

                  //bottom buttons
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // const SizedBox(
                        //   height: 40,
                        // ),
                        // lowerOptions(
                        //     context, Icons.info, 'Licenses', () => showLicenses(context)),
                        lowerDivider(),
                        lowerOptions(
                            context,
                            Icons.info,
                            channelGridDisplayTranslation.about,
                            () => showAbout(context)),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

void showLicenses(BuildContext context, {String? appName, String? appVersion}) {
  void showLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    // assert(context != null);
    // assert(useRootNavigator != null);
    Navigator.of(context, rootNavigator: useRootNavigator)
        .push(MaterialPageRoute<void>(
      builder: (BuildContext context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
    ));
  }

  showLicensePage(
      context: context,
      applicationVersion: appVersion,
      applicationName: appName,
      useRootNavigator: true);
}

Widget lowerOptions(
    BuildContext context, IconData icon, String label, void Function()? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}

Widget lowerDivider() {
  return const Divider(
    height: 40,
    indent: 50,
    endIndent: 50,
    thickness: 2,
    color: Colors.white,
  );
}
