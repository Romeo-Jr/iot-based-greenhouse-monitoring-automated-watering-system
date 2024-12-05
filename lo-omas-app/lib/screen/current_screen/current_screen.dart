import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lo_omas_app/widget/history_page/more_info.dart';

import 'package:intl/intl.dart';

class CurrentScreen extends StatefulWidget {
  const CurrentScreen({super.key});

  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen>{

  DateFormat dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  DateFormat timeFormat = DateFormat('h:mm a');

  DateTime now = DateTime.now();
  late DateTime today = DateTime(now.year, now.month, now.day);

  late final startOfDay = Timestamp.fromDate(today);
  late final toDate = startOfDay.toDate();
  late final endOfDay = toDate.add(const Duration(days: 1));
  late final endOfDatTs = Timestamp.fromDate(endOfDay);

  late final Stream<QuerySnapshot> _conditionsStream = FirebaseFirestore.instance.collection('conditions')
                                                        .where('date_time', isGreaterThanOrEqualTo: startOfDay)
                                                        .where('date_time', isLessThan: endOfDatTs)
                                                        .orderBy('date_time', descending: true)
                                                        .snapshots();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              dateFormat.format(now),
              style: GoogleFonts.poppins(fontSize: 18.0),  
            ),
          ),
          SizedBox(
            height: 450,
            child: StreamBuilder<QuerySnapshot>(
            stream: _conditionsStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                  Timestamp documentTimestamp = data['date_time'];
                  DateTime toDate = documentTimestamp.toDate();
                
                  String formattedDate = dateFormat.format(toDate);
                  String formattedTime = timeFormat.format(toDate);

                  return ListTile(
                    title: Text(formattedTime),
                    subtitle: Text(formattedDate),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_right),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MoreInfo(
                            soil_moisture: data['soil_moisture'], 
                            temperature: data['temperature'], 
                            humidity: data['humidity'], 
                            ph: data['ph'],)
                          ),
                        );
                      },
                    ),
                  );
                  
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
