import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Game',
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color shadowColor = Colors.cyan;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 17, 16),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '2048',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color:  Color.fromARGB(255, 252, 252, 252),
                fontFamily: 'Aerospace',
                shadows: [
                  for (double i = 1; i < 4; i++)
                    Shadow(color: shadowColor, blurRadius: 10 * i),
                ],
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TwentyFortyEight(title: '2048 Game'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 2),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'JOUER',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbix',
                  shadows: [
                    for (double i = 1; i < 4; i++)
                      Shadow(color: shadowColor, blurRadius: 3 * i),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder pour les options/règles
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Comment jouer',
                      style: TextStyle(fontFamily: 'Space'),
                    ),
                    content: Text(
                      'Glissez pour déplacer les tuiles. Combinez les tuiles identiques pour atteindre 2048!',
                      // style: TextStyle(fontFamily: 'Space'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 2),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'RÈGLES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbix',
                  shadows: [
                    for (double i = 1; i < 4; i++)
                      Shadow(color: shadowColor, blurRadius: 3 * i),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
