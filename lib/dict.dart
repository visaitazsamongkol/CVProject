import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:mdi/mdi.dart';
import 'package:audioplayers/audioplayers.dart';
import './globals.dart' as globals;
import './dict_api/dict_search.dart' as dict_search;

class Dict extends StatefulWidget {
  @override
  State<Dict> createState() => _DictState();
}

class _DictState extends State<Dict> {
  bool loading = false;
  AudioPlayer audioPlayer = AudioPlayer();

  Widget buildDescription(dynamic description) {
    List<Widget> definitionWidgets = <Widget>[];
    if (description["definitions"].length > 0) {
      for (int i = 0; i <= description["definitions"].length - 1; i++) {
        String verbDivider =
            description["definitions"][i]["verb_divider"].split(" ")[0];
        String meaning = description["definitions"][i]["meaning"];
        List<String> examples =
            description["definitions"][i]["examples"].cast<String>();
        print(meaning);

        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "${i + 1} ${verbDivider == "" ? "" : "[$verbDivider] "}$meaning",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
        definitionWidgets.add(meaningWidget);

        if (examples.length != 0) {
          bool isFirstExample = true;
          for (String example in examples) {
            Align exampleWidget;
            if (isFirstExample) {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: Text("e.g. $example"));
              isFirstExample = false;
            } else {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: Text("       $example"));
            }
            definitionWidgets.add(exampleWidget);
          }
        }

        definitionWidgets.add(SizedBox(height: 10));
      }
    } else {
      for (int i = 0; i <= description["all_meanings"].length - 1; i++) {
        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text("${description["all_meanings"][i]}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
        definitionWidgets.add(meaningWidget);
      }
    }
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "${description["syllable"]} (${description["pos"]})",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        description["audio_links"].length == 0
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () async =>
                    await audioPlayer.play(description["audio_links"][0]),
                icon: const Icon(Icons.volume_up),
                iconSize: 24,
                color: Colors.grey,
                tooltip: "Play Word Audio")
      ]),
      description["audio_links"].length == 0
          ? SizedBox(height: 15)
          : SizedBox.shrink(),
      ...definitionWidgets
    ]);
  }

  void showDictionaryDescriptions(String word) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      final descriptions = globals.dictionaryCache[word];
      return Scaffold(
          appBar: AppBar(title: Text(word), centerTitle: true),
          body: descriptions == null
              ? Container(
                  alignment: Alignment.center,
                  child: Text("Not Found in Dictionary!",
                      style: TextStyle(fontSize: 28)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  itemCount: descriptions.length * 2 - 1,
                  itemBuilder: (context, item) {
                    if (item.isOdd)
                      return Divider(thickness: 3.0, color: Colors.orange);
                    final index = item ~/ 2;
                    return buildDescription(descriptions[index]);
                  }));
    }));
  }

  void showThesaurusDescriptions(String word) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      final descriptions = globals.thesaurusCache[word];
      return Scaffold(
          appBar: AppBar(title: Text(word), centerTitle: true),
          body: ListView(
            children: [
              Text(descriptions.toString()),
            ],
          ));
    }));
  }

  // Future<http.Response> sendWordToDictionary(String word) async {
  //   var url =
  //       "https://dictionary-search-ocr-server.herokuapp.com/search/dictionary";
  //   //encode Map to JSON
  //   var res = await http.post(Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode([word]));
  //   if (res.statusCode == 200) {
  //     var resJson = json.decode(res.body);
  //     globals.dictionaryCache[word] =
  //         resJson[word].cast<Map<String, dynamic>>();
  //   }
  //   return res;
  // }

  // Future<http.Response> sendWordToThesaurus(String word) async {
  //   var url =
  //       "https://dictionary-search-ocr-server.herokuapp.com/search/thesaurus";
  //   //encode Map to JSON
  //   var res = await http.post(Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode([word]));
  //   if (res.statusCode == 200) {
  //     var resJson = json.decode(res.body);
  //     globals.thesaurusCache[word] = resJson[word].cast<Map<String, dynamic>>();
  //   }
  //   return res;
  // }

  dynamic sendWordToDictionary(String word) async {
    setState(() => loading = true);
    var descriptions = await dict_search.search_dictionary(word);
    globals.dictionaryCache[word] = descriptions;
    setState(() => loading = false);
    return globals.dictionaryCache[word];
  }

  dynamic sendWordToThesaurus(String word) async {
    setState(() => loading = true);
    var descriptions = await dict_search.search_thesaurus(word);
    globals.thesaurusCache[word] = descriptions;
    setState(() => loading = false);
    return globals.thesaurusCache[word];
  }

  Widget buildRow(String word, int index) {
    word = word.capitalize!;
    return ListTile(
        title: Text(word, style: TextStyle(fontSize: 18.0)),
        tileColor:
            index % 2 == 0 ? Colors.orange.shade200 : Colors.yellow.shade300,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              iconSize: 30.0,
              icon: const Icon(Mdi.alphaDBox),
              color: Colors.green,
              tooltip: "Collegiate Dictionary Search",
              onPressed: () async {
                if (!globals.dictionaryCache.containsKey(word)) {
                  await sendWordToDictionary(word);
                }
                showDictionaryDescriptions(word);
              }),
          IconButton(
              iconSize: 30.0,
              icon: const Icon(Mdi.alphaTBox),
              color: Colors.blue,
              tooltip: "Collegiate Thesaurus Search",
              onPressed: () async {
                if (!globals.thesaurusCache.containsKey(word)) {
                  await sendWordToThesaurus(word);
                }
                showThesaurusDescriptions(word);
              }),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Dictionary Search'), centerTitle: true),
        body: loading
            ? globals.startProgressIndicator(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: globals.wordList!.length * 2,
                itemBuilder: (context, item) {
                  if (item.isOdd) return Divider();
                  final index = item ~/ 2;
                  return buildRow(globals.wordList![index], index);
                }));
  }
}
