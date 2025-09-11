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

  int score = 0;
  int best_score = 0;

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

        if (isGameOver()) {
          print("GAME OVER DÉTECTÉ APRÈS ANIMATION");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Game Over"),
                  content: Text("Ton score est $score"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          initGrid();
                        });
                      },
                      child: Text("Rejouer"),
                    ),
                  ],
                );
              },
            );
          });
        }
      }
    });

    initGrid();

    // flattenedGrid.forEach((element) => element.resetAnimation());
  }

  void initGrid() {
    setState(() {
      score = 0;
      grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));

      // grid[1][2].val = 4;
      // grid[0][2].val = 4;
      // grid[3][2].val = 16;
      // grid[0][0].val = 16;

      // Grid example to trigger faster the alert dialog widget
      grid[0][0].val = 2;
      grid[0][1].val = 4;
      grid[0][2].val = 2;
      grid[0][3].val = 4;
      grid[1][0].val = 4;
      grid[1][1].val = 2;
      grid[1][2].val = 4;
      grid[1][3].val = 2;
      grid[2][0].val = 2;
      grid[2][1].val = 4;
      grid[2][2].val = 2;
      grid[2][3].val = 4;
      grid[3][0].val = 4;
      grid[3][1].val = 16;
      grid[3][2].val = 4;
      // grid[3][3].val = 2;

      flattenedGrid.forEach((element) => element.resetAnimation());
    });
  }

  void addNewtile() {
    List<Tile> empty = flattenedGrid
        .where((element) => element.val == 0)
        .toList();
    empty.shuffle();
    toAdd.add(Tile(empty.first.x, empty.first.y, 2)..appear(controller));
  }

  bool isGameOver() {
    bool canUp = canSwipeUp();
    bool canDown = canSwipeDown();
    bool canLeft = canSwipeLeft();
    bool canRight = canSwipeRight();

    print(
      "DEBUG isGameOver - Up: $canUp, Down: $canDown, Left: $canLeft, Right: $canRight",
    );

    return !canUp && !canDown && !canLeft && !canRight;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Score : $score'),
            ElevatedButton(
              onPressed: () {
                // Force game over pour tester
                if (isGameOver()) {
                  print("SHOWING GAME OVER DIALOG");
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Game Over"),
                        content: Text("Ton score est $score"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                initGrid();
                              });
                            },
                            child: Text("Rejouer"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Test Game Over"),
            ),
            Container(
              width: gridSize,
              height: gridSize,
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: darkBrown,
              ),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy < -250 &&
                      canSwipeUp()) {
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
          ],
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFn) {
    debugGameState(); // Ajoutez cette ligne pour voir l'état

    setState(() {
      swipeFn();
      print(
        "Après swipe - canSwipeUp: ${canSwipeUp()}, canSwipeDown: ${canSwipeDown()}, canSwipeLeft: ${canSwipeLeft()}, canSwipeRight: ${canSwipeRight()}",
      );
      if (!isGameOver()) {
        addNewtile();
      } else {
        print("GAME OVER détecté");
      }
      controller.forward(from: 0);
    });

    if (isGameOver()) {
      print("SHOWING GAME OVER DIALOG"); // Debug
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Game Over"),
              content: Text("Ton score est $score"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      initGrid();
                    });
                  },
                  child: Text("Rejouer"),
                ),
              ],
            );
          },
        );
      });
    }
  }

  void debugGameState() {
    print("=== DEBUG GAME STATE ===");
    print("Can swipe left: ${canSwipeLeft()}");
    print("Can swipe right: ${canSwipeRight()}");
    print("Can swipe up: ${canSwipeUp()}");
    print("Can swipe down: ${canSwipeDown()}");
    print("Is game over: ${isGameOver()}");

    print("\nGrid state:");
    for (int y = 0; y < 4; y++) {
      String row = "";
      for (int x = 0; x < 4; x++) {
        row += "${grid[y][x].val.toString().padLeft(4)} ";
      }
      print(row);
    }
    print("========================");
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);
  bool canSwipeUp() => cols.any(canSwipe);
  bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    // 1. S'il y a des espaces vides, on peut toujours bouger
    if (tiles.any((tile) => tile.val == 0)) {
      return true;
    }

    // 2. S'il n'y a pas d'espaces vides, vérifier s'il y a des fusions possibles
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i].val == tiles[i + 1].val) {
        return true; // Deux tuiles adjacentes identiques peuvent fusionner
      }
    }

    return false;
  }

  List<int> mergeValues(List<int> values) {
    List<int> result = List.filled(4, 0);
    List<int> nonZero = values.where((v) => v != 0).toList();

    int resultIndex = 0;
    int i = 0;

    while (i < nonZero.length) {
      if (i < nonZero.length - 1 && nonZero[i] == nonZero[i + 1]) {
        // Fusion possible
        result[resultIndex] = nonZero[i] * 2;
        i += 2; // Skip both tiles
      } else {
        // Pas de fusion
        result[resultIndex] = nonZero[i];
        i += 1;
      }
      resultIndex++;
    }

    return result;
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
            score += merge.val * 2;
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
