import logging
import paho.mqtt.client as mqtt
from json import loads
from firebase_admin.firestore import SERVER_TIMESTAMP
from firebase import firebase
from sys import exit

info_handler = logging.FileHandler("logs/mqtt/info.log")
info_handler.setLevel(logging.INFO)

error_handler = logging.FileHandler("logs/mqtt/error.log")
error_handler.setLevel(logging.ERROR)

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
info_handler.setFormatter(formatter)
error_handler.setFormatter(formatter)

logger = logging.getLogger('mqtt_subscriber')
logger.setLevel(logging.DEBUG)

logger.addHandler(info_handler)
logger.addHandler(error_handler)

class MqttSubscriber: 
    def __init__(self, broker_address, port, topic, username = None, password = None):
        self.broker_address = broker_address
        self.port = port
        self.topic = topic
        self.client = None
        self.username = username
        self.password = password

    def connect_to_broker(self):
        try:
            self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
            self.client.username_pw_set(username = self.username, password = self.password)
            self.client.on_message = self.on_message
            self.client.connect(self.broker_address, self.port)
            logger.info(f"Connected to {self.broker_address} MQTT broker successfully.")

        except Exception as error:
            logger.error(f'Error connecting to broker: {error.args[0]}')
            exit(1)

    def subscribe_to_topic(self):
        try:
            logger.info(f"Subscribing to topic : {self.topic}")
            self.client.subscribe(self.topic)
            self.client.loop_forever()

        except Exception as error:
            logger.error(f'Error : {error.args[0]}')

    def on_message(self, client, userdata, msg):
        try:
            message = msg.payload.decode('utf-8')
            message = loads(message)
            
            if all(key in message for key in ["sm", "tm", "hd", "ph"]):
                json_data = {
                    key: int(value) if key in ["soil_moisture", "temperature", "humidity"] else (float(value) if key == 'ph' else value)
                    for key, value in {
                        'soil_moisture': message["sm"],
                        'temperature': message["tm"],
                        'humidity': message["hd"],
                        'ph': message["ph"],
                        'date_time': SERVER_TIMESTAMP
                    }.items()
                }
                
                if json_data['soil_moisture'] < 100 and json_data['ph'] < 10 and json_data['soil_moisture'] != 0:
                    firebase.insert_data(json_data)
                    logger.info(f"Data Inserted : {json_data['soil_moisture']} : {json_data['ph']} : {json_data['temperature']} : {json_data['humidity']}")

        except Exception as error:
            logger.error(f"Error processing message: {error.args[0]}")

