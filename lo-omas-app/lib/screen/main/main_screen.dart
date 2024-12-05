import 'package:flutter/material.dart';
import 'package:lo_omas_app/widget/main_page/table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:lo_omas_app/services/notification.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key,});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {



  @override
  Widget build(BuildContext context) {

    NotificationService notificationService = NotificationService();

    final Stream<QuerySnapshot> _conditionsStream = FirebaseFirestore.instance
                                                        .collection('conditions')
                                                        .orderBy('date_time', descending: true)
                                                        .limit(1)
                                                        .snapshots();
    // Define threshold values
    const int moistureMinThreshold = 60;  
    const int moistureMaxThreshold = 60;  

    const double phMinThreshold = 6.0;          
    const double phMaxThreshold = 6.8;          

    const int temperatureMinThreshold = 18; 
    const int temperatureMaxThreshold = 20;

    const int humidityMinThreshold = 50;   
    const int humidityMaxThreshold = 70;


    return Column(
      children: <Widget>[
        const ConditionsTableData(),
        Expanded( // Use Expanded to fill available space
          child: StreamBuilder<QuerySnapshot>(
            stream: _conditionsStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              }

              // Handle case when no documents are found
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No data available.'));
              }

              // Access the first (and only) document
              final document = snapshot.data!.docs.first.data() as Map<String, dynamic>;

              // Extract values from the document
              final soilMoisture = document['soil_moisture'];
              final soilPh = document['ph'];
              final temperature = document['temperature'];
              final humidity = document['humidity'];

              // Create a message for notifications
              String notificationMessage = 'Alert: Greenhouse Conditions Out of Range:\n';
              bool shouldSendNotification = false;

              // Check for threshold violations and accumulate messages
              if (soilMoisture < moistureMinThreshold || soilMoisture > moistureMaxThreshold && soilMoisture != 0) {
                notificationMessage += '• Soil moisture: $soilMoisture (Out of range)\n';
                shouldSendNotification = true;
              }
              if (soilPh < phMinThreshold || soilPh > phMaxThreshold && soilPh != 0) {
                notificationMessage += '• Soil pH: $soilPh (Out of range)\n';
                shouldSendNotification = true;
              }
              if (temperature < temperatureMinThreshold || temperature > temperatureMaxThreshold) {
                notificationMessage += '• Temperature: $temperature°C (Out of range)\n';
                shouldSendNotification = true;
              }
              if (humidity < humidityMinThreshold || humidity > humidityMaxThreshold) {
                notificationMessage += '• Humidity: $humidity% (Out of range)\n';
                shouldSendNotification = true;
              }

              // Send notification if any threshold is violated
              if (shouldSendNotification) {
                notificationService.sendNotification(
                  'Alert: Conditions Out of Range',
                  notificationMessage.trim()
                );
              }

              // Map through the documents
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                  DateFormat dateFormat = DateFormat("EEEE, MMMM d, yyyy");
                  DateFormat timeFormat = DateFormat('h:mm a');

                  Timestamp documentTimestamp = data['date_time'];
                  DateTime toDate = documentTimestamp.toDate();

                  String formattedDate = dateFormat.format(toDate);
                  String formattedTime = timeFormat.format(toDate);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      children: [
                        Text(formattedTime, style: GoogleFonts.poppins(fontSize: 20)),
                        Text(formattedDate, style: GoogleFonts.poppins(fontSize: 20)),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildConditionColumn("Soil Moisture", '${data['soil_moisture']} %'),
                            ),
                            Expanded(
                              child: _buildConditionColumn("Temperature", '${data['temperature']} °C'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildConditionColumn("Humidity", '${data['humidity']} %'),
                            ),
                            Expanded(
                              child: _buildConditionColumn("pH", '${data['ph']}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper function to reduce redundancy in building columns
  Widget _buildConditionColumn(String title, String value) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(title, style: GoogleFonts.poppins(fontSize: 15)),
        ),
        Text(value, style: GoogleFonts.poppins(fontSize: 25)),
      ],
    );
  }
}
