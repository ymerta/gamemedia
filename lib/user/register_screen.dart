import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/bottom_nav_bar.dart';
import 'login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _profileImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _profileImage = File(pickedFile.path);
        }
      });
    } catch (e) {
      print('Image picker error: $e');
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    if (_profileImage == null) {
      return '';
    }
    final ref = _storage.ref().child('profile_images').child('$userId.jpg');
    await ref.putFile(_profileImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String profileImageUrl = await _uploadProfileImage(userCredential.user!.uid);

      // Kullanıcı başarıyla kayıt olduysa, Firestore'a kullanıcı bilgilerini kaydet
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text,
        'profilePicture': profileImageUrl,
        'followers': [],
        'following': [],
        'favorites': [],
        'wishlist': [],
        'reviews': [],
      });

      print('Registration successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar(userId: userCredential.user!.uid)),
      );
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.add_a_photo, size: 50) : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefon Numarası',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifreyi Onayla',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Kayıt Ol'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
