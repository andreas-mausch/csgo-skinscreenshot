from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return send_from_directory("screenshots", "weapon_knife_karambit##419##0.001##-1##2##0.png")

if __name__ == '__main__':
    app.run()
