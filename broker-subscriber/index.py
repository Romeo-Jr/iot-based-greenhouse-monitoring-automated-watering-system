import paho.mqtt.client as mqtt
from os import environ
from mqtt.mqtt_controller import MqttSubscriber

if __name__ == '__main__':

  BROKER_ADDRESS = environ.get("BROKER_ADDRESS")
  PORT = int(environ.get("PORT"))
  TOPIC = environ.get("TOPIC")
  BROKER_USERNAME = environ.get("BROKER_USERNAME")
  BROKER_PASSWORD = environ.get("BROKER_PASSWORD")

  subscriber = MqttSubscriber(BROKER_ADDRESS, PORT, TOPIC, BROKER_USERNAME, BROKER_PASSWORD)
  subscriber.connect_to_broker()
  subscriber.subscribe_to_topic()
