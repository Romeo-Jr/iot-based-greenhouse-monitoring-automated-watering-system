import 'package:flutter/material.dart';
import 'package:lo_omas_app/widget/history_page/card.dart';

class MoreInfo extends StatelessWidget {

  final int soil_moisture;
  final int temperature;
  final int humidity;
  final double ph;

  const MoreInfo({
    super.key, 
    required this.soil_moisture, 
    required this.humidity, 
    required this.temperature, 
    required this.ph
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Information'),
        backgroundColor: const Color.fromRGBO(49, 54, 63, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          children: [
            CardWidget(
              label: "Soil Moisture",
              value: "${soil_moisture.toString()} %",
            ),

            CardWidget(
              label: "Temperature",
              value: "${temperature.toString()} °C",
            ),

            CardWidget(
              label: "Humidity",
              value: "${humidity.toString()} %",
            ),

            CardWidget(
              label: "Ph",
              value: ph.toString(),
            ),
            
          ],
        ),
      ),
    );
  }
}
