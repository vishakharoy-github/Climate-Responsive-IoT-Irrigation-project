#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "DHT.h"

#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Soil sensor
const int soilPin = 34;

// Relay & buzzer
const int relayPin = 27;
const int buzzerPin = 25;

// WiFi Credentials
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// MQTT Broker
const char* mqtt_server = "broker.hivemq.com";

// Device Info
String device_id = "device_001";
String farmer_id = "farmer_001";

WiFiClient espClient;
PubSubClient client(espClient);

// Water calculation (rough value)
float seconds_per_litre = 40.0;


// WiFi Setup
void setup_wifi() {

  delay(10);
  Serial.println("Connecting to WiFi...");

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
}


// MQTT Callback (Receive Command)
void callback(char* topic, byte* message, unsigned int length) {

  String msg;

  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }

  Serial.println("Message Received:");
  Serial.println(msg);

  StaticJsonDocument<200> doc;
  deserializeJson(doc, msg);

  String mode = doc["mode"];
  float water_required = doc["water_required"];

  if (mode == "auto") {

    int duration = water_required * seconds_per_litre;

    Serial.print("Auto Irrigation: ");
    Serial.print(water_required);
    Serial.println(" litres");

    digitalWrite(relayPin, HIGH);
    digitalWrite(buzzerPin, HIGH);

    delay(duration * 1000);

    digitalWrite(relayPin, LOW);
    digitalWrite(buzzerPin, LOW);

    Serial.println("Irrigation Completed");
  }
}


// MQTT Reconnect
void reconnect() {

  while (!client.connected()) {

    Serial.print("Attempting MQTT connection...");

    if (client.connect("ESP32Client")) {

      Serial.println("connected");

      client.subscribe("smart_irrigation/command");

    } else {

      Serial.print("failed, rc=");
      Serial.print(client.state());
      delay(2000);
    }
  }
}


void setup() {

  Serial.begin(115200);

  setup_wifi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  dht.begin();

  pinMode(relayPin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);

  digitalWrite(relayPin, LOW);
  digitalWrite(buzzerPin, LOW);
}


void loop() {

  if (!client.connected()) {
    reconnect();
  }

  client.loop();

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  int raw = analogRead(soilPin);

  int moisture = map(raw, 3000, 1000, 0, 100);

  StaticJsonDocument<200> doc;

  doc["device_id"] = device_id;
  doc["farmer_id"] = farmer_id;
  doc["soil_moisture"] = moisture;
  doc["temperature"] = temperature;
  doc["humidity"] = humidity;

  char buffer[256];

  serializeJson(doc, buffer);

  client.publish("smart_irrigation/sensor", buffer);

  Serial.println("Data Sent:");
  Serial.println(buffer);

  delay(5000);
}
