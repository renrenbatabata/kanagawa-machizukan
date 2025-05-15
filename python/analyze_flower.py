from PIL import Image
import base64
import requests
from io import BytesIO

PLANT_ID_API_KEY = '2u3gJlVhuqMQ7c83BWUUSnTwG3FLVwdRvlErn6gUGGOPFa1B1K'

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

        if response.status_code not in [200, 201]:
            return {
                'error': 'Plant.id APIでエラー',
                'status': response.status_code,
                'details': response.text
            }

        data = response.json()
        suggestions = data.get("result", {}).get("classification", {}).get("suggestions", [])
        access_token = response.json().get("access_token")

        if not suggestions:
            return {'error': 'お花を特定できませんでした'}

        best = suggestions[0]
        name = best.get('name')


        info_response = requests.get(
            f'https://plant.id/api/v3/identification/{access_token}',
            headers={'Content-Type': 'application/json',
                     'Api-Key': PLANT_ID_API_KEY},
            params={
            'lang': 'ja',
            'details': 'common_names,description,wiki_description,taxonomy,synonyms'
        }
        )

        if info_response.status_code == 200:
            info_data = info_response.json()

            common_names = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('common_names')[0]

            taxonomy = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('taxonomy')

            description = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('description')
        elif info_response.status_code == 404:
            return {
                'error': 'お花の情報が見つかりませんでした',
                'status': info_response.status_code,
                'details': info_response.text
            }
        else:
            return {
                'error': 'Plant.id APIでエラー',
                'status': info_response.status_code,
                'details': info_response.text
            }
        return {
            'name': name,
            'common_names': common_names,
            'taxonomy': taxonomy,
            'description': description,
        }

    except Exception as e:
        return {'error': '処理中にエラーが発生しました', 'exception': str(e)}
