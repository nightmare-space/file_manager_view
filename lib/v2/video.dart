// import 'package:better_player/better_player.dart';
import 'package:better_player/better_player.dart';
import 'package:file_manager_view/file_manager_view.dart';
import 'package:flutter/material.dart';
import 'package:signale/signale.dart';

class SerieExample extends StatefulWidget {
  const SerieExample({Key key, this.path}) : super(key: key);
  final String path;

  @override
  _SerieExampleState createState() => _SerieExampleState();
}

class _SerieExampleState extends State<SerieExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: widget.path.startsWith('http')
              ? BetterPlayer.network(
                  Uri.encodeFull(widget.path),
                  betterPlayerConfiguration: BetterPlayerConfiguration(
                    // aspectRatio: 9 / 16,
                    fullScreenByDefault: false,
                    autoPlay: true,
                    fit: BoxFit.contain,
                  ),
                )
              : BetterPlayer.file(
                  widget.path,
                  betterPlayerConfiguration: BetterPlayerConfiguration(
                    // aspectRatio: 9 / 16,
                    fullScreenByDefault: false,
                    autoPlay: true,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  }
}
