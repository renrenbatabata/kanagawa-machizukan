import requests
import json
import os

# 送信する画像ファイルのパス
IMAGE_PATH = "plant_image.png"

# 送信する花のリスト
FLOWERS_LIST = ["Marigold", "calendula", "Carnation"]

# FlaskアプリのエンドポイントURL
FLASK_APP_URL = "http://localhost:5000/app"

def send_flower_analysis_request():
    if not os.path.exists(IMAGE_PATH):
        print(f"エラー: 画像ファイル '{IMAGE_PATH}' が見つかりません。")
        return

    print(f"画像 '{IMAGE_PATH}' を使ってリクエストを送信します...")

    # 画像ファイルをバイナリモードで開く
    with open(IMAGE_PATH, 'rb') as f:
        image_data = f.read()

    # multipart/form-data の 'files' 部分
    files = {
        'image': (IMAGE_PATH, image_data, 'image/png') # ファイル名, データ, Content-Type
    }

    # multipart/form-data の 'data' 部分
    data = {
        'category': 'flower',
        # flowerslist は JSON文字列として渡す
        'flowerslist': json.dumps(FLOWERS_LIST)
    }

    try:
        # POSTリクエストを送信
        response = requests.post(FLASK_APP_URL, files=files, data=data)
        response.raise_for_status() # HTTPエラーが発生した場合に例外を発生させる

        print("\n--- レスポンス ---")
        print(response.json())
        print("------------------")

    except requests.exceptions.ConnectionError as e:
        print(f"エラー: Flaskサーバーに接続できません。サーバーが起動しているか確認してください。: {e}")
    except requests.exceptions.RequestException as e:
        print(f"リクエスト中にエラーが発生しました: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"サーバーからのエラー詳細: {e.response.text}")
    except json.JSONDecodeError:
        print(f"エラー: サーバーからのレスポンスがJSON形式ではありません。\n生レスポンス: {response.text}")

if __name__ == "__main__":
    send_flower_analysis_request()