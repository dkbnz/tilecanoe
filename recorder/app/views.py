from app import app, request

@app.route('/track', methods = ['POST'])
def track():

    try:
        content = request.get_json(force=True)
        lat = float(content.get('lat'))
        lon = float(content.get('lon'))
    except:
        return 'Bad Request', 400

    with open('/data/locations.csv', 'a') as locations:
        locations.write(f"{lat},{lon}\n")

    return "OK", 200
