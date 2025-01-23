import 'package:flutter/material.dart';

class HeartButton extends StatefulWidget {
  final bool initialIsFavorite;
  final int tourId;
  final Function() onFavoriteChanged;

  const HeartButton({
    Key? key,
    required this.initialIsFavorite,
    required this.tourId,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
  }

  @override
  void didUpdateWidget(HeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite) {
      isFavorite = widget.initialIsFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.white,
      ),
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
        widget.onFavoriteChanged();
      },
    );
  }
}
