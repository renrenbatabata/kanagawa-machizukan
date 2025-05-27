// lib/data/quiz_data.dart

// クイズの1問を表現するクラス
class QuizQuestion {
  final String questionText; // 問題文
  final List<String> options; // 選択肢のリスト
  final int correctOptionIndex; // 正解の選択肢のインデックス (0から始まる)
  final String explanation; // 解説

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

// クイズ問題のリスト
// 今後、バックエンドから取得したり、より多くの問題を追加したりできます
List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    questionText: '横浜市神奈川区にある大きな公園の名前はなんでしょう？',
    options: ['横浜公園', '岸根公園', '三ツ池公園', '山下公園'],
    correctOptionIndex: 2, // 三ツ池公園
    explanation: '三ツ池公園は、3つの池がある神奈川区の大きな公園だよ。桜の名所としても有名だね！',
  ),
  QuizQuestion(
    questionText: '神奈川区の区役所があるのはどこでしょう？',
    options: ['東神奈川駅の近く', '横浜駅の近く', '新横浜駅の近く', '大口駅の近く'],
    correctOptionIndex: 0, // 東神奈川駅の近く
    explanation: '神奈川区役所は東神奈川駅から歩いてすぐの場所にあるよ。',
  ),
  QuizQuestion(
    questionText: '神奈川区の鳥はなんでしょう？',
    options: ['カモメ', 'ハト', 'ウグイス', 'オオタカ'],
    correctOptionIndex: 3, // オオタカ
    explanation: '神奈川区の鳥はオオタカだよ！自然豊かな場所にいるんだ。',
  ),
  QuizQuestion(
    questionText: '神奈川区のマスコットキャラクターの名前はなんでしょう？',
    options: ['かにゃお', 'カメ太郎', 'ハマちゅん', 'パンダ先生'],
    correctOptionIndex: 1, // カメ太郎
    explanation: '神奈川区のマスコットキャラクターは「カメ太郎」だよ！区内イベントで会えるかもね。',
  ),
  QuizQuestion(
    questionText: '神奈川区を流れている大きな川の名前はなんでしょう？',
    options: ['鶴見川', '帷子川', '大岡川', '境川'],
    correctOptionIndex: 0, // 鶴見川
    explanation: '神奈川区の東側を流れる大きな川は鶴見川だよ。多摩川と並んで大きな川だね。',
  ),
];
