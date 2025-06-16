from openai import OpenAI
import base64
import os
import unicodedata # カタカナの正規化は不要になりますが、念のため残しておきます。

# OpenAIクライアントの初期化
# APIキーは環境変数「OPENAI_API_KEY」から自動的に読み込まれます。
# 環境変数の設定がうまくいかない場合は、
# client = OpenAI(api_key="sk-YOUR_API_KEY_HERE") のように直接記述も可能ですが、非推奨です。
client = OpenAI()

def encode_image(image_path):
    """画像をBase64形式にエンコードする関数"""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def analyze_plant_image(image_path):
    """植物画像を分析し、情報を取得する関数"""
    base64_image = encode_image(image_path)

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "user",
                    "content": [
                        # ★ここを英語名で返すように変更しました！
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
            max_tokens=10, # 英語名は短いことが多いので、さらにmax_tokensを短縮
        )
        return response.choices[0].message.content.strip() # 余分な空白を除去
    except Exception as e:
        return f"画像分析中にエラーが発生しました: {e}"

if __name__ == "__main__":
    # ここに分析したい画像ファイルのパスを指定してください
    image_file_path = "plant_image.png" # ★あなたの画像ファイルの正確なパスを入力してください！

    # ★確認したいお花の名前のリストを英語でここに設定してください。
    # APIの応答の揺らぎを考慮し、リストには一般的な英語名称を登録することをお勧めします。
    known_plant_names = [
        "calendula","Carnation","Marigold"
    ]

    if not os.path.exists(image_file_path):
        print(f"エラー: 指定された画像ファイル '{image_file_path}' が見つかりません。パスを確認してください。")
    else:
        print(f"画像 '{image_file_path}' の分析を開始します...")

        # 植物の名前をAPIから取得
        plant_name_from_api_raw = analyze_plant_image(image_file_path)

        print(f"\n--- API分析生結果 ---")
        print(f"APIが識別した植物名（生データ）: {plant_name_from_api_raw}")
        print(f"--------------------")

        # APIからの結果がエラーメッセージの場合
        if "画像分析中にエラーが発生しました" in plant_name_from_api_raw:
            print(f"\nエラーのため、リストとの照合は行いませんでした。")
        else:
            # APIの応答とリスト内の名前を小文字化して比較することで、大文字小文字の違いを吸収
            # 英語なのでunicodedata.normalize('NFKC')は通常不要ですが、念のため残しておきます。
            normalized_api_name = plant_name_from_api_raw.lower()

            found_matched_name = None
            for known_name in known_plant_names:
                normalized_known_name = known_name.lower()

                # APIの応答がリストの名前を「含む」か、リストの名前がAPIの応答を「含む」場合をチェック
                # 例: APIが「French Marigold」と返しても、リストに「Marigold」があればヒット
                if normalized_known_name in normalized_api_name or \
                   normalized_api_name in normalized_known_name:
                    found_matched_name = known_name # 見つかった場合はリスト内の元の名前を保持
                    break

            print(f"\n--- リスト照合結果 ---")
            if found_matched_name:
                print(f"リストに一致する植物が見つかりました: {found_matched_name}")
            else:
                print(f"リストに一致する植物は見つかりませんでした。")
            print("--------------------")