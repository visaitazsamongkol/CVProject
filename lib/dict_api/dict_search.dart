import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import "dict_key.dart" as key;
import "utils.dart" as utils;

dynamic searchThesaurus(String word) async {
  word = word.toLowerCase();
  var uri = Uri.https("www.dictionaryapi.com",
      "/api/v3/references/thesaurus/json/$word", {"key": key.thesaurusKey});
  var response = await http.get(uri);
  var dictionary = convert.jsonDecode(response.body);
  bool exactWordFound = false;
  var wordDicts = [];
  try {
    var allPos = [];
    for (var eachWord in dictionary) {
      if (utils.delNonAlphaEndings(eachWord['meta']['id']) == word) {
        exactWordFound = true;
        if (!allPos.contains(eachWord['fl'].toLowerCase())) {
          allPos.add(eachWord['fl'].toLowerCase());
          wordDicts.add(eachWord);
        }
      }
    }
  } catch (_) {
    return null;
  }

  if (!exactWordFound) {
    wordDicts.add(dictionary[0]);
  }

  // descriptions consist of description (result we get from word)
  var descriptions = [];
  for (var wordDict in wordDicts) {
    var description = {};

    if (exactWordFound) {
      description['word'] = word;
    } else {
      description['word'] = wordDict['meta']['id'];
    }

    // part-of-speech
    description['pos'] = wordDict['fl'];
    // stems (similar words) (list)
    description['stems'] = wordDict['meta']['stems'];
    // meanings (all meanings summary) (list)
    description['all_meanings'] = [];
    for (var meaning in wordDict['shortdef']) {
      description['all_meanings'].add(utils.manageBraces(meaning));
    }
    // definitions (meaning, example, syn, ant) (list)
    description['definitions'] = [];
    for (var divider in wordDict['def']) {
      var verbDivider = "";
      if (divider.keys.contains('vd')) {
        verbDivider = divider['vd'];
      }
      for (var senseSeq in divider['sseq']) {
        for (var sense in senseSeq) {
          if (sense[0] != 'sense') continue;
          sense = sense[1];
          var definition = {};

          definition['meaning'] = '';
          definition['examples'] = [];
          for (var dtElement in sense['dt']) {
            if (dtElement[0] == 'text') {
              definition['meaning'] = utils.manageBraces(dtElement[1]);
            } else if (dtElement[0] == 'vis') {
              for (var ex in dtElement[1]) {
                definition['examples'].add(utils.manageBraces(ex['t']));
              }
            }
          }

          if (utils.delNonAlphaEndings(definition['meaning']) == '') {
            continue;
          }

          definition['verb_divider'] = verbDivider;

          definition['categories'] = [];
          if (sense.keys.contains('sls')) {
            definition['categories'] = sense['sls'];
          }

          definition['synonyms'] = [];
          definition =
              utils.getDefinition('syn_list', 'synonyms', sense, definition);
          definition =
              utils.getDefinition('sim_list', 'synonyms', sense, definition);

          definition['synonymous_phrases'] = [];
          definition = utils.getDefinition(
              'phrase_list', 'synonymous_phrases', sense, definition);

          definition['antonyms'] = [];
          definition =
              utils.getDefinition('ant_list', 'antonyms', sense, definition);
          definition =
              utils.getDefinition('opp_list', 'antonyms', sense, definition);
          definition =
              utils.getDefinition('near_list', 'antonyms', sense, definition);

          description['definitions'].add(definition);
        }
      }
    }

    descriptions.add(description);
  }

  return descriptions;
}

