import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/login_screen.dart';

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
      onPressed: () async {
        // Kullanıcının giriş yapıp yapmadığını kontrol et
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getString('access_token') != null;

        if (isLoggedIn) {
          // Kullanıcı giriş yapmışsa, favorileri güncelle
          setState(() {
            isFavorite = !isFavorite;
          });
          widget.onFavoriteChanged();
        } else {
          // Kullanıcı giriş yapmamışsa, login gerekliliği hakkında bilgilendir
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Required'),
                  content: const Text('You must log in to add to favorites.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dialog'u kapat
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dialog'u kapat
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                );
              },
            );
          }
        }
      },
    );
  }
}
