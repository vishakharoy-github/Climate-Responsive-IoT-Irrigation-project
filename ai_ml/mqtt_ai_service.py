import json
import joblib
import ssl
import paho.mqtt.client as mqtt
import pandas as pd


# Load ML model
model = joblib.load("irrigation_model.pkl")

# HiveMQ credentials
BROKER = "48b269f0a66e4b6687d683bc4b0d5a8f.s1.eu.hivemq.cloud"
PORT = 8883
USERNAME = "Vishakha_roy"
PASSWORD = "Vishakha@123"

# MQTT topics
SENSOR_TOPIC = "farm/sensors"
PREDICTION_TOPIC = "farm/irrigation"

def on_connect(client, userdata, flags, rc):
    print("Connected with result code", rc)
    client.subscribe(SENSOR_TOPIC)

def on_message(client, userdata, msg):
    print("Sensor data received")

    data = json.loads(msg.payload.decode())

    features = pd.DataFrame([{
        "soil_moisture": data["soil_moisture"],
        "temperature": data["temperature"],
        "humidity": data["humidity"],
        "solar_radiation": data["solar_radiation"],
        "wind_speed": data["wind_speed"],
        "evapotranspiration": data["evapotranspiration"]
    }])


    prediction = model.predict(features)[0]

    result = {"irrigation": int(prediction)}

    client.publish(PREDICTION_TOPIC, json.dumps(result))

    print("Prediction:", result)

client = mqtt.Client()

client.username_pw_set(USERNAME, PASSWORD)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED)

client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER, PORT)

client.loop_forever()