dynamic searchDictionary(String word) async {
  word = word.toLowerCase();
  var uri = Uri.https("www.dictionaryapi.com",
      "/api/v3/references/collegiate/json/$word", {"key": key.dictionaryKey});
  var response = await http.get(uri);
  var dictionary = convert.jsonDecode(response.body);
  var wordDicts = [];
  bool exactWordFound = false;
  try {
    var allPos = [];
    for (var eachWord in dictionary) {
      if (utils.delNonAlphaEndings(eachWord['meta']['id']) == word) {
        exactWordFound = true;
        if (!allPos.contains(eachWord['fl'].toLowerCase())) {
          allPos.add(eachWord['fl'].toLowerCase());
          wordDicts.add(eachWord);
        }
      }
    }
  } catch (_) {
    return null;
  }

  if (!exactWordFound) {
    wordDicts.add(dictionary[0]);
  }

  var descriptions = [];
  for (var wordDict in wordDicts) {
    var description = {};

    if (exactWordFound) {
      description['word'] = word;
    } else {
      description['word'] = wordDict['meta']['id'];
    }

    // part-of-speech
    description['pos'] = wordDict['fl'];
    // stems (similar words) (list)
    description['stems'] = wordDict['meta']['stems'];
    // meanings (all meanings summary) (list)
    description['all_meanings'] = [];
    for (var meaning in wordDict['shortdef']) {
      description['all_meanings'].add(utils.manageBraces(meaning));
    }
    // definitions (meaning, example, syn, ant) (list)
    description['definitions'] = [];
    for (var divider in wordDict['def']) {
      var verbDivider = "";
      if (divider.keys.contains('vd')) {
        verbDivider = divider['vd'];
      }
      for (var senseSeq in divider['sseq']) {
        for (var sense in senseSeq) {
          if (sense[0] != 'sense') continue;
          sense = sense[1];
          var definition = {};

          definition['meaning'] = '';
          definition['examples'] = [];
          for (var dtElement in sense['dt']) {
            if (dtElement[0] == 'text') {
              definition['meaning'] = utils.manageBraces(dtElement[1]);
            } else if (dtElement[0] == 'vis') {
              for (var ex in dtElement[1]) {
                definition['examples'].add(utils.manageBraces(ex['t']));
              }
            }
          }

          if (utils.delNonAlphaEndings(definition['meaning']) == '') {
            continue;
          }

          definition['verb_divider'] = verbDivider;

          definition['categories'] = [];
          if (sense.keys.contains('sls')) {
            definition['categories'] = sense['sls'];
          }
          definition['closely_related_meaning'] = '';
          definition['closely_related_examples'] = [];
          if (sense.keys.contains('sdsense')) {
            for (var dtElement in sense['sdsense']['dt']) {
              if (dtElement[0] == 'text') {
                definition['closely_related_meaning'] =
                    utils.manageBraces(dtElement[1]);
              } else if (dtElement[0] == 'vis') {
                for (var ex in dtElement[1]) {
                  definition['closely_related_examples']
                      .add(utils.manageBraces(ex['t']));
                }
              }
            }
          }
          description['definitions'].add(definition);
        }
      }
    }

    // syllable division
    description['syllable'] = wordDict['hwi']['hw'];
    // audio link
    description['audio_links'] = [];
    if (wordDict['hwi'].keys.contains('prs')) {
      for (var soundObj in wordDict['hwi']['prs']) {
        if (soundObj.keys.contains('sound')) {
          var audioFilename = soundObj['sound']['audio'];
          var punctuations = '''[!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~]''';
          var audioSubdir = '';
          final digits = RegExp(r'[0-9]');
          if (audioFilename.startsWith('bix')) {
            audioSubdir = 'bix';
          } else if (audioFilename.startsWith('gg')) {
            audioSubdir = 'gg';
          } else if (punctuations.contains(audioFilename[0]) ||
              digits.hasMatch(audioFilename[0])) {
            audioSubdir = 'number';
          } else {
            audioSubdir = audioFilename[0];
          }
          description['audio_links'].add(
              'https://media.merriam-webster.com/audio/prons/en/us/mp3/$audioSubdir/$audioFilename.mp3');
        }
      }
    }
    descriptions.add(description);
  }
  return descriptions;
}
