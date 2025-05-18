def analyze_turtle(image,latitude,longitude):
    width, height = image.size
    return {
        'category': 'turtle',
        'message': '亀の処理をしました',
        'name':"亀名前",
        'hiraganaName':'かめなまえ',
        'description':'かめ説明',
        'latitude': latitude,
        'longitude': longitude
    }

