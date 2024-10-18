import json
import secrets
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
cors = CORS(app)

# Database configuration
config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'P8[1W~0|IXEd',
    'database': 'eventmap',
    'port': 3306,
}

# Function to get a database connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(**config)
        return conn
    except Error as e:
        print("Error connecting to the database:", e)
        return None

@app.route('/api/save-position', methods=['POST'])
def save_position():
    print('Request body:', request.json)
    latitude = request.json.get('latitude')
    longitude = request.json.get('longitude')
    address = request.json.get('address')

    if not latitude or not longitude:
        return jsonify({'message': 'Address, latitude, and longitude are required'}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO Location (address, latitude, longitude) VALUES (%s, POINT(%s, %s), POINT(%s, %s))',
            (address, latitude, longitude, latitude, longitude)
        )
        conn.commit()
        location_id = cursor.lastrowid
        return jsonify({'message': 'Position saved successfully', 'location_id': location_id}), 200
    except Error as err:
        print('Error inserting position:', err)
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/save-eventdata', methods=['POST'])
def save_event_data():
    print('Request body:', request.json)
    location_id = request.json.get('location_id')
    title = request.json.get('title')
    description = request.json.get('description')
    event_date = request.json.get('event_date')
    type_of_event = request.json.get('type_of_event')

    if not all([location_id, title, description, event_date, type_of_event]):
        return jsonify({'message': 'location_id, title, description, event_date, and type_of_event are required'}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO Event (location_id, title, description, event_date, type_of_event) VALUES (%s, %s, %s, %s, %s)',
            (location_id, title, description, event_date, type_of_event)
        )
        conn.commit()
        event_id = cursor.lastrowid
        return jsonify({'message': 'Event data saved successfully', 'event_id': event_id}), 200
    except Error as err:
        print('Error inserting event data:', err)
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.secret_key = secrets.token_hex(16)
    app.run(debug=True, port=3000)
