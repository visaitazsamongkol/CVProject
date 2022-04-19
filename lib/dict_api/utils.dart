dynamic getDefinition(
    String key, String target_key, var sense, var definition) {
  if (sense.keys.contains(key)) {
    for (var sim_group in sense[key]) {
      for (var sim in sim_group) {
        var synonym = sim['wd'];
        if (sim.keys.contains('wvrs')) {
          for (var sub_word in sim['wvrs']) {
            synonym += '/' + sub_word['wva'];
          }
        }
        if (sim.keys.contains('wvbvrs')) {
          for (var subword in sim['wvbvrs']) {
            synonym += '/' + subword['wvbva'];
          }
        }
        definition[target_key].add(synonym);
      }
    }
  }
  return definition;
}

String manage_braces(String text) {
  var del_index = [];
  var is_in_brace = false;
  var is_field = false;
  var is_field_count_change = false;
  var field_count = 0;
  var last_special_char = '';
  var last_field_seperator_index = 999999;
  var first_field_separator_index = 999999;
  for (var i = 0; i < text.length; i++) {
    if (text[i] == '{') {
      is_in_brace = true;
      is_field = false;
      is_field_count_change = false;
      last_special_char = text[i];
      del_index.add(i);
    } else if (text[i] == '}') {
      is_in_brace = false;
      is_field = false;
      is_field_count_change = true;
      field_count = 0;
      last_special_char = text[i];
      del_index.add(i);
    } else if (text[i] == '|') {
      is_field = true;
      is_field_count_change = true;
      field_count += 1;
      if (last_special_char == '{') {
        first_field_separator_index = i;
      }
      last_special_char = text[i];
      last_field_seperator_index = i;
      if (field_count >= 3) {
        for (var j = first_field_separator_index + 1;
            j < last_field_seperator_index;
            j++) {
          if (!del_index.contains(j)) {
            del_index.add(j);
          }
        }
      }
      del_index.add(i);
    } else {
      if (!is_in_brace) {
        is_field_count_change = false;
      } else if (is_in_brace && !is_field) {
        is_field_count_change = false;
        del_index.add(i);
      } else if (is_in_brace && is_field) {
        if (field_count < 2) {
          is_field_count_change = false;
        } else if (field_count == 2) {
          if (is_field_count_change) {
            for (var j = first_field_separator_index + 1;
                j < last_field_seperator_index;
                j++) {
              if (!del_index.contains(j)) {
                del_index.add(j);
              }
            }
            is_field_count_change = false;
          }
        } else {
          is_field_count_change = false;
          del_index.add(i);
        }
      }
    }
  }

  var result = [];
  for (int i = 0; i < text.length; i++) {
    result.add(text[i]);
  }
  var num_adjacent_space = 0;
  for (int i = 0; i < result.length; i++) {
    if (del_index.contains(i)) {
      result[i] = '';
    } else if (result[i] == ' ') {
      num_adjacent_space += 1;
      if (num_adjacent_space >= 2) {
        result[i] = '';
      }
    } else {
      num_adjacent_space = 0;
    }
  }

  var ans = "";

  for (var x in result) {
    ans += x;
  }
  return ans.trim();
}

String del_non_alpha_endings(String word) {
  String result = word;
  final validCharacters = RegExp(r'[a-zA-Z]');
  for (var i = word.length - 1; i >= 0; i--) {
    if (!validCharacters.hasMatch(word[i])) {
      result = result.substring(0, result.length - 1);
    }
  }
  return result.toLowerCase();
}
