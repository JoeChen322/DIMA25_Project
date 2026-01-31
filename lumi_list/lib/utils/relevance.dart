int relevanceScore(String title, String query) {
  final t = title.toLowerCase().trim();
  final q = query.toLowerCase().trim();

  int score = 0;

  // total equal
  if (t == q) {
    score += 5000;
  }

  // begin with
  else if (t.startsWith(q)) {
    score += 1000;
  }

  // whole word matc
  final wordRegex = RegExp(r'\b' + RegExp.escape(q) + r'\b');
  if (wordRegex.hasMatch(t)) {
    score += 200;
  }

  // 4contain
  if (t.contains(q)) {
    score += 100;
  }

  // better if title is shorter
  score -= t.length*2;

  return score;
}
