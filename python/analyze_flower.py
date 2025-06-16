# analyze_flower.py

from openai import OpenAI
import base64
import os
import unicodedata
from PIL import Image
import io # PIL.Imageをバイトデータに変換するために必要

client = OpenAI()

# KNOWN_PLANT_NAMES は外部から渡されるため、このファイルからは削除されています。
# デバッグ用の main ブロックもコメントアウトまたは削除してください。

def encode_image_from_pil(image_pil):
    """PIL ImageオブジェクトをBase64形式にエンコードする関数"""
    buffered = io.BytesIO()
    image_pil.save(buffered, format="JPEG") # JPEG形式で保存
    return base64.b64encode(buffered.getvalue()).decode('utf-8')

# ★ known_plant_names を引数として受け取るように変更されています
def analyze_flower(image_pil: Image.Image, known_plant_names: list):
    """
    PIL Imageオブジェクトと既知の植物名のリストを受け取り、OpenAI APIで植物名を分析し、
    提供されたリストと照合して結果を返す関数。
    """
    base64_image = encode_image_from_pil(image_pil)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "What is the common English name of the plant in this image? Provide only the common name, no other information like scientific name, detailed features, or care instructions. Keep it very concise."},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}"
                            },
                        },
                    ],
                }
            ],
            max_tokens=10,
        )
        plant_name_from_api_raw = response.choices[0].message.content.strip()

        normalized_api_name = plant_name_from_api_raw.lower()

        found_matched_name = None
        for known_name in known_plant_names: # ★引数で受け取ったリストを使用
            normalized_known_name = unicodedata.normalize('NFKC', known_name).lower()

            if normalized_known_name in normalized_api_name or \
               normalized_api_name in normalized_known_name:
                found_matched_name = known_name
                break

        if found_matched_name:
            return {"status": "success", "identified_plant": found_matched_name, "api_raw_result": plant_name_from_api_raw}
        else:
            return {"status": "success", "identified_plant": "Not found in list", "api_raw_result": plant_name_from_api_raw}

    except Exception as e:
        return {"status": "error", "message": f"画像分析中にエラーが発生しました: {str(e)}"}
# このファイル単体でテストしたい場合は、以下のコメントを解除して実行してください
# if __name__ == "__main__":
#     # テスト用の画像ファイルを指定
#     test_image_path = "path/to/your/test_flower.jpg" # ←テストしたい画像のパスに置き換え
#     if os.path.exists(test_image_path):
#         test_image_pil = Image.open(test_image_path)
#         result = analyze_flower(test_image_pil)
#         print(result)
#     else:
#         print(f"テスト画像 '{test_image_path}' が見つかりません。")


# from PIL import Image
# import base64
# import requests
# from io import BytesIO
# import deepl

# PLANT_ID_API_KEY = '4FQkwl4wqam7HyHygEDYLreoklMohFmjl8S5y8k8SpGHWnE4Wm'
# DEEPL_API_KEY= '222ede1e-56bc-4131-a900-4dc437e2efdb:fx'  # DeepL APIキーを指定してください


# def analyze_flower(image):
#     try:
#         buffered = BytesIO()
#         image.save(buffered, format="JPEG")
#         buffered.seek(0)
#         base64_image = base64.b64encode(buffered.getvalue()).decode('utf-8')

#         response = requests.post(
#             'https://plant.id/api/v3/identification',
#             headers={'Content-Type': 'application/json'},
#             json={
#                 'api_key': PLANT_ID_API_KEY,
#                 'images': [base64_image],
#                 'classification_level': 'species',
#             }
#         )

#         if response.status_code not in [200, 201]:
#             return {
#                 'error': 'Plant.id APIでエラー',
#                 'status': response.status_code,
#                 'details': response.text
#             }

#         data = response.json()
#         suggestions = data.get("result", {}).get("classification", {}).get("suggestions", [])
#         access_token = response.json().get("access_token")

#         if not suggestions:
#             return {'error': 'お花を特定できませんでした'}

#         best = suggestions[0]
#         # name_en = best.get('name')


#         info_response = requests.get(
#             f'https://plant.id/api/v3/identification/{access_token}',
#             headers={'Content-Type': 'application/json',
#                      'Api-Key': PLANT_ID_API_KEY},
#             params={
#             'lang': 'ja',
#             'details': 'common_names,description,wiki_description,taxonomy,synonyms'
#         }
#         )

#         if info_response.status_code == 200:
#             info_data = info_response.json()

#             name_en = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('common_names')[1]
#             print(name_en)


#             common_names = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('common_names')


#             taxonomy = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('taxonomy')

#             description = info_data.get('result').get('classification').get('suggestions')[0].get('details').get('description').get('value')
#         elif info_response.status_code == 404:
#             return {
#                 'error': 'お花の情報が見つかりませんでした',
#                 'status': info_response.status_code,
#                 'details': info_response.text
#             }
#         else:
#             return {
#                 'error': 'Plant.id APIでエラー',
#                 'status': info_response.status_code,
#                 'details': info_response.text
#             }

#         deepl_client = deepl.DeepLClient(DEEPL_API_KEY)

#         name_jp = deepl_client.translate_text(name_en, target_lang='JA').text

#         # common_names = deepl_client.translate_text(common_names, target_lang='JA').text
#         description = deepl_client.translate_text(description, target_lang='JA').text

#         # taxonomyの情報を取得
#         # flower_class = taxonomy.get('class')
#         genius = taxonomy.get('genus')
#         family = taxonomy.get('family')
#         # flower_order = taxonomy.get('order')
#         # flower_kingdom = taxonomy.get('kingdom')
#         # flower_phylum = taxonomy.get('phylum')
#         # flower_common_name = taxonomy.get('common_name')

#         # taxonomyの情報を日本語に翻訳
#         # flower_class = deepl_client.translate_text(flower_class, target_lang='JA').text
#         genius = deepl_client.translate_text(genius, target_lang='JA').text
#         family = deepl_client.translate_text(family, target_lang='JA').text

#         # flower_order = deepl_client.translate_text(flower_order, target_lang='JA').text
#         # flower_kingdom = deepl_client.translate_text(flower_kingdom, target_lang='JA').text
#         # flower_phylum = deepl_client.translate_text(flower_phylum, target_lang='JA').text


#         # taxonomyの情報を辞書にまとめる
#         # taxonomy = {
#         #     'class': flower_class,
#         #     'genus': flower_genus,
#         #     'family': flower_family,
#         #     'order': flower_order,
#         #     'kingdom': flower_kingdom,
#         #     'phylum': flower_phylum,
#         # }


# #   final String imagePath;
# #   final String name;
# #   final String family;
# #   final String genius;
# #   final String meaning;
# #   final String description;
#         return {
#             'common_names':common_names,
#             'name_en':name_en,
#             'name_jp': name_jp,
#             'family': family,
#             'genius': genius,
#             'description': description,
#         }

#     except Exception as e:
#         return {'error': '処理中にエラーが発生しました', 'exception': str(e)}