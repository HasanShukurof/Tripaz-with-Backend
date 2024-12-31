import 'package:flutter/material.dart';

class HeartButton extends StatefulWidget {
  final bool initialIsFavorite;
  final VoidCallback onFavoriteChanged;

  const HeartButton({
    super.key,
    this.initialIsFavorite = false,
    required this.onFavoriteChanged,
  });

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
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        widget.onFavoriteChanged();
      },
    );
  }
}
