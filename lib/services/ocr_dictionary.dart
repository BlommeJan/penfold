import 'dart:math' as math;

/// Post-processes ML Kit OCR output using a user-defined glossary.
///
/// ML Kit Latin script has no custom-word hints, so we fuzzy-match tokens
/// against stored terms and substitute close matches before indexing.
String applyOcrDictionary(String text, List<String> terms) {
  final trimmed = text.trim();
  if (trimmed.isEmpty || terms.isEmpty) return text;

  final glossary = <String, String>{};
  for (final raw in terms) {
    final term = raw.trim();
    if (term.isEmpty) continue;
    glossary[term.toLowerCase()] = term;
  }
  if (glossary.isEmpty) return text;

  return text.replaceAllMapped(RegExp(r'[A-Za-z0-9]+'), (match) {
    final word = match.group(0)!;
    final lower = word.toLowerCase();
    if (glossary.containsKey(lower)) return glossary[lower]!;

    String? bestTerm;
    var bestScore = 0.0;
    for (final entry in glossary.entries) {
      final term = entry.key;
      if ((lower.length - term.length).abs() > 2) continue;
      final dist = _levenshtein(lower, term);
      final maxLen = math.max(lower.length, term.length);
      if (maxLen == 0) continue;
      final score = 1.0 - dist / maxLen;
      if (score >= 0.75 && score > bestScore) {
        bestScore = score;
        bestTerm = entry.value;
      }
    }
    return bestTerm ?? word;
  });
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 0; i < a.length; i++) {
    var corner = prev[0];
    prev[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final upperLeft = corner;
      corner = prev[j + 1];
      final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
      prev[j + 1] = math.min(
        math.min(prev[j] + 1, prev[j + 1] + 1),
        upperLeft + cost,
      );
    }
  }
  return prev[b.length];
}
