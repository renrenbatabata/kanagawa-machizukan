def analyze_shrine(image):
    width, height = image.size
    return {
        'category': 'shrine',
        'message': '神社の処理をしました',
        'name':"神社名前",
        'hiraganaName':'じんじゃなまえ',
        'description':'神社説明'
    }

