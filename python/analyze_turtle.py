def analyze_turtle(image):
    width, height = image.size
    return {
        'category': 'turtle',
        'message': '亀の処理をしました',
        'image_width': width,
        'image_height': height
    }
