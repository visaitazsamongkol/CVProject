import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import "dict_key.dart" as key;
import "utils.dart" as utils;

dynamic search_thesaurus(String word) async {
  word = word.toLowerCase();
  var uri = Uri.https("www.dictionaryapi.com",
      "/api/v3/references/thesaurus/json/${word}", {"key": key.thesaurus_key});
  var response = await http.get(uri);
  var dictionary = convert.jsonDecode(response.body);
  bool exact_word_found = false;
  var word_dicts = [];
  try {
    for (var each_word in dictionary) {
      if (utils.del_non_alpha_endings(each_word['meta']['id']) == word) {
        exact_word_found = true;
        word_dicts.add(each_word);
      }
    }
  } on Exception catch (_) {
    return null;
  }

  if (!exact_word_found) {
    word_dicts.add(dictionary[0]);
  }

  // descriptions consist of description (result we get from word)
  var descriptions = [];
  for (var word_dict in word_dicts) {
    var description = {};

    if (exact_word_found) {
      description['word'] = word;
    } else {
      description['word'] = word_dict['meta']['id'];
    }

    // part-of-speech
    description['pos'] = word_dict['fl'];
    // stems (similar words) (list)
    description['stems'] = word_dict['meta']['stems'];
    // meanings (all meanings summary) (list)
    description['all_meanings'] = [];
    for (var meaning in word_dict['shortdef']) {
      description['all_meanings'].add(utils.manage_braces(meaning));
    }
    // definitions (meaning, example, syn, ant) (list)
    description['definitions'] = [];
    for (var divider in word_dict['def']) {
      var verb_divider = "";
      if (divider.keys.contains('vd')) {
        verb_divider = divider['vd'];
      }
      for (var sense_seq in divider['sseq']) {
        for (var sense in sense_seq) {
          if (sense[0] != 'sense') continue;
          sense = sense[1];
          var definition = {};

          definition['meaning'] = '';
          definition['examples'] = [];
          for (var dt_element in sense['dt']) {
            if (dt_element[0] == 'text') {
              definition['meaning'] = utils.manage_braces(dt_element[1]);
            } else if (dt_element[0] == 'vis') {
              for (var ex in dt_element[1]) {
                definition['examples'].add(utils.manage_braces(ex['t']));
              }
            }
          }

          if (definition['meaning'] == '') continue;

          definition['verb_divider'] = verb_divider;

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

dynamic search_dictionary(String word) async {
  word = word.toLowerCase();
  var uri = Uri.https(
      "www.dictionaryapi.com",
      "/api/v3/references/collegiate/json/${word}",
      {"key": key.dictionary_key});
  var response = await http.get(uri);
  var dictionary = convert.jsonDecode(response.body);
  var word_dicts = [];
  bool exact_word_found = false;
  try {
    for (var each_word in dictionary) {
      if (utils.del_non_alpha_endings(each_word['meta']['id']) == word) {
        exact_word_found = true;
        word_dicts.add(each_word);
      }
    }
  } on Exception catch (_) {
    return null;
  }

  if (!exact_word_found) {
    word_dicts.add(dictionary[0]);
  }

  var descriptions = [];
  for (var word_dict in word_dicts) {
    var description = {};

    if (exact_word_found) {
      description['word'] = word;
    } else {
      description['word'] = word_dict['meta']['id'];
    }

    // part-of-speech
    description['pos'] = word_dict['fl'];
    // stems (similar words) (list)
    description['stems'] = word_dict['meta']['stems'];
    // meanings (all meanings summary) (list)
    description['all_meanings'] = [];
    for (var meaning in word_dict['shortdef']) {
      description['all_meanings'].add(utils.manage_braces(meaning));
    }
    // definitions (meaning, example, syn, ant) (list)
    description['definitions'] = [];
    for (var divider in word_dict['def']) {
      var verb_divider = "";
      if (divider.keys.contains('vd')) {
        verb_divider = divider['vd'];
      }
      for (var sense_seq in divider['sseq']) {
        for (var sense in sense_seq) {
          if (sense[0] != 'sense') continue;
          sense = sense[1];
          var definition = {};

          definition['meaning'] = '';
          definition['examples'] = [];
          for (var dt_element in sense['dt']) {
            if (dt_element[0] == 'text') {
              definition['meaning'] = utils.manage_braces(dt_element[1]);
            } else if (dt_element[0] == 'vis') {
              for (var ex in dt_element[1]) {
                definition['examples'].add(utils.manage_braces(ex['t']));
              }
            }
          }

          if (definition['meaning'] == '') continue;

          definition['verb_divider'] = verb_divider;

          definition['categories'] = [];
          if (sense.keys.contains('sls')) {
            definition['categories'] = sense['sls'];
          }
          definition['closely_related_meaning'] = '';
          definition['closely_related_examples'] = [];
          if (sense.keys.contains('sdsense')) {
            for (var dt_element in sense['sdsense']['dt']) {
              if (dt_element[0] == 'text') {
                definition['closely_related_meaning'] =
                    utils.manage_braces(dt_element[1]);
              } else if (dt_element[0] == 'vis') {
                for (var ex in dt_element[1]) {
                  definition['closely_related_examples']
                      .add(utils.manage_braces(ex['t']));
                }
              }
            }
          }
          description['definitions'].add(definition);
        }
      }
    }

    // syllable division
    description['syllable'] = word_dict['hwi']['hw'];
    // audio link
    description['audio_links'] = [];
    if (word_dict['hwi'].keys.contains('prs')) {
      for (var sound_obj in word_dict['hwi']['prs']) {
        if (sound_obj.keys.contains('sound')) {
          var audio_filename = sound_obj['sound']['audio'];
          var punctuations = '''[!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~]''';
          var audio_subdir = '';
          final digits = RegExp(r'[0-9]');
          if (audio_filename.startsWith('bix')) {
            audio_subdir = 'bix';
          } else if (audio_filename.startsWith('gg')) {
            audio_subdir = 'gg';
          } else if (punctuations.contains(audio_filename[0]) ||
              digits.hasMatch(audio_filename[0])) {
            audio_subdir = 'number';
          } else {
            audio_subdir = audio_filename[0];
          }
          description['audio_links'].add(
              'https://media.merriam-webster.com/audio/prons/en/us/mp3/${audio_subdir}/${audio_filename}.mp3');
        }
      }
    }
    descriptions.add(description);
  }
  return descriptions;
}
