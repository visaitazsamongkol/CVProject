import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mdi/mdi.dart';
import 'package:audioplayers/audioplayers.dart';
import 'globals.dart' as globals;
import 'dict_api/dict_search.dart' as dict_search;

class Dict extends StatefulWidget {
  const Dict({Key? key}) : super(key: key);

  @override
  State<Dict> createState() => _DictState();
}

class _DictState extends State<Dict> {
  bool loading = false;
  AudioPlayer audioPlayer = AudioPlayer();

  Widget getRichTextSpan(String boldText, String normalText) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
                text: boldText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: normalText)
          ]),
    );
  }

  Widget buildDictionaryDescription(dynamic description) {
    List<Widget> definitionWidgets = <Widget>[];
    if (description["definitions"].length > 0) {
      for (int i = 0; i <= description["definitions"].length - 1; i++) {
        String verbDivider =
            description["definitions"][i]["verb_divider"].split(" ")[0];
        String meaning = description["definitions"][i]["meaning"];
        List<String> examples =
            description["definitions"][i]["examples"].cast<String>();
        List<String> categories =
            description["definitions"][i]["categories"].cast<String>();

        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "${i + 1}  ${verbDivider == "" ? "" : "[$verbDivider] "}${categories.isEmpty ? "" : "[${categories.join("/")}] "}$meaning",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade800)));
        definitionWidgets.add(meaningWidget);

        if (examples.isNotEmpty) {
          bool isFirstExample = true;
          for (String example in examples) {
            Align exampleWidget;
            if (isFirstExample) {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: getRichTextSpan("e.g. ", example));
              isFirstExample = false;
            } else {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: Text("        $example"));
            }
            definitionWidgets.add(exampleWidget);
          }
        }

        definitionWidgets.add(const SizedBox(height: 15));
      }
    } else if (description["all_meanings"].length > 0) {
      for (int i = 0; i <= description["all_meanings"].length - 1; i++) {
        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text("${description["all_meanings"][i]}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade800)));
        definitionWidgets.add(meaningWidget);
      }
    }
    return Column(children: [
      description["audio_links"].length == 0
          ? const SizedBox(height: 10)
          : const SizedBox.shrink(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "${description["syllable"]} (${description["pos"]})",
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        description["audio_links"].length == 0
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () async =>
                    await audioPlayer.play(description["audio_links"][0]),
                icon: const Icon(Icons.volume_up),
                iconSize: 24,
                color: Colors.grey,
                tooltip: "Play Word Audio")
      ]),
      description["audio_links"].length == 0
          ? const SizedBox(height: 15)
          : const SizedBox.shrink(),
      ...definitionWidgets
    ]);
  }

  Widget buildThesaurusDescription(dynamic description) {
    List<Widget> definitionWidgets = <Widget>[];
    if (description["definitions"].length > 0) {
      for (int i = 0; i <= description["definitions"].length - 1; i++) {
        String verbDivider =
            description["definitions"][i]["verb_divider"].split(" ")[0];
        String meaning = description["definitions"][i]["meaning"];
        List<String> examples =
            description["definitions"][i]["examples"].cast<String>();
        List<String> categories =
            description["definitions"][i]["categories"].cast<String>();
        List<String> synonymousPhrases =
            description["definitions"][i]["synonymous_phrases"].cast<String>();
        List<String> synonyms =
            description["definitions"][i]["synonyms"].cast<String>();
        List<String> antonyms =
            description["definitions"][i]["antonyms"].cast<String>();

        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "${i + 1}  ${verbDivider == "" ? "" : "[$verbDivider] "}${categories.isEmpty ? "" : "[${categories.join("/")}] "}$meaning",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade800)));
        definitionWidgets.add(meaningWidget);

        if (examples.isNotEmpty) {
          bool isFirstExample = true;
          for (String example in examples) {
            Align exampleWidget;
            if (isFirstExample) {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: getRichTextSpan("e.g. ", example));
              isFirstExample = false;
            } else {
              exampleWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: Text("        $example"));
            }
            definitionWidgets.add(exampleWidget);
          }
        }

        if (synonymousPhrases.isNotEmpty) {
          Align synPhrasesWidget = Align(
              alignment: Alignment.centerLeft,
              child: getRichTextSpan(
                  "syn (phrases): ",
                  synonymousPhrases.join(
                      ", "))); // Text("syn (phrases): ${synonymous_phrases.join(", ")}"));
          definitionWidgets.add(synPhrasesWidget);
        }

        if (synonyms.isNotEmpty) {
          Align synonymsWidget = Align(
              alignment: Alignment.centerLeft,
              child: getRichTextSpan("syn: ",
                  synonyms.join(", "))); //Text("syn: ${synonyms.join(", ")}"));
          definitionWidgets.add(synonymsWidget);
        }

        if (antonyms.isNotEmpty) {
          Align antonymsWidget = Align(
              alignment: Alignment.centerLeft,
              child: getRichTextSpan("ant: ",
                  antonyms.join(", "))); //Text("ant: ${antonyms.join(", ")}"));
          definitionWidgets.add(antonymsWidget);
        }

        definitionWidgets.add(const SizedBox(height: 15));
      }
    } else if (description["all_meanings"].length > 0) {
      for (int i = 0; i <= description["all_meanings"].length - 1; i++) {
        Align meaningWidget = Align(
            alignment: Alignment.centerLeft,
            child: Text("${description["all_meanings"][i]}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade800)));
        definitionWidgets.add(meaningWidget);
      }
    }
    return Column(children: [
      const SizedBox(height: 10),
      Text(
        "${description["word"]} (${description["pos"]})",
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 15),
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
                  child: const Text("Not Found in Collegiate Dictionary!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  itemCount: descriptions.length * 2 - 1,
                  itemBuilder: (context, item) {
                    if (item.isOdd) {
                      return const Divider(
                          thickness: 3.0, color: Colors.orange);
                    }
                    final index = item ~/ 2;
                    return buildDictionaryDescription(descriptions[index]);
                  }));
    }));
  }

  void showThesaurusDescriptions(String word) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      final descriptions = globals.thesaurusCache[word];
      return Scaffold(
          appBar: AppBar(title: Text(word), centerTitle: true),
          body: descriptions == null
              ? Container(
                  alignment: Alignment.center,
                  child: const Text("Not Found in Collegiate Thesaurus!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  itemCount: descriptions.length * 2 - 1,
                  itemBuilder: (context, item) {
                    if (item.isOdd) {
                      return const Divider(
                          thickness: 3.0, color: Colors.orange);
                    }
                    final index = item ~/ 2;
                    return buildThesaurusDescription(descriptions[index]);
                  }));
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
    var descriptions = await dict_search.searchDictionary(word);
    globals.dictionaryCache[word] = descriptions;
    setState(() => loading = false);
    return globals.dictionaryCache[word];
  }

  dynamic sendWordToThesaurus(String word) async {
    setState(() => loading = true);
    var descriptions = await dict_search.searchThesaurus(word);
    globals.thesaurusCache[word] = descriptions;
    setState(() => loading = false);
    return globals.thesaurusCache[word];
  }

  Widget buildRow(String word, int index) {
    word = word.capitalize!;
    return ListTile(
        title: Text(word, style: const TextStyle(fontSize: 18.0)),
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
        appBar:
            AppBar(title: const Text('Dictionary Search'), centerTitle: true),
        body: loading
            ? globals.startProgressIndicator(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: globals.wordList!.length * 2,
                itemBuilder: (context, item) {
                  if (item.isOdd) return const Divider();
                  final index = item ~/ 2;
                  return buildRow(globals.wordList![index], index);
                }));
  }
}
