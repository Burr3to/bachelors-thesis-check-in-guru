import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Všimnite si: Táto stránka NEobsahuje Scaffold ani AppBar,
    // pretože ich poskytuje nadradený widget MainLayout.
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Hlavný nadpis
            Text(
              'Welcome to Check In Guru!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Popis
            Text(
              'Vaša platforma pre rýchle a jednoduché sledovanie a zbieranie reakcií na kľúčové eventy a udalosti vo vašom tíme alebo projekte.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // Výzva k akcii
            Text(
              'Prihláste sa aby ste mohli vytvorit vas prvy check in',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
