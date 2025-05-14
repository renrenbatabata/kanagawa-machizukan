from flask import Flask, request, jsonify
from PIL import Image

app = Flask(__name__)

@app.route('/analyze', methods=['POST'])
def analyze():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    file = request.files['image']
    image = Image.open(file.stream)

    category = request.form.get('category')
    width, height = image.size  # 仮処理として画像サイズ取得

    if category == 'flower':
        result = {
            'category': 'flower',
            'message': '花の処理をしました',
            'image_width': width,
            'image_height': height
        }
    elif category == 'shrine':
        result = {
            'category': 'shrine',
            'message': '神社の処理をしました',
            'image_width': width,
            'image_height': height
        }
    elif category == 'turtle':
        result = {
            'category': 'turtle',
            'message': 'カメの処理をしました',
            'image_width': width,
            'image_height': height
        }
    else:
        result = {'error': '未対応のカテゴリです'}

    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
