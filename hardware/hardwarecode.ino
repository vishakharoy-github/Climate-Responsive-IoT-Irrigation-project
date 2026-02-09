#include "DHT.h"

#define DHTPIN 4          // DHT22 data -> GPIO4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Soil sensor
const int soilPin = 34;   // ADC1_6 (GPIO34) - analog input
// ADC range on ESP32: 0..4095 (12-bit) by default
int dryValue = 3000;      // EXAMPLE: raw value in dry soil/air - replace after calibration
int wetValue = 1000;      // EXAMPLE: raw value in fully wet - replace after calibration

// Relay & buzzer
const int relayPin = 27;  // Relay IN
const int buzzerPin = 25; // Passive buzzer (optional)

int moisturePercent = 0;

// Control thresholds (percent)
const int threshold_on  = 30; // Turn pump ON when moisture < threshold_on
const int threshold_off = 45; // Turn pump OFF when moisture > threshold_off

// Smoothing
const int N_SAMPLES = 8;      // number of samples to average for soil reading
int soilSamples[N_SAMPLES];
int sampleIndex = 0;
bool pumpState = false;

void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(10); }
  Serial.println("Starting DHT22 + Soil Moisture system...");

  dht.begin();
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW); // ensure relay OFF initially (LOW = off for many modules; check yours)

  pinMode(buzzerPin, OUTPUT);
  digitalWrite(buzzerPin, LOW);

  // initialize smoothing array with current reading
  int r = analogRead(soilPin);
  for (int i = 0; i < N_SAMPLES; ++i) soilSamples[i] = r;
}

void loop() {
  // --- Read DHT22 (every loop with 2s delay) ---
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // --- Read soil (smoothed) ---
  int raw = analogRead(soilPin); // 0..4095
  soilSamples[sampleIndex++] = raw;
  if (sampleIndex >= N_SAMPLES) sampleIndex = 0;

  long sum = 0;
  for (int i = 0; i < N_SAMPLES; ++i) sum += soilSamples[i];
  int avgRaw = sum / N_SAMPLES;

  // Map raw to percent (0..100), taking into account inversion
  // If dryValue > wetValue (typical: dry higher), map accordingly; else handle reverse.
  float pct;
  if (dryValue > wetValue) {
    // dry is high, wet is low
    pct = (float)(avgRaw - wetValue) * 100.0 / (float)(dryValue - wetValue);
  } else {
    // wet is high, dry is low (less common)
    pct = (float)(avgRaw - dryValue) * 100.0 / (float)(wetValue - dryValue);
  }
  // clamp
  if (pct < 0) pct = 0;
  if (pct > 100) pct = 100;
  moisturePercent = (int)pct;

  // --- Control with hysteresis ---
  if (!pumpState) {
    // pump currently OFF — check if it should turn ON
    if (moisturePercent < threshold_on) {
      pumpState = true;
      digitalWrite(relayPin, HIGH); // activate relay (check your relay logic: some boards are active LOW)
      digitalWrite(buzzerPin, HIGH);
      Serial.println(">>> PUMP TURNED ON");
    }
  } else {
    // pump currently ON — check if it should turn OFF
    if (moisturePercent > threshold_off) {
      pumpState = false;
      digitalWrite(relayPin, LOW);
      digitalWrite(buzzerPin, LOW);
      Serial.println(">>> PUMP TURNED OFF");
    }
  }

  // --- Print readings ---
  Serial.print("Soil raw: "); Serial.print(avgRaw);
  Serial.print("  Moisture: "); Serial.print(moisturePercent); Serial.print("%");
  Serial.print("  |  Temp: ");
  if (isnan(temperature)) Serial.print("N/A"); else Serial.print(temperature);
  Serial.print("C  Hum: ");
  if (isnan(humidity)) Serial.print("N/A"); else Serial.print(humidity);
  Serial.print("%  Relay: ");
  Serial.println(pumpState ? "ON" : "OFF");

  delay(2000); 
}