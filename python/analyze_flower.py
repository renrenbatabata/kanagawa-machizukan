from PIL import Image
import base64
import requests
from io import BytesIO

PLANT_ID_API_KEY = 'xFlElLSkIgWAwsLhJVZbvHeKYia3sIaHuZXYG8bRbOwUFnnCAV'

def analyze_flower(image):
    try:
        buffered = BytesIO()
        image.save(buffered, format="JPEG")
        buffered.seek(0)
        base64_image = base64.b64encode(buffered.getvalue()).decode('utf-8')

        response = requests.post(
            'https://plant.id/api/v3/identification',
            headers={'Content-Type': 'application/json'},
            json={
                'api_key': PLANT_ID_API_KEY,
                'images': [base64_image],
                'classification_level': 'species',
            }
        )

        if response.status_code != 200:
            return {
                'error': 'Plant.id APIでエラー',
                'status': response.status_code,
                'details': response.text
            }

        data = response.json()
        suggestions = data.get("result", {}).get("classification", {}).get("suggestions", [])
        if not suggestions:
            return {'error': 'お花を特定できませんでした'}

        best = suggestions[0]
        name = best.get('name')
        common_names = best.get('details', {}).get('common_names', [])
        entity_id = best.get('details', {}).get('entity_id')

        # 🌸 entity_idを使って追加情報を取得
        info_response = requests.get(
            f"https://api.plant.id/v2/info?entity_id={entity_id}&lang=ja",
            headers={
                'Content-Type': 'application/json',
                'Api-Key': PLANT_ID_API_KEY
            }
        )

        if info_response.status_code == 200:
            info_data = info_response.json()
            wiki_description = info_data.get('wiki_description', {}).get('value', '')
            more_common_names = info_data.get('common_names', [])
        else:
            wiki_description = "詳細情報の取得に失敗しました。"
            more_common_names = []

        return {
            'name': name,
            'common_names': common_names,
            'ja_common_names': more_common_names,
            'description': wiki_description
        }

    except Exception as e:
        return {'error': '処理中にエラーが発生しました', 'exception': str(e)}
