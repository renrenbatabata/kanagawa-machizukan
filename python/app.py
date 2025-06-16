from flask import Flask, request, jsonify
from PIL import Image
import io
import json # JSONボディをパースするために必要

# 各カテゴリの処理をインポート
from analyze_flower import analyze_flower
from analyze_shrine import analyze_shrine
from analyze_turtle import analyze_turtle

app = Flask(__name__)

@app.route('/app', methods=['POST'])
def analyze():
    # 画像ファイルは request.files から取得
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    file = request.files['image']
    image_pil = Image.open(io.BytesIO(file.read()))

    # カテゴリは request.form から取得
    category = request.form.get('category')
    if not category:
        return jsonify({'error': 'カテゴリが指定されていません'}), 400

    # カテゴリに基づいて処理

    if category == 'flower':
        flowers_list_json_str = request.form.get('flowersList')
        flowers_list_from_request = []

        if flowers_list_json_str:
            try:
                flowers_list_from_request = json.loads(flowers_list_json_str)
                if not isinstance(flowers_list_from_request, list):
                    return jsonify({'error': '花のリスト（flowersList）が無効な形式です。リストを指定してください。'}), 400
            except json.JSONDecodeError:
                return jsonify({'error': '花のリスト（flowersList）のJSON形式が不正です'}), 400

        if not flowers_list_from_request:
            return jsonify({'error': '花のリスト（flowerslist）が提供されていないか、空です'}), 400

        # analyze_flower関数にPIL Imageオブジェクトとリストを渡します
        raw_result = analyze_flower(image_pil, flowers_list_from_request) # 結果をraw_resultとして受け取る

        # ★ここから変更点★
        # raw_result から 'identified_plant' の値を取り出し、JSON形式で返す
        if raw_result['status'] == 'success':
            identified_plant_name = raw_result['identified_plant']
            # {"nama_en": "Marigold"} の形式で返す
            return jsonify({"nama_en": identified_plant_name})
        else:
            # analyze_flowerでエラーが発生した場合は、そのエラーメッセージをそのまま返す
            return jsonify(raw_result), 500 # サーバーエラーとして500ステータスコードを返す
        # ★ここまで変更点★

    elif category == 'shrine':
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')
        if not latitude or not longitude:
            return jsonify({'error': '位置情報が必要です'}), 400

        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            return jsonify({'error': '位置情報が無効です'}), 400

        result = analyze_shrine(image_pil, latitude, longitude)
        return jsonify(result)

    elif category == 'turtle':
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')
        if not latitude or not longitude:
            return jsonify({'error': '位置情報が必要です'}), 400

        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            return jsonify({'error': '位置情報が無効です'}), 400

        result = analyze_turtle(image_pil, latitude, longitude)
        return jsonify(result)

    else:
        return jsonify({'error': '未対応のカテゴリです'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)