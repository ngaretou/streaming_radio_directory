// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';
import '../providers/channels.dart';
import 'filter_button.dart';

class ChannelsGrid extends StatefulWidget {
  const ChannelsGrid({Key? key}) : super(key: key);

  @override
  State<ChannelsGrid> createState() => _ChannelsGridState();
}

class _ChannelsGridState extends State<ChannelsGrid> {
  ValueNotifier<String> searchTerm = ValueNotifier("");
  final stationSearchController = TextEditingController();
  List<Channel> channelsToDisplay = [];
  late bool grid;
  String? selectedCountry;
  String? selectedLanguage;

  @override
  void initState() {
    grid = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final List<Channel> allChannels =
        Provider.of<Channels>(context, listen: false).channels;

    if (channelsToDisplay.isEmpty) {
      channelsToDisplay.addAll(allChannels);
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

            Map<String, String> languageAbbreviations = {
              "en": "English",
              "es": "Español",
              "fr": "Français",
              "sw": "Swahili"
            };

            // Grab all the languages and countries
            for (var channel in allChannels) {
              allCountryEntries.add(channel.country);
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: 300,
                    // width: 700,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButtonFormField(
                            value: selectedCountry,
                            items: countryDropDowns,
                            onChanged: (i) {
                              selectedCountry = i;
                            },
                            decoration: const InputDecoration(
                              filled: false,
                              border: OutlineInputBorder(),
                              labelText: 'Country',
                            ),
                          ),
                          DropdownButtonFormField(
                            value: selectedLanguage,
                            items: languageDropDowns,
                            onChanged: (i) {
                              selectedLanguage = i;
                            },
                            decoration: const InputDecoration(
                              filled: false,
                              border: OutlineInputBorder(),
                              labelText: 'Language',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                  onPressed: () {
                                    print(selectedCountry);
                                    print(selectedLanguage);
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('OK')),
                              OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'))
                            ],
                          )
                        ])),
              ),
            );
          });
    }

    Widget radioBadge(String path) {
      return CachedNetworkImage(
        //TODO clear cache when new json data is detected
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
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
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
            );
            // return Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ListTile(

            //     visualDensity: VisualDensity.standard,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     leading: radioBadge(data[index].image),
            //     title: Text(data[index].name),
            //     contentPadding: const EdgeInsets.all(8),
            //     tileColor: Colors.amber,
            //   ),
            // );
          },
          childCount: data.length,
        ),
      );
    }

    Widget gridView(List<Channel> data) {
      return SliverGrid.count(
        childAspectRatio: .7,
        crossAxisCount: 3,
        children: List.generate(data.length, (index) {
          return GestureDetector(
            onTap: () {
              print(data[index].name);
            },
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
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              overflow: TextOverflow.fade,
                            ),
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

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SizedBox(
                height: 62,
              ),
              Form(
                key: formKey,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: stationSearchController,
                        onChanged: (value) {
                          if (value.length > 2 || value.isEmpty) {
                            filterStationsByName(stationSearchController.text);
                            searchTerm.value = value;
                            // setState(() {});
                          }
                        },
                        // onFieldSubmitted: (value) => fetchingListOfUsers =
                        //     getNamesList(userSearchController.text),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 74, 74, 74),
                          hintText: 'Enter part of name',
                          suffixIcon: ValueListenableBuilder(
                              valueListenable: searchTerm,
                              builder: (context, val, child) {
                                if (val.isNotEmpty) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        stationSearchController.clear();
                                        channelsToDisplay = [];
                                        searchTerm.value = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  );
                                } else {
                                  return const SizedBox(width: 20);
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
                        icon: const Icon(Icons.list)),
                    const SizedBox(width: 10),
                    FilterButton(
                        onPressed: () => showFilterOptions(),
                        icon: const Icon(Icons.filter_alt)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        //This rebuilds every time the searchTerm value changes
        ValueListenableBuilder(
            valueListenable: searchTerm,
            builder: (context, val, child) {
              //this is in the case some combination of filters results in no stations displayed
              if (channelsToDisplay.isEmpty) {
                return const Center(
                    child: Icon(
                  Icons.access_alarm,
                  size: 200,
                ));
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
              const SizedBox(
                height: 40,
              ),
              lowerOptions(
                  context, Icons.info, 'Licenses', () => showLicenses(context)),
              lowerDivider(),
              lowerOptions(context, Icons.access_time, 'About',
                  () => showAbout(context)),
            ],
          ),
        ),
      ],
    );
  }
}

void showLicenses(BuildContext context) {
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
      applicationName: 'Streaming Radio',
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
              .headlineSmall!
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

showAbout(BuildContext context) {
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // if (!mounted) return;
  showAboutDialog(
    context: context,
    applicationName: 'Radio',
    // applicationVersion: packageInfo.version,
    applicationLegalese: '© 2023 SIM',
    // children: [],
    applicationIcon: Image.asset(
      'assets/images/icon.png',
      fit: BoxFit.cover,
      width: 52,
      // filterQuality: FilterQuality.high,
    ),
    // Container(
    //   // color: $styles.colors.black,
    //   // padding: EdgeInsets.all($styles.insets.xs),
    //   child: Image.asset(
    //     'assets/images/icon.png',
    //     fit: BoxFit.cover,
    //     width: 52,
    //     // filterQuality: FilterQuality.high,
    //   ),
    // ),
  );
}
