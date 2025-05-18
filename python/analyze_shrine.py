import googlemaps
from dotenv import load_dotenv
import os
from math import radians, cos, sin, sqrt, atan2

def calculate_distance(lat1, lon1, lat2, lon2):
    """2点間の距離をキロメートルで返す"""
    R = 6371  # 地球の半径（km）
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# 環境変数からAPIキーを読み込む
load_dotenv()
API_KEY = os.getenv("GOOGLE_MAPS_API_KEY", "Your_API_Key_Here")  # 環境変数を使用

def analyze_shrine(image, latitude, longitude):
    """現在地と画像から神社情報を取得し、結果を整形して返す"""
    if not API_KEY:
        return {'error': 'Google Maps APIキーが設定されていません'}

    gmaps = googlemaps.Client(key=API_KEY)
    location = (latitude, longitude)

    try:
        result = gmaps.places_nearby(
            location=location,
            radius=2000,
            type='point_of_interest',
            keyword='神社',
            language='ja'
        )
    except Exception as e:
        return {'error': f'Google Maps APIリクエスト中にエラーが発生しました: {str(e)}'}

    # 最も近い神社を探す
    closest_shrine = None
    min_distance = float('inf')

    for place in result.get('results', []):
        shrine_lat = place['geometry']['location']['lat']
        shrine_lon = place['geometry']['location']['lng']
        distance = calculate_distance(latitude, longitude, shrine_lat, shrine_lon)

        if distance < min_distance:
            min_distance = distance
            closest_shrine = {
                'name': place.get('name', '名前不明'),
                'latitude': shrine_lat,
                'longitude': shrine_lon,
                'address': place.get('vicinity', '住所不明'),
                'distance': distance,
                'place_id': place.get('place_id')
            }

    if closest_shrine:
        # Place Details APIから説明を取得
        place_id = closest_shrine.get('place_id')

        if place_id:
            try:
                details = gmaps.place(place_id=place_id, language='ja')
                description = details.get('result', {}).get('editorial_summary', {}).get('overview', '説明がありません')
            except Exception as e:
                print('Place Details APIでエラー:', e)
                description = '説明の取得に失敗しました'
        else:
            description = '説明がありません'

        closest_shrine['description'] = description

        return {
            'category': 'shrine',
            'name': closest_shrine['name'],
            'description': closest_shrine['description'],
            'address': f"住所: {closest_shrine['address']} (距離: {closest_shrine['distance']:.2f} km)"
        }

    return {'error': '近くに神社が見つかりませんでした'}
