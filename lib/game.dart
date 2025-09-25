import 'package:flutter/material.dart';
import 'dart:math';
import 'score_manager.dart';

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);

const Map<int, Color> numTileColor = {
  2: Color.fromRGBO(178, 235, 242, 1),
  4: Color.fromARGB(255, 128, 222, 234),
  8: Color.fromARGB(255, 178, 236, 242),
  16: Color.fromARGB(255, 151, 225, 245),
  32: Color.fromARGB(255, 124, 214, 246),
  64: Color.fromARGB(255, 95, 203, 246),
  128: Color.fromARGB(255, 117, 235, 235),
  256: Color.fromARGB(255, 103, 235, 225),
  512: Color.fromARGB(255, 85, 236, 215),
  1024: Color.fromARGB(255, 90, 229, 205),
  2048: Color.fromARGB(255, 70, 232, 195),
};

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
    ).animate(CurvedAnimation(parent: parent, curve: Interval(0, .8)));
    animatedY = Tween(
      begin: this.y.toDouble(),
      end: y.toDouble(),
    ).animate(CurvedAnimation(parent: parent, curve: Interval(0, .8)));
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
  bool _isInitialized = false; // Ajout d'un flag d'initialisation

  Iterable<Tile> get flattenedGrid => grid.expand((e) => e);
  Iterable<List<Tile>> get cols =>
      List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  int score = 0;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    loadBestScore();
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
          ScoreManager.saveScore(score);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Game Over",
                    style: TextStyle(fontFamily: 'Orbix'),
                  ),
                  content: Text(
                    "Ton score est $score",
                    style: TextStyle(fontFamily: 'Orbix'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          initGrid();
                          loadBestScore();
                        });
                      },
                      child: Text(
                        "Rejouer",
                        style: TextStyle(fontFamily: 'Orbix'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        print("object");
                      },
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbix',
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          });
          // });
        }
      }
    });

    initGrid();
  }

  Future<void> loadBestScore() async {
    final best = await ScoreManager.getBestScore();
    setState(() {
      bestScore = best;
    });
  }

  void initGrid() {
    setState(() {
      score = 0;
      final random = Random();

      grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));

      int tilesCount = 3 + random.nextInt(3);

      for (int i = 0; i < tilesCount; i++) {
        // Find empty position
        int x, y;
        do {
          x = random.nextInt(4);
          y = random.nextInt(4);
        } while (grid[y][x].val != 0);

        // Place 2 (90%) or 4 (10%)
        grid[y][x].val = random.nextDouble() < 0.9 ? 2 : 4;
      }

      flattenedGrid.forEach((element) => element.resetAnimation());
      _isInitialized = true;
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

    return !canUp && !canDown && !canLeft && !canRight;
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];
    Color shadowColor = Colors.cyan;

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
                color: const Color.fromARGB(255, 0, 0, 0),
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
                            boxShadow: [
                              for (double i = 1; i < 2; i++)
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    243,
                                    243,
                                    243,
                                  ),
                                  blurRadius: 5 * i,
                                ),
                            ],
                            borderRadius: BorderRadius.circular(10.0),
                            color:
                                numTileColor[e.animatedValue.value] ??
                                lightBrown,
                          ),
                          child: Center(
                            child: Text(
                              "${e.animatedValue.value}",
                              style: TextStyle(
                                color: e.animatedValue.value <= 4
                                    ? const Color.fromARGB(255, 65, 60, 57)
                                    : Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Aerospace',
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
      backgroundColor: const Color.fromARGB(255, 17, 17, 16),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: const Color.fromARGB(255, 35, 22, 114),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Score : $score",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbix',
                    shadows: [
                      for (double i = 1; i < 4; i++)
                        Shadow(color: shadowColor, blurRadius: 10 * i),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 5),

            Container(
              width: gridSize,
              height: gridSize,
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
                color: const Color.fromARGB(255, 31, 31, 31),
              ),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy < -250 &&
                      canSwipeUp()) {
                    doSwipe(swipeUp);
                  } else if (details.velocity.pixelsPerSecond.dy > 250 &&
                      canSwipeDown()) {
                    doSwipe(swipeDown);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx < -1000 &&
                      canSwipeLeft()) {
                    doSwipe(swipeLeft);
                  } else if (details.velocity.pixelsPerSecond.dx > 1000 &&
                      canSwipeRight()) {
                    doSwipe(swipeRight);
                  }
                },
                child: Stack(children: stackItems),
              ),
            ),

            Container(
              width: gridSize,
              margin: EdgeInsets.only(top: 16.0), // Espace au-dessus de la row
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          initGrid();
                          loadBestScore();
                        }),
                      },

                      child: Icon(Icons.restart_alt),
                    ),
                  ),

                  SizedBox(width: 5),

                  Container(
                    child: ElevatedButton(
                      onPressed: () => {Navigator.of(context).pop()},

                      child: Icon(Icons.home),
                    ),
                  ),

                  SizedBox(width: 5),

                  Card(
                    color: const Color.fromARGB(255, 35, 22, 114),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        "Best score : $bestScore",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbix',
                          shadows: [
                            for (double i = 1; i < 4; i++)
                              Shadow(color: shadowColor, blurRadius: 10 * i),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFn) {
    debugGameState();

    setState(() {
      swipeFn();

      if (!isGameOver()) {
        addNewtile();
      } else {
        print("GAME OVER détecté");
      }
      controller.forward(from: 0);
    });

    if (isGameOver()) {
      ScoreManager.saveScore(score);
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
                      loadBestScore();
                    });
                  },
                  child: Text("Rejouer"),
                ),
              ],
            );
          },
        );
      });
      // });
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
    // 1. If there are empty spaces, we can move
    if (tiles.any((tile) => tile.val == 0)) {
      return true;
    }

    // 2. If there are no empty spaces, check if fusions are possible
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i].val == tiles[i + 1].val) {
        return true; // 2 identical sided tiles can fusion
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
        // No fusion
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
          // Animate the tile position at position t
          t.moveTo(controller, tiles[i].x, tiles[i].y);
          if (merge != null) {
            resultValue += merge.val;
            score += merge.val * 2;
            // Move the merge tile
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
