from app import app

@app.route('/track', methods = ['POST'])
def track():

    content = request.json

    try:
        lat = float(content['lat'])
        lon = float(content['lon'])
    except:
        return 'Bad Request', 400

    with open('/data/locations.csv', 'a') as locations:
        locations.write(f"{lat},{lon}\n")

    return "OK", 200
