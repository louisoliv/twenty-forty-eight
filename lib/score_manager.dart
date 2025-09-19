import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static Future<bool> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('best_score') ?? 0;

    if (score > currentBest) {
      await prefs.setInt('best_score', score);
      return true; // New record
    }
    return false;
  }

  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('best_score') ?? 0;
  }
}
