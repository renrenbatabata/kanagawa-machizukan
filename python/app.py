from flask import Flask, request, jsonify
from PIL import Image

# 各カテゴリの処理をインポート
from analyze_flower import analyze_flower
from analyze_shrine import analyze_shrine
from analyze_turtle import analyze_turtle

app = Flask(__name__)

@app.route('/app', methods=['POST'])
def analyze():
    # 画像がない場合
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    # 画像ファイルを読み込み
    file = request.files['image']
    image = Image.open(file.stream)

    # カテゴリの取得
    category = request.form.get('category')

    if not category:
        return jsonify({'error': 'カテゴリが指定されていません'}), 400

    # カテゴリに基づいて処理
    if category == 'flower':
        result = analyze_flower(image)
    elif category == 'shrine':
        result = analyze_shrine(image)
    elif category == 'turtle':
        result = analyze_turtle(image)
    else:
        return jsonify({'error': '未対応のカテゴリです'}), 400

    # 結果を返す
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
