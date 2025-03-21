import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'booking_screen.dart';
import 'register_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'terms_condition_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      viewModel.loadUser();
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('access_token') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: SingleChildScrollView(
          child: isLoggedIn ? _buildLoggedInProfile() : _buildGuestProfile(),
        ),
      ),
    );
  }

  Widget _buildGuestProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0XFFF0FA3E2),
                child: Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'You are not logged in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Log in to make a reservation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFF0FA3E2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0XFFF0A7BAB)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Color(0XFFF0A7BAB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Image.asset('assets/images/divider.png'),
        const SizedBox(height: 30),
        const Text(
          'Derleng Legal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 20),
        Container(
          height: 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.edit_document),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Terms and Condition'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.policy_rounded),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Privacy policy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Image.asset('assets/images/divider.png'),
        const SizedBox(height: 30),
        const Text(
          'Contact Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: 'assets/images/instagram.png',
              onTap: () => _launchUrl('https://www.instagram.com/tripaz.az/'),
            ),
            _buildSocialButton(
              icon: 'assets/images/facebook.jpeg',
              onTap: () => _launchUrl(
                  'https://www.facebook.com/profile.php?id=61571571547943'),
            ),
            _buildSocialButton(
              icon: 'assets/images/email.jpeg',
              onTap: () => _launchUrl('mailto:info@tripaz.az'),
            ),
            _buildSocialButton(
              icon: 'assets/images/whatsapp.png',
              onTap: () => _launchUrl('https://wa.me/994102651470'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone, color: Color(0XFFF0A7BAB)),
                  SizedBox(width: 10),
                  Text(
                    'Telefon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(left: 34),
                child: Text('+994 10 265 14 70'),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.email, color: Color(0XFFF0A7BAB)),
                  SizedBox(width: 10),
                  Text(
                    'E-posta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(left: 34),
                child: Text('info@tripaz.az'),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.location_on, color: Color(0XFFF0A7BAB)),
                  SizedBox(width: 10),
                  Text(
                    'Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(left: 34),
                child: Text('Baku, Azerbaijan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLoggedInProfile() {
    return Consumer<HomeViewModel>(builder: (context, viewModel, child) {
      if (viewModel.user != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipOval(
                    child: viewModel.isUserLoading
                        ? Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : (viewModel.user!.profileImageUrl != null
                            ? _buildProfileImage(
                                viewModel.user!.profileImageUrl!)
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )),
                  ),
                ),
                const SizedBox(width: 30),
                Text(
                  viewModel.user!.userName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17),
                )
              ],
            ),
            const SizedBox(height: 30),
            Image.asset('assets/images/divider.png'),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Booking'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Wishlist'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.chevron_right),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Image.asset('assets/images/divider.png'),
            const SizedBox(height: 30),
            const Text(
              'Derleng Legal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsConditionScreen()),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.edit_document),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Terms and Condition'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.policy_rounded),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Privacy policy'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset('assets/images/divider.png'),
            const SizedBox(height: 30),
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  icon: 'assets/images/instagram.png',
                  onTap: () =>
                      _launchUrl('https://www.instagram.com/tripaz.az/'),
                ),
                _buildSocialButton(
                  icon: 'assets/images/facebook.jpeg',
                  onTap: () => _launchUrl(
                      'https://www.facebook.com/profile.php?id=61571571547943'),
                ),
                _buildSocialButton(
                  icon: 'assets/images/email.jpeg',
                  onTap: () => _launchUrl('mailto:info@tripaz.az'),
                ),
                _buildSocialButton(
                  icon: 'assets/images/whatsapp.png',
                  onTap: () => _launchUrl('https://wa.me/994102651470'),
                ),
              ],
            ),
            const SizedBox(height: 45),
            GestureDetector(
              onTap: () async {
                try {
                  // Tüm local storage'ı temizle
                  final prefs = await SharedPreferences.getInstance();
                  await prefs
                      .clear(); // access_token, user_name ve diğer tüm verileri siler

                  if (mounted) {
                    setState(() {
                      isLoggedIn = false;
                    });
                  }
                } catch (e) {
                  print("Logout error: $e");
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                // Kullanıcıya onay dialogu göster
                final bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to delete your account? This action cannot be undone.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  try {
                    await Provider.of<HomeViewModel>(context, listen: false)
                        .deleteUser();

                    if (mounted) {
                      // Tüm local storage'ı temizle
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      setState(() {
                        isLoggedIn = false;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account deletion failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else if (viewModel.errorMessage != null) {
        return Center(child: Text('Hata: ${viewModel.errorMessage!}'));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }

  Widget _buildProfileImage(String base64String) {
    try {
      Uint8List bytes = base64.decode(base64String);
      return Image.memory(bytes, width: 90, height: 90, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        width: 90,
        height: 90,
        color: Colors.grey.shade300,
        child: const Icon(
          Icons.person,
          size: 50,
          color: Colors.white,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        Provider.of<HomeViewModel>(context, listen: false)
            .uploadNewProfileImage(_image!);
      }
    } catch (e) {
      print("Error pick image : $e");
    }
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset(
            icon,
            width: 30,
            height: 30,
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
