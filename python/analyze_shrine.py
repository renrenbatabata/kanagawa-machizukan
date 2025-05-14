def analyze_shrine(image):
    width, height = image.size
    return {
        'category': 'shrine',
        'message': '神社の処理をしました',
        'image_width': width,
        'image_height': height
    }
