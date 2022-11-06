import 'package:day07_tic_tac_toe/board_tile.dart';
import 'package:day07_tic_tac_toe/tile_state.dart';
import 'package:flutter/material.dart';
import 'package:invert_colors/invert_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  var _boardState = List.filled(9, TileState.EMPTY);
  var player;
  var _currentTurn = TileState.CROSS;
  // var curr_player = players[_currentTurn];
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Container(
          child: Center(
            child: Stack(children: [
              Align(
                  alignment: Alignment.center,
                  child: Image.asset('images/board.png')),
              Align(alignment: Alignment.center,child:_boardTiles()),
              Column(
                // mainAxisAlignment: MainAxisAlignment.,
                children: [
                  Container(
                    height: 50,
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      height: 40,
                      width: 95,
                      child: FlatButton(
                        onPressed: _resetGame,
                        child: Image.asset(
                          'images/replay.png',
                          fit: BoxFit.contain,
                        ),
                      )),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _boardTiles() {
    return Builder(builder: (context) {
      final boardDimension = MediaQuery.of(context).size.width;
      final tileDimension = boardDimension / 3;
      player = _currentTurn == TileState.CROSS ? 'X' : 'O';
      return Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // color: Colors.amber,
              height: 140,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text(
                "$player's turn",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.bold),
              ),
              height: 50,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: boardDimension,
                height: boardDimension,
                child: Column(
                    children:
                        // Text("data"),
                        chunk(_boardState, 3).asMap().entries.map((entry) {
                  final chunkIndex = entry.key;
                  final tileStateChunk = entry.value;

                  return Row(
                    children: tileStateChunk.asMap().entries.map((innerEntry) {
                      final innerIndex = innerEntry.key;
                      final tileState = innerEntry.value;
                      final tileIndex = (chunkIndex * 3) + innerIndex;

                      return BoardTile(
                          tileState: tileState,
                          dimension: tileDimension,
                          onPressed: () => {
                                _updateTileStateForIndex(tileIndex),
                                print(_count)
                              });
                    }).toList(),
                  );
                }).toList())),
          ),
        ],
      );
    });
  }

  void _updateTileStateForIndex(int selectedIndex) {
    if (_boardState[selectedIndex] == TileState.EMPTY) {
      setState(() {
        _count += 1;
        _boardState[selectedIndex] = _currentTurn;
        _currentTurn = _currentTurn == TileState.CROSS
            ? TileState.CIRCLE
            : TileState.CROSS;
      });

      final winner = _findWinner();
      if (winner != null) {
        print('Winner is: $winner');
        _showWinnerDialog(winner);
      } else if (_count == 9) {
        print('Match is a draw!!');
        DrawDialog();
      }
    }
  }

  TileState _findWinner() {
    TileState Function(int, int, int) winnerForMatch = (a, b, c) {
      if (_boardState[a] != TileState.EMPTY) {
        if ((_boardState[a] == _boardState[b]) &&
            (_boardState[b] == _boardState[c])) {
          return _boardState[a];
        }
      }
      return null;
    };

    final checks = [
      winnerForMatch(0, 1, 2),
      winnerForMatch(3, 4, 5),
      winnerForMatch(6, 7, 8),
      winnerForMatch(0, 3, 6),
      winnerForMatch(1, 4, 7),
      winnerForMatch(2, 5, 8),
      winnerForMatch(0, 4, 8),
      winnerForMatch(2, 4, 6),
    ];

    TileState winner;
    for (int i = 0; i < checks.length; i++) {
      if (checks[i] != null) {
        winner = checks[i];
        break;
      }
    }

    return winner;
  }

  void _showWinnerDialog(TileState tileState) {
    final context = navigatorKey.currentState.overlay.context;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Winner'),
            content: Image.asset(
                tileState == TileState.CROSS ? 'images/x.png' : 'images/o.png'),
            actions: [
              FlatButton(
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                  child: Text('New Game'))
            ],
          );
        });
  }

  void DrawDialog() {
    final context = navigatorKey.currentState.overlay.context;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Draw'),
            content: Text("You ran out of moves!!"),
            actions: [
              FlatButton(
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                  child: Text('New Game'))
            ],
          );
        });
  }

  void _resetGame() {
    setState(() {
      _count = 0;
      _boardState = List.filled(9, TileState.EMPTY);
      _currentTurn = TileState.CROSS;
    });
  }
}
