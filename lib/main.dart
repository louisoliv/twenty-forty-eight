import 'package:flutter/material.dart';

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
const Color tan = Color.fromARGB(255, 238, 228, 218);
const Color greyText = Color.fromARGB(255, 119, 110, 101);

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

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = Tween(
      begin: this.x.toDouble(),
      end: x.toDouble(),
    ).animate(CurvedAnimation(parent: parent, curve: Interval(0, .5)));
    animatedY = Tween(
      begin: this.y.toDouble(),
      end: y.toDouble(),
    ).animate(CurvedAnimation(parent: parent, curve: Interval(0, .5)));
  }

  void bounce(Animation<double> parent) {
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1)));
  }

  void appear(Animation<double> parent) {
    scale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1)));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(val), weight: .01),
      TweenSequenceItem(tween: ConstantTween(newValue), weight: .99),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1.0)));
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
  List<Tile> toAdd = [];

  Iterable<Tile> get flattenedGrid => grid.expand((e) => e);
  Iterable<List<Tile>> get cols =>
      List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        toAdd.forEach((element) {
          grid[element.y][element.x].val = element.val;
        });
        flattenedGrid.forEach((element) {
          element.resetAnimation();
        });
        toAdd.clear();
      }
    });

    grid[1][2].val = 4;
    grid[0][2].val = 4;
    grid[3][2].val = 16;
    grid[0][0].val = 16;

    flattenedGrid.forEach((element) => element.resetAnimation());
  }

  void addNewtile() {
    List<Tile> empty = flattenedGrid
        .where((element) => element.val == 0)
        .toList();
    empty.shuffle();
    toAdd.add(Tile(empty.first.x, empty.first.y, 2)..appear(controller));
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
      [flattenedGrid, toAdd]
          .expand((e) => e)
          .map( 
            (e) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) => e.animatedValue.value == 0
                  ? SizedBox()
                  : Positioned(
                      left: e.animatedX.value * tileSize,
                      top: e.animatedY.value * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Center(
                        child: Container(
                          width: (tileSize - 4.0 * 2) * e.scale.value,
                          height: (tileSize - 4.0 * 2) * e.scale.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: numTileColor[e.animatedValue.value],
                          ),
                          child: Center(
                            child: Text(
                              "${e.animatedValue.value}",
                              style: TextStyle(
                                color: e.animatedValue.value <= 4
                                    ? greyText
                                    : Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -250 && canSwipeUp()) {
                // swipe up
                doSwipe(swipeUp);
              } else if (details.velocity.pixelsPerSecond.dy > 250 &&
                  canSwipeDown()) {
                // swipe down
                doSwipe(swipeDown);
              }
            },

            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < -1000 &&
                  canSwipeLeft()) {
                // swipe left
                doSwipe(swipeLeft);
              } else if (details.velocity.pixelsPerSecond.dx > 1000 &&
                  canSwipeRight()) {
                // swipe right
                doSwipe(swipeRight);
              }
            },

            child: Stack(children: stackItems),
          ),
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFn) {
    setState(() {
      swipeFn();
      // add new tile
      addNewtile();
      controller.forward(from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);
  bool canSwipeUp() => cols.any(canSwipe);
  bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((e) => e.val != 0)) {
          return true;
        }
      } else {
        Tile? nextNonZero = tiles
            .skip(i + 1)
            .cast<Tile?>()
            .firstWhere((e) => e!.val != 0, orElse: () => null);
        if (nextNonZero != null && nextNonZero.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
  void swipeUp() => cols.forEach(mergeTiles);
  void swipeDown() => cols.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Iterable<Tile> toCheck = tiles
          .skip(i)
          .skipWhile((value) => value.val == 0);
      if (toCheck.isNotEmpty) {
        Tile t = toCheck.first;
        Tile? merge = toCheck
            .skip(1)
            .cast<Tile?>()
            .firstWhere((t) => t!.val != 0, orElse: () => null);
        if (merge != null && merge.val != t.val) {
          merge = null;
        }
        if (tiles[i] != t || merge != null) {
          int resultValue = t.val;
          // animate the tile position at position t
          t.moveTo(controller, tiles[i].x, tiles[i].y);
          if (merge != null) {
            resultValue += merge.val;
            // move the merge tile
            merge.moveTo(controller, tiles[i].x, tiles[i].y);
            merge.bounce(controller);
            merge.changeNumber(controller, resultValue);
            merge.val = 0;
            t.changeNumber(controller, 0);
          }
          t.val = 0;
          tiles[i].val = resultValue;
        }
      }
    }
  }
}
