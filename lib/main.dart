import 'package:flutter/material.dart';

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
const Color tan = Color.fromARGB(255, 238, 228, 218);
const Color greyRext = Color.fromARGB(255, 119, 110, 101);

const Map<int, Color> numTileColor = {
  2: tan,
  4: tan,
  8: Color.fromARGB(255, 242, 177, 121),
  16: Color.fromARGB(255, 245, 149, 99),
  32: Color.fromARGB(255, 246, 124, 95),
  64: Color.fromARGB(255, 246, 95, 64),
  128: Color.fromARGB(255, 235, 208, 117),
  256: Color.fromARGB(255, 235, 203, 103),
  512: Color.fromARGB(255, 236, 201, 85),
  1024: Color.fromARGB(255, 229, 194, 90),
  2048: Color.fromARGB(255, 232, 192, 70),
};

void main() {
  runApp(TwentyFortyEightApp());
}

class Tile {
  final int x;
  final int y;
  int val;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<int> animatedValue;
  late Animation<double> scale;

  Tile(this.x, this.y, this.val) {
    resetAnimation();
  }

  void resetAnimation() {
    animatedX = AlwaysStoppedAnimation(this.x.toDouble());
    animatedY = AlwaysStoppedAnimation(this.y.toDouble());
    animatedValue = AlwaysStoppedAnimation(this.val);
    scale = AlwaysStoppedAnimation(1.0);
  }
}

class TwentyFortyEightApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 Game',
      home: TwentyFortyEight(title: '2048 Game'),
    );
  }
}

class TwentyFortyEight extends StatefulWidget {
  const TwentyFortyEight({super.key, required this.title});

  final String title;

  @override
  State<TwentyFortyEight> createState() => TwentyFortyEightState();
}

class TwentyFortyEightState extends State<TwentyFortyEight>
    with SingleTickerProviderStateMixin {
  // Need to add "with TickerProviderStateMixin" to use "this" as a vsync correct field value
  late AnimationController controller;
  List<List<Tile>> grid = List.generate(
    4,
    (y) => List.generate(4, (x) => Tile(x, y, 0)),
  );
  Iterable<Tile> get flattenedGrid => grid.expand((e) => e);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    grid[1][2].val = 4;
    grid[3][2].val = 16;

    flattenedGrid.forEach((element) => element.resetAnimation());
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];

    stackItems.addAll(
      flattenedGrid.map(
        (e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4.0 * 2,
              height: tileSize - 4.0 * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: lightBrown,
              ),
            ),
          ),
        ),
      ),
    );

    stackItems.addAll(
      flattenedGrid.map(
        (e) => AnimatedBuilder(
          animation: controller,
          builder: (context, child) => e.animatedValue.value == 0
              ? SizedBox()
              : Positioned(
                  left: e.x * tileSize,
                  top: e.y * tileSize,
                  width: tileSize,
                  height: tileSize,
                  child: Center(
                    child: Container(
                      width: tileSize - 4.0 * 2,
                      height: tileSize - 4.0 * 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: numTileColor[e.animatedValue.value],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: tan,
      body: Center(
        child: Container(
          width: gridSize,
          height: gridSize,
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: darkBrown,
          ),
          child: Stack(children: stackItems),
        ),
      ),
    );
  }
}
