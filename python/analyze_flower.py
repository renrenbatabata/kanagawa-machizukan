from PIL import Image
import base64
import requests
from io import BytesIO
import deepl

PLANT_ID_API_KEY = 'ecJO6G6Ca0hYv1TaNYuXaYfZFOfTdwlfRzFYUmEOu0PaXkX3JZ'
DEEPL_API_KEY= '222ede1e-56bc-4131-a900-4dc437e2efdb:fx'  # DeepL APIキーを指定してください


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

            description = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('description').get('value')
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

        deepl_client = deepl.DeepLClient(DEEPL_API_KEY)
        name = deepl_client.translate_text(name, target_lang='JA').text
        common_names = deepl_client.translate_text(common_names, target_lang='JA').text
        description = deepl_client.translate_text(description, target_lang='JA').text

        # taxonomyの情報を取得
        flower_class = taxonomy.get('class')
        flower_genus = taxonomy.get('genus')
        flower_family = taxonomy.get('family')
        flower_order = taxonomy.get('order')
        flower_kingdom = taxonomy.get('kingdom')
        flower_phylum = taxonomy.get('phylum')
        flower_common_name = taxonomy.get('common_name')

        # taxonomyの情報を日本語に翻訳
        flower_class = deepl_client.translate_text(flower_class, target_lang='JA').text
        flower_genus = deepl_client.translate_text(flower_genus, target_lang='JA').text
        flower_family = deepl_client.translate_text(flower_family, target_lang='JA').text
        flower_order = deepl_client.translate_text(flower_order, target_lang='JA').text
        flower_kingdom = deepl_client.translate_text(flower_kingdom, target_lang='JA').text
        flower_phylum = deepl_client.translate_text(flower_phylum, target_lang='JA').text


        # taxonomyの情報を辞書にまとめる
        taxonomy = {
            'class': flower_class,
            'genus': flower_genus,
            'family': flower_family,
            'order': flower_order,
            'kingdom': flower_kingdom,
            'phylum': flower_phylum,
        }

        return {
            'name': name,
            'common_names': common_names,
            'taxonomy': taxonomy,
            'description': description,
        }

    except Exception as e:
        return {'error': '処理中にエラーが発生しました', 'exception': str(e)}
