import 'package:flutter/material.dart';

class HeartButton extends StatefulWidget {
  final bool initialIsFavorite;
  final VoidCallback onFavoriteChanged;
  final int tourId;

  const HeartButton(
      {super.key,
      required this.initialIsFavorite,
      required this.onFavoriteChanged,
      required this.tourId});

  @override
  _HeartButtonState createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  void didUpdateWidget(HeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsFavorite != oldWidget.initialIsFavorite) {
      setState(() {
        _isFavorite = widget.initialIsFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        widget.onFavoriteChanged();
      },
    );
  }
}
