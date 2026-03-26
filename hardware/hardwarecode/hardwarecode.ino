#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "DHT.h"

#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Pins
#define SOIL_PIN 34
#define RELAY_PIN 27
#define BUZZER_PIN 25

bool pumpRunning = false;
bool manualMode = false;

// WiFi
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// HiveMQ Cloud
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 8883;

const char* mqtt_user = "YOUR_USER_NAME";
const char* mqtt_password = "YOUR_PASSWORD";

// Device Info
String device_id = "device_001";
String farmer_id = "farmer_001";

WiFiClientSecure espClient;
PubSubClient client(espClient);

float seconds_per_litre = 40.0;


// WiFi Setup
void setup_wifi() {

Serial.println("Connecting to WiFi...");
WiFi.begin(ssid, password);

while (WiFi.status() != WL_CONNECTED) {
delay(500);
Serial.print(".");
}

Serial.println("");
Serial.println("WiFi connected");

}


// MQTT Callback
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


// AUTO MODE
if (mode == "auto") {

  manualMode = false;

  float waterRequired = doc["water_required"];
  int secondsPerLitre = 40;

  int pumpTime = waterRequired * secondsPerLitre;

  Serial.println("Auto Irrigation Started");
  Serial.print("Water Required: ");
  Serial.print(waterRequired);
  Serial.println(" litres");

  Serial.print("Pump ON for ");
  Serial.print(pumpTime);
  Serial.println(" seconds");

  digitalWrite(RELAY_PIN, HIGH);
  pumpRunning = true;

  tone(BUZZER_PIN, 1000);   // buzzer ON

  for(int i = pumpTime; i > 0; i--) {
    Serial.print("Pump running: ");
    Serial.print(i);
    Serial.println(" sec remaining");
    delay(1000);
  }

  digitalWrite(RELAY_PIN, LOW);
  pumpRunning = false;

  noTone(BUZZER_PIN);   // buzzer OFF

  Serial.println("Pump OFF");
  Serial.println("Irrigation Completed");
}



// MANUAL MODE
if (mode == "manual_on") {

manualMode = true;

Serial.println("Manual Mode Activated");
Serial.println("Farmer watering manually");

tone(BUZZER_PIN, 2000);
delay(1000);
noTone(BUZZER_PIN);

}


// MANUAL STOP
if (mode == "manual_off") {

manualMode = false;

Serial.println("Manual Mode Stopped");

tone(BUZZER_PIN, 1500);
delay(500);
noTone(BUZZER_PIN);

}

}


// MQTT reconnect
void reconnect() {

while (!client.connected()) {

Serial.print("Attempting MQTT connection...");

if (client.connect("ESP32Client", mqtt_user, mqtt_password)) {

Serial.println("connected");
client.subscribe("smart_irrigation/command");

} else {

Serial.print("failed, rc=");
Serial.print(client.state());
Serial.println(" retrying...");
delay(2000);

}

}

}


void setup() {

Serial.begin(115200);

setup_wifi();

espClient.setInsecure();

client.setServer(mqtt_server, mqtt_port);
client.setCallback(callback);

dht.begin();

pinMode(RELAY_PIN, OUTPUT);

digitalWrite(RELAY_PIN, LOW);

}


void loop() {

if (!client.connected()) {
reconnect();
}

client.loop();

float humidity = dht.readHumidity();
float temperature = dht.readTemperature();

int raw = analogRead(SOIL_PIN);

Serial.print("Raw Soil Value: ");
Serial.println(raw);

int moisture = map(raw, 4095, 700, 0, 100);
moisture = constrain(moisture, 0, 100);


StaticJsonDocument<200> doc;

doc["device_id"] = device_id;
doc["farmer_id"] = farmer_id;
doc["soil_moisture"] = moisture;
doc["temperature"] = temperature;
doc["humidity"] = humidity;
doc["pump_status"] = pumpRunning;
doc["manual_mode"] = manualMode;

char buffer[256];

serializeJson(doc, buffer);

client.publish("smart_irrigation/sensor", buffer);

Serial.println("Data Sent:");
Serial.println(buffer);

delay(5000);

}
