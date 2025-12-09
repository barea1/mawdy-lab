import os
import requests
from flask import Flask, jsonify

app = Flask(__name__)

# La URL del Backend vendrá inyectada por la Infraestructura
BACKEND_URL = os.environ.get('API_BASE_URL', 'http://localhost:8080')

@app.route('/')
def home():
    return """
    <div style="font-family: sans-serif; text-align: center; padding: 20px;">
        <h1>MAWDY Odyssey - Frontend</h1>
        <p style="color: green;">Status: <strong>Running</strong></p>
        <hr>
        <h3>Panel de Control:</h3>
        <p><a href="/test-api">📡 Probar conexión con Backend (.NET 10)</a></p>
        <p><a href="/test-db">💾 Consultar Base de Datos SQL</a></p>
    </div>
    """

@app.route('/test-api')
def test_api():
    try:
        response = requests.get(f"{BACKEND_URL}/")
        return jsonify({
            "frontend": "Conexión establecida",
            "backend_response": response.json()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/test-db')
def test_db():
    try:
        response = requests.get(f"{BACKEND_URL}/data")
        return jsonify({
            "frontend": "Solicitud de datos enviada",
            "backend_response": response.json()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)