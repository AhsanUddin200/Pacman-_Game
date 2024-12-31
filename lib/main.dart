import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

void main() => runApp(MaterialApp(home: PacmanGame()));

class PacmanGame extends StatefulWidget {
  @override
  _PacmanGameState createState() => _PacmanGameState();
}

class _PacmanGameState extends State<PacmanGame> {
  static int numberOfSquares = 760;
  static int numberInRow = 20;

  int player = 190;
  int ghost = 40;
  bool mouthClosed = false;
  int score = 0;
  bool gameOver = false;
  bool gamePaused = false;
  Direction pacmanDirection = Direction.right;
  Timer? gameTimer;

  List<int> barriers = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    40,
    60,
    80,
    100,
    120,
    140,
    160,
    180,
    200,
    220,
    240,
    260,
    280,
    300,
    320,
    340,
    360,
    39,
    59,
    79,
    99,
    119,
    139,
    159,
    179,
    199,
    219,
    239,
    259,
    279,
    299,
    319,
    339,
    359,
    379,
    740,
    741,
    742,
    743,
    744,
    745,
    746,
    747,
    748,
    749,
    750,
    751,
    752,
    753,
    754,
    755,
    756,
    757,
    758,
    759
  ];

  List<int> food = [];

  @override
  void initState() {
    super.initState();
    getFood();
    startGame();
  }

  void startGame() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (!gamePaused && !gameOver) {
        setState(() {
          mouthClosed = !mouthClosed;
          moveGhost();
          // Auto-move Pacman in current direction
          moveInDirection(pacmanDirection);
        });
      }
    });
  }

  void moveInDirection(Direction direction) {
    if (gameOver || gamePaused) return;

    setState(() {
      switch (direction) {
        case Direction.left:
          if (!barriers.contains(player - 1)) {
            player--;
            pacmanDirection = Direction.left;
          }
          break;
        case Direction.right:
          if (!barriers.contains(player + 1)) {
            player++;
            pacmanDirection = Direction.right;
          }
          break;
        case Direction.up:
          if (!barriers.contains(player - numberInRow)) {
            player -= numberInRow;
            pacmanDirection = Direction.up;
          }
          break;
        case Direction.down:
          if (!barriers.contains(player + numberInRow)) {
            player += numberInRow;
            pacmanDirection = Direction.down;
          }
          break;
      }
      eatFood();
    });
  }

  void moveGhost() {
    // Smarter ghost movement - tries to chase Pacman
    int ghostRow = ghost ~/ numberInRow;
    int ghostCol = ghost % numberInRow;
    int pacmanRow = player ~/ numberInRow;
    int pacmanCol = player % numberInRow;

    List<int> possibleMoves = [];

    // Add possible moves
    if (!barriers.contains(ghost - 1)) possibleMoves.add(ghost - 1);
    if (!barriers.contains(ghost + 1)) possibleMoves.add(ghost + 1);
    if (!barriers.contains(ghost - numberInRow))
      possibleMoves.add(ghost - numberInRow);
    if (!barriers.contains(ghost + numberInRow))
      possibleMoves.add(ghost + numberInRow);

    if (possibleMoves.isNotEmpty) {
      // Choose move that gets closer to Pacman
      ghost = possibleMoves.reduce((a, b) {
        int aRow = a ~/ numberInRow;
        int aCol = a % numberInRow;
        int bRow = b ~/ numberInRow;
        int bCol = b % numberInRow;

        double distA =
            sqrt(pow(aRow - pacmanRow, 2) + pow(aCol - pacmanCol, 2));
        double distB =
            sqrt(pow(bRow - pacmanRow, 2) + pow(bCol - pacmanCol, 2));

        return distA < distB ? a : b;
      });
    }

    if (ghost == player) {
      gameOver = true;
      showGameOverDialog();
    }
  }

  void getFood() {
    food.clear();
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  void checkGameWin() {
    if (food.isEmpty) {
      gameOver = true;
      showGameWinDialog();
    }
  }

  void showGameWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won!\nFinal Score: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      player = 190;
      ghost = 40;
      score = 0;
      gameOver = false;
      gamePaused = false;
      pacmanDirection = Direction.right;
      getFood();
      startGame();
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Final Score: $score'),
              SizedBox(height: 10),
              Text('Dots collected: $score'),
              Text('Dots remaining: ${food.length}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void eatFood() {
    if (food.contains(player)) {
      setState(() {
        food.remove(player);
        score++;
        checkGameWin();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            moveInDirection(Direction.left);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            moveInDirection(Direction.right);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            moveInDirection(Direction.up);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            moveInDirection(Direction.down);
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            setState(() {
              gamePaused = !gamePaused;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    moveInDirection(Direction.down);
                  } else if (details.delta.dy < 0) {
                    moveInDirection(Direction.up);
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) {
                    moveInDirection(Direction.right);
                  } else if (details.delta.dx < 0) {
                    moveInDirection(Direction.left);
                  }
                },
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (player == index) {
                      return Transform.rotate(
                        angle: pacmanDirection == Direction.right
                            ? 0
                            : pacmanDirection == Direction.down
                                ? pi / 2
                                : pacmanDirection == Direction.left
                                    ? pi
                                    : -pi / 2,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CustomPaint(
                            painter: PacmanPainter(mouthClosed),
                          ),
                        ),
                      );
                    } else if (ghost == index) {
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else if (barriers.contains(index)) {
                      return Container(
                        color: Colors.blue[900],
                      );
                    } else if (food.contains(index)) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        color: Colors.black,
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            gamePaused = !gamePaused;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          gamePaused ? 'PLAY' : 'PAUSE',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'RESET',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}

// Custom painter for Pacman with animated mouth
class PacmanPainter extends CustomPainter {
  final bool mouthClosed;

  PacmanPainter(this.mouthClosed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellow;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    if (mouthClosed) {
      canvas.drawCircle(center, radius, paint);
    } else {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          0.4, // start angle
          2 * pi - 0.8, // sweep angle
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(PacmanPainter oldDelegate) =>
      mouthClosed != oldDelegate.mouthClosed;
}
