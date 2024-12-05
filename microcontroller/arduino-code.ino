#include <ArduinoJson.h>
#include <Wire.h>
#include "Adafruit_SHT31.h"
#include <SoftwareSerial.h>

Adafruit_SHT31 sht31 = Adafruit_SHT31();

#define RE_DE 7
#define RELAY_PIN 6

const int soil_moisture_threshold = 60;

const uint32_t TIMEOUT = 500UL;

const byte moist[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x03, 0x05, 0xCB};
const byte PH[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x74, 0x0B};

byte values[8];
SoftwareSerial mod(2, 3); // Rx pin, Tx pin

StaticJsonDocument<255> doc;

void setup() {

    Serial.begin(9600);
    mod.begin(4800);

    pinMode(RE_DE, OUTPUT);
    pinMode(RELAY_PIN, OUTPUT);

    digitalWrite(RELAY_PIN, HIGH);

    if (!sht31.begin(0x44)) {  // Use 0x44 or 0x45 depending on ADDR pin
        Serial.println("Couldn't find SHT35 sensor!");
        while(1);
    }

    delay(1000);    
}

void loop() {
    uint16_t soil_moisture_val, soil_ph_val;

    float humidity_val, temperature_val;

    soil_moisture_val = moisture();
    soil_ph_val = ph();

    float calculate_soil_moisture = soil_moisture_val * 0.1;
    float calculate_soil_ph = soil_ph_val / 100;

    float temp = sht31.readTemperature();
    float hum = sht31.readHumidity();

    if (!isnan(temp)) {
        temperature_val = temp;
    } 
    else {
        Serial.println("Failed to read temperature");
    }

    if (!isnan(hum)) {
        humidity_val = hum;
    } 
    else {
        Serial.println("Failed to read humidity");
    }

    doc["sm"] = calculate_soil_moisture;
    doc["tm"] = temperature_val;
    doc["hd"] = humidity_val;
    doc["ph"] = calculate_soil_ph;

    // Serialize the JSON object to a string
    String jsonString;
    serializeJson(doc, jsonString);
    
    // Send the JSON string over Serial
    Serial.println(jsonString);

    // trigger solenoid valve
    if(calculate_soil_moisture < 100 && calculate_soil_moisture < soil_moisture_threshold){
        digitalWrite( RELAY_PIN, LOW );
    }else{
        digitalWrite( RELAY_PIN, HIGH );
    }
    
    delay(2000);
}

int16_t readSensor(const uint8_t* command, size_t commandSize) {
    uint32_t startTime = 0;
    uint8_t byteCount = 0;

    // Enable transmission
    digitalWrite(RE_DE, HIGH);
    delay(10);

    // Write command to the sensor
    mod.write(command, commandSize);
    mod.flush();

    // Disable transmission, enable reception
    digitalWrite(RE_DE, LOW);

    // Start timeout counter
    startTime = millis();

    // Read data within the timeout period
    while (millis() - startTime <= TIMEOUT) {
        if (mod.available() && byteCount < sizeof(values)) {
            values[byteCount++] = mod.read();
        }
    }
    return (int16_t)(values[3] << 8 | values[4]);
}

int16_t moisture() {
    return readSensor(moist, sizeof(moist));
}

int16_t ph() {
    return readSensor(PH, sizeof(PH));
}