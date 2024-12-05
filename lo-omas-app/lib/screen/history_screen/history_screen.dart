import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lo_omas_app/widget/history_page/more_info.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with RestorationMixin{

  DateTime? selectedDate;
  Stream<QuerySnapshot>? _conditionsStream;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final yesterday =  now.subtract(const Duration(days: 1));
    late DateTime theDay = DateTime(yesterday.year, yesterday.month, yesterday.day);

    late final startOfDay = Timestamp.fromDate(theDay);
    late final toDate = startOfDay.toDate();
    late final endOfDay = toDate.add(const Duration(days: 1));
    late final endOfDatTs = Timestamp.fromDate(endOfDay); 

    _conditionsStream = FirebaseFirestore.instance.collection('conditions')
                                                  .where('date_time', isGreaterThanOrEqualTo: startOfDay)
                                                  .where('date_time', isLessThan: endOfDatTs)
                                                  .orderBy('date_time', descending: true)
                                                  .snapshots();
  }


  @override                  
  String? get restorationId => widget.restorationId;
  
  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        late DateTime theDay = DateTime(_selectedDate.value.year, _selectedDate.value.month, _selectedDate.value.day);

        late final startOfDay = Timestamp.fromDate(theDay);
        late final toDate = startOfDay.toDate();
        late final endOfDay = toDate.add(const Duration(days: 1));
        late final endOfDatTs = Timestamp.fromDate(endOfDay); 

        _conditionsStream = FirebaseFirestore.instance.collection('conditions')
                                                      .where('date_time', isGreaterThanOrEqualTo: startOfDay)
                                                      .where('date_time', isLessThan: endOfDatTs)
                                                      .orderBy('date_time', descending: true)
                                                      .snapshots();

      });
    }
  }                                

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Historical Data',
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: '\nData must be filtered by date before it can be displayed.',
                  style: GoogleFonts.poppins(fontSize: 13.0, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: const ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
              ),
            onPressed: () {
              _restorableDatePickerRouteFuture.present();
            },
            child: const Text('Filter by Date'),
          ),
          SizedBox(
            height: 400,
            child: StreamBuilder<QuerySnapshot>(
            stream: _conditionsStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                    'Loading',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  );
              }

              if (snapshot.data!.docs.isEmpty){
                  return Text(
                    'No data found for ${DateFormat('yMMMMd').format(_selectedDate.value)}',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  );
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                  DateFormat dateFormat = DateFormat("EEEE, MMMM d, yyyy");
                  DateFormat timeFormat = DateFormat('h:mm a');

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
