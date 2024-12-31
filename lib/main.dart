import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
          backgroundColor: Color(0xFF000B45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blue[900]!, width: 3),
          ),
          title: Text(
            'GAME OVER!',
            style: GoogleFonts.pressStart2p(
              textStyle: TextStyle(
                color: Colors.red,
                fontSize: 24,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Final Score: $score',
                style: GoogleFonts.pressStart2p(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Dots collected: $score',
                style: GoogleFonts.pressStart2p(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                'Dots remaining: ${food.length}',
                style: GoogleFonts.pressStart2p(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'PLAY AGAIN',
                  style: GoogleFonts.pressStart2p(
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
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
        backgroundColor: Color(0xFF000B45),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'PACMAN',
            style: GoogleFonts.pressStart2p(
              textStyle: TextStyle(
                color: Colors.yellow,
                fontSize: 28,
                shadows: [
                  Shadow(
                    color: Colors.yellow.withOpacity(0.5),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000B45),
                Color(0xFF000000),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue[900]!, width: 3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[900]!.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
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
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFF000B45),
                  border: Border(
                    top: BorderSide(color: Colors.blue[900]!, width: 3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[900]!,
                            Colors.blue[800]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.blue[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
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
                            backgroundColor: gamePaused
                                ? Colors.green[600]
                                : Colors.green[700],
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: Colors.green[300]!,
                                width: 2,
                              ),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            gamePaused ? 'PLAY' : 'PAUSE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow[700]!,
                                Colors.yellow[600]!
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.yellow[300]!,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.warning,
                              color: Colors.black87,
                              size: 30,
                            ),
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
