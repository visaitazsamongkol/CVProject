import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:mdi/mdi.dart';
import './globals.dart' as globals;
import './dict_api/dict_search.dart' as dict_search;

class Dict extends StatefulWidget {
  @override
  State<Dict> createState() => _DictState();
}

class _DictState extends State<Dict> {
  bool loading = false;

  void showDictionaryDescription(String word) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      final descriptions = globals.dictionaryCache[word];
      return Scaffold(
          appBar: AppBar(title: Text(word), centerTitle: true),
          body: ListView(
            children: [
              Text(descriptions.toString()),
            ],
          ));
    }));
  }

  void showThesaurusDescription(String word) {
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
              onPressed: () async {
                if (!globals.dictionaryCache.containsKey(word)) {
                  await sendWordToDictionary(word);
                }
                showDictionaryDescription(word);
              }),
          IconButton(
              iconSize: 30.0,
              icon: const Icon(Mdi.alphaTBox),
              color: Colors.blue,
              onPressed: () async {
                if (!globals.thesaurusCache.containsKey(word)) {
                  await sendWordToThesaurus(word);
                }
                showThesaurusDescription(word);
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
