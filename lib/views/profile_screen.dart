import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).loadUser();
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
          child: Consumer<HomeViewModel>(builder: (context, viewModel, child) {
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
                  const Row(
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
                  const SizedBox(height: 45),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(11)),
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
                ],
              );
            } else if (viewModel.errorMessage != null) {
              return Center(child: Text('Hata: ${viewModel.errorMessage!}'));
            } else {
              return const SizedBox.shrink();
            }
          }),
        ),
      ),
    );
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
}
