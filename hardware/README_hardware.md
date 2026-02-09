# 🌱 Climate Responsive Irrigation System – Hardware

This folder contains the **complete hardware implementation** of the *Climate Responsive Irrigation System*.  
The hardware module is built around an **ESP32** and is responsible for **sensing environmental conditions** and **automatically controlling irrigation** based on real-time data.

The system is designed to be **reliable, noise-resistant, and scalable** for future cloud and AI integrations.

---

## 📌 What This Hardware Does

- Measures **soil moisture** using an analog sensor
- Measures **temperature and humidity** using a DHT22 sensor
- Converts raw sensor values into **human-readable percentages**
- Automatically turns the **water pump ON/OFF**
- Uses **hysteresis logic** to avoid rapid relay switching
- Provides **visual/log feedback** via Serial Monitor
- Activates a **buzzer alert** when irrigation is active

---

## 🔧 Hardware Components

| Component | Purpose |
|---------|--------|
| ESP32 Dev Board | Main controller |
| DHT22 Sensor | Temperature & humidity measurement |
| Soil Moisture Sensor (Analog) | Soil water level detection |
| Relay Module | Controls pump or solenoid valve |
| Water Pump / Valve | Irrigation |
| Passive Buzzer (Optional) | Pump status alert |
| Jumper Wires & Breadboard | Connections |
| External Power Supply | Pump & relay power |

---

## 📂 Folder Structure