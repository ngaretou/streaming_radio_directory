// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';
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
  ValueNotifier<String> searchTerm = ValueNotifier("");
  final stationSearchController = TextEditingController();
  List<Channel> allChannels = [];
  List<Channel> channelsToDisplay = [];
  late bool grid;
  String? selectedCountry;
  String? selectedLanguage;

  @override
  void initState() {
    grid = true;
    allChannels = Provider.of<Channels>(context, listen: false).channels;
    // channelsToDisplay.addAll(allChannels);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final mediaQuery = MediaQuery.of(context).size;
    final bool isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;

    //handle filters
    if (selectedCountry != null && selectedLanguage == null) {
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
      channelsToDisplay
          .removeWhere((element) => element.country != selectedCountry);
    } else if (selectedCountry == null && selectedLanguage != null) {
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
      channelsToDisplay
          .removeWhere((element) => element.language != selectedLanguage);
    } else if (selectedCountry != null && selectedLanguage != null) {
      channelsToDisplay = [];
      for (var channel in allChannels) {
        if (channel.language == selectedLanguage &&
            channel.country == selectedCountry) {
          channelsToDisplay.add(channel);
        }
      }
    } else {
      //showing all channels
      channelsToDisplay = [];
      channelsToDisplay.addAll(allChannels);
    }

    void sendNewStationToPlayer(Channel newChannel) {
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
                                value: selectedCountry,
                                items: countryDropDowns,
                                onChanged: (i) {
                                  setState(() {
                                    selectedCountry = i;
                                  });
                                  setDialogState(() {});
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
                                  setState(() {
                                    selectedLanguage = i;
                                  });
                                  setDialogState(() {});
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
                                      onPressed: selectedCountry != null ||
                                              selectedLanguage != null
                                          ? () {
                                              selectedCountry = null;
                                              selectedLanguage = null;
                                              setState(() {});
                                              setDialogState(() {});
                                            }
                                          : null,
                                      child: Icon(
                                        Icons.filter_alt_off,
                                        color: selectedCountry == null &&
                                                selectedLanguage == null
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
                                        print(selectedCountry);
                                        print(selectedLanguage);
                                        setState(() {
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        });
                                      },
                                      child: const Text('OK')),
                                  OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'))
                                ],
                              )
                            ])),
                  );
                },
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
      return SliverGrid.extent(
        childAspectRatio: .65,
        // crossAxisCount: isPhone ? 3 : 6,
        maxCrossAxisExtent: 150,
        children: List.generate(data.length, (index) {
          return GestureDetector(
            onTap: () {
              print(data[index].name);
              sendNewStationToPlayer(data[index]);
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

    //

    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                //header spacer so the close/theme button row shows
                CircleButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close)),
                const Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 10,
                    )),
                CircleButton(
                    onPressed: () {
                      ThemeModel themeProvider =
                          Provider.of<ThemeModel>(context, listen: false);
                      //       ThemeComponents _themeToSet = ThemeComponents(
                      // brightness: Brightness.light, color: _userTheme.color);
                      var brightnessToSet =
                          Theme.of(context).brightness == Brightness.dark
                              ? Brightness.light
                              : Brightness.dark;
                      themeProvider.setTheme(
                          brightness: brightnessToSet, refresh: true);
                    },
                    icon: Theme.of(context).brightness == Brightness.dark
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
                            controller: stationSearchController,
                            onChanged: (value) {
                              if (value.length > 2 || value.isEmpty) {
                                filterStationsByName(
                                    stationSearchController.text);
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
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.white70),
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(width: 3, color: Colors.red),
                              ),

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
                            icon: grid
                                ? const Icon(Icons.view_list)
                                : const Icon(Icons.grid_view)),
                        const SizedBox(width: 10),
                        FilterButton(
                            onPressed: () => showFilterOptions(),
                            // if no filters are selected make the icon filter off
                            icon: selectedCountry == null &&
                                    selectedLanguage == null
                                ? const Icon(Icons.filter_alt_off)
                                : const Icon(Icons.filter_alt)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        // SliverList(
        //   delegate: SliverChildListDelegate(
        //     [
        //       //header spacer so the close/theme button row shows
        //       const SizedBox(
        //         height: 62,
        //       ),
        //       //search bar, grid/list button, filter button
        //       Form(
        //         key: formKey,
        //         child: Row(
        //           children: <Widget>[
        //             Expanded(
        //               child: TextFormField(
        //                 controller: stationSearchController,
        //                 onChanged: (value) {
        //                   if (value.length > 2 || value.isEmpty) {
        //                     filterStationsByName(stationSearchController.text);
        //                     searchTerm.value = value;
        //                     // setState(() {});
        //                   }
        //                 },
        //                 // onFieldSubmitted: (value) => fetchingListOfUsers =
        //                 //     getNamesList(userSearchController.text),
        //                 decoration: InputDecoration(
        //                   filled: true,
        //                   fillColor: const Color.fromARGB(255, 74, 74, 74),
        //                   hintText: 'Enter part of name',
        //                   hintStyle: Theme.of(context)
        //                       .textTheme
        //                       .labelLarge!
        //                       .copyWith(color: Colors.white70),
        //                   border: const UnderlineInputBorder(
        //                     borderSide: BorderSide(width: 3, color: Colors.red),
        //                   ),

        //                   suffixIcon: ValueListenableBuilder(
        //                       valueListenable: searchTerm,
        //                       builder: (context, val, child) {
        //                         if (val.isNotEmpty) {
        //                           return IconButton(
        //                             onPressed: () {
        //                               setState(() {
        //                                 stationSearchController.clear();
        //                                 channelsToDisplay = [];
        //                                 searchTerm.value = '';
        //                               });
        //                             },
        //                             icon: const Icon(Icons.clear),
        //                           );
        //                         } else {
        //                           return const SizedBox(width: 20);
        //                         }
        //                       }),

        //                   // The validator receives the text that the user has entered.
        //                 ),
        //               ),
        //             ),
        //             const SizedBox(width: 10),
        //             FilterButton(
        //                 onPressed: () {
        //                   setState(() {
        //                     grid = !grid;
        //                   });
        //                 },
        //                 icon: grid
        //                     ? const Icon(Icons.view_list)
        //                     : const Icon(Icons.grid_view)),
        //             const SizedBox(width: 10),
        //             FilterButton(
        //                 onPressed: () => showFilterOptions(),
        //                 // if no filters are selected make the icon filter off
        //                 icon:
        //                     selectedCountry == null && selectedLanguage == null
        //                         ? const Icon(Icons.filter_alt_off)
        //                         : const Icon(Icons.filter_alt)),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(height: 20),
        //     ],
        //   ),
        // ),

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
              const SizedBox(
                height: 40,
              ),
              // lowerOptions(
              //     context, Icons.info, 'Licenses', () => showLicenses(context)),
              // lowerDivider(),
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
