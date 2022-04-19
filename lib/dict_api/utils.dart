dynamic getDefinition(String key, String targetKey, var sense, var definition) {
  if (sense.keys.contains(key)) {
    for (var simGroup in sense[key]) {
      for (var sim in simGroup) {
        var synonym = sim['wd'];
        if (sim.keys.contains('wvrs')) {
          for (var subWord in sim['wvrs']) {
            synonym += '/' + subWord['wva'];
          }
        }
        if (sim.keys.contains('wvbvrs')) {
          for (var subword in sim['wvbvrs']) {
            synonym += '/' + subword['wvbva'];
          }
        }
        definition[targetKey].add(synonym);
      }
    }
  }
  return definition;
}

String manageBraces(String text) {
  var delIndex = [];
  var isInBrace = false;
  var isField = false;
  var isFieldCountChange = false;
  var fieldCount = 0;
  var lastSpecialChar = '';
  var lastFieldSeperatorIndex = 999999;
  var firstFieldSeparatorIndex = 999999;
  for (var i = 0; i < text.length; i++) {
    if (text[i] == '{') {
      isInBrace = true;
      isField = false;
      isFieldCountChange = false;
      lastSpecialChar = text[i];
      delIndex.add(i);
    } else if (text[i] == '}') {
      isInBrace = false;
      isField = false;
      isFieldCountChange = true;
      fieldCount = 0;
      lastSpecialChar = text[i];
      delIndex.add(i);
    } else if (text[i] == '|') {
      isField = true;
      isFieldCountChange = true;
      fieldCount += 1;
      if (lastSpecialChar == '{') {
        firstFieldSeparatorIndex = i;
      }
      lastSpecialChar = text[i];
      lastFieldSeperatorIndex = i;
      if (fieldCount >= 3) {
        for (var j = firstFieldSeparatorIndex + 1;
            j < lastFieldSeperatorIndex;
            j++) {
          if (!delIndex.contains(j)) {
            delIndex.add(j);
          }
        }
      }
      delIndex.add(i);
    } else {
      if (!isInBrace) {
        isFieldCountChange = false;
      } else if (isInBrace && !isField) {
        isFieldCountChange = false;
        delIndex.add(i);
      } else if (isInBrace && isField) {
        if (fieldCount < 2) {
          isFieldCountChange = false;
        } else if (fieldCount == 2) {
          if (isFieldCountChange) {
            for (var j = firstFieldSeparatorIndex + 1;
                j < lastFieldSeperatorIndex;
                j++) {
              if (!delIndex.contains(j)) {
                delIndex.add(j);
              }
            }
            isFieldCountChange = false;
          }
        } else {
          isFieldCountChange = false;
          delIndex.add(i);
        }
      }
    }
  }

  var result = [];
  for (int i = 0; i < text.length; i++) {
    result.add(text[i]);
  }
  var numAdjacentSpace = 0;
  for (int i = 0; i < result.length; i++) {
    if (delIndex.contains(i)) {
      result[i] = '';
    } else if (result[i] == ' ') {
      numAdjacentSpace += 1;
      if (numAdjacentSpace >= 2) {
        result[i] = '';
      }
    } else {
      numAdjacentSpace = 0;
    }
  }

  var ans = "";

  for (var x in result) {
    ans += x;
  }
  return ans.trim();
}

String delNonAlphaEndings(String word) {
  String result = word;
  final validCharacters = RegExp(r'[a-zA-Z]');
  for (var i = word.length - 1; i >= 0; i--) {
    if (!validCharacters.hasMatch(word[i])) {
      result = result.substring(0, result.length - 1);
    }
  }
  return result.toLowerCase();
}
