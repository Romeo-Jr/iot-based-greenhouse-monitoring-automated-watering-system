#include <WiFi.h>
#include <PubSubClient.h>
#include <SoftwareSerial.h>

#define LED_PIN 19
SoftwareSerial arduinoSerial(16, 17);

const char* mqtt_server = "<broker-server>";
const char* username = "<broker-username>";
const char* password = "<broker-password>";

const char* ssid = "<wifi-ssid>";
const char* wifi_password = "<wifi-password>";

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() { 
    delay(10);
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, wifi_password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}

// Function to connect to MQTT broker
void reconnect() {
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection...");
        // username, password
        if (client.connect("ESP32Client")) {
            Serial.println("connected");
        } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            delay(5000);
        }
    }
}

void setup() {
    Serial.begin(115200); 
    arduinoSerial.begin(9600); // Initialize serial communication for Arduino-ESP32

    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);

    setup_wifi();       // Connect to WiFi
    client.setServer(mqtt_server, 1883); // Set MQTT broker
}

void loop() {

    digitalWrite(LED_PIN, LOW);
    
    if (!client.connected()) {
        reconnect();
    }
    client.loop();

    if (arduinoSerial.available()) {

        String jsonString = arduinoSerial.readStringUntil('\n'); // Read JSON from serial
        Serial.println(jsonString);

        // Publish a message every 5 seconds 1800000
        static unsigned long lastMsg = 0;
        unsigned long now = millis();
        if (now - lastMsg > 5000) {
            lastMsg = now;

            // Publish the received JSON directly to the MQTT broker
            if (client.publish("conditions", jsonString.c_str())) {
                digitalWrite(LED_PIN, HIGH);
                Serial.println("JSON data sent to MQTT broker successfully");
            } else {
                Serial.println("Failed to send JSON data to MQTT broker");
            }

        }
    }

    delay(1000);
}
