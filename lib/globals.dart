library dictionary_search_ocr_client.globals;

import 'package:flutter/material.dart';

List<String>? wordList;
Map<String, dynamic> dictionaryCache = {};
Map<String, dynamic> thesaurusCache = {};

Container startProgressIndicator(BuildContext context) {
  return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
          backgroundColor: Colors.lightGreen,
          strokeWidth: 20,
        ),
        height: MediaQuery.of(context).size.width * 0.3,
        width: MediaQuery.of(context).size.width * 0.3,
      ));
}
