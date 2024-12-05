import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConditionsTableData extends StatefulWidget {
  const ConditionsTableData({super.key});

  @override
  State<ConditionsTableData> createState() => _ConditionsTableDataState();
}

class _ConditionsTableDataState extends State<ConditionsTableData> {

  final List<String> labels = ['Soil Moisture', 'Temperature', 'Humidity', 'Ph'];
  final List<String> values = ['60% - 75%', '18°C - 20°C', '50% - 70%', '6.0 - 6.8'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade400),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            children: <Widget>[
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Condtions",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),

              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sensor Value",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),

            ],
          ),

          for(int i = 0; i < labels.length; i++)

            TableRow(
              children: <Widget>[
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      labels[i], style: GoogleFonts.poppins(),
                    ),
                  ),
                ),

                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      values[i],
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
              ],
            ),

        ],
      ),
    );
  }
}
