import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardWidget extends StatelessWidget {

  final String label;
  final String value;

  const CardWidget({
    super.key, 
    required this.label, 
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 15),
              ),
            ),
          Text(value,
            style: GoogleFonts.poppins(fontSize: 25),
          )
        ],
      ),
    );
  }
}
