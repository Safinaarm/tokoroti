// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // Untuk utf8.encode
import 'roti.dart'; // Pastikan roti.dart sudah diimpor dengan benar dan RotiScreen didefinisikan
import 'admin.dart'; // Pastikan admin.dart sudah diimpor dengan benar dan AdminScreen didefinisikan

void main() {
  runApp(TokoRotiApp());
}

class TokoRotiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet Rise',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink[300],
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.pink[700]),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final Client client;
  late final Databases databases;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://fra.cloud.appwrite.io/v1')
      ..setProject('684a553a0011273f7c07')
      ..setSelfSigned(status: true);
    databases = Databases(client);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await databases.listDocuments(
          databaseId: '684a556400142abfb7ab',
          collectionId: '684a5f58002d02b22181',
        );
        String hashedInput = _hashPassword(_passwordController.text);
        bool isAuthenticated = false;
        for (var doc in response.documents) {
          if (doc.data['email'] == _emailController.text &&
              doc.data['password'] == hashedInput) {
            isAuthenticated = true;
            break;
          }
        }
        if (isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login berhasil!')),
          );
          if (_emailController.text.toLowerCase().contains('@admin')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RotiScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email atau password salah!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[100]!, Colors.pink[200]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sweet Rise',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email', icon: Icon(Icons.email, color: Colors.pink[700])),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || value.isEmpty) ? 'Masukkan email' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password', icon: Icon(Icons.lock, color: Colors.pink[700])),
                        obscureText: true,
                        validator: (value) => (value == null || value.isEmpty) ? 'Masukkan password' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _login(context),
                        child: Text('Masuk'),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text('Belum punya akun? Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final Client client;
  late final Databases databases;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://fra.cloud.appwrite.io/v1')
      ..setProject('684a553a0011273f7c07')
      ..setSelfSigned(status: true);
    databases = Databases(client);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = ID.unique();
        String hashedPassword = _hashPassword(_passwordController.text);
        await databases.createDocument(
          databaseId: '684a556400142abfb7ab',
          collectionId: '684a5f58002d02b22181',
          documentId: userId,
          data: {
            'email': _emailController.text,
            'username': _usernameController.text,
            'password': hashedPassword,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
        print('Dokumen disimpan untuk userId: $userId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data tersimpan, silakan login terlebih dahulu')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[100]!, Colors.pink[200]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sweet Rise',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username', icon: Icon(Icons.person, color: Colors.pink[700])),
                        validator: (value) => (value == null || value.isEmpty) ? 'Masukkan username' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email', icon: Icon(Icons.email, color: Colors.pink[700])),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || value.isEmpty) ? 'Masukkan email' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password', icon: Icon(Icons.lock, color: Colors.pink[700])),
                        obscureText: true,
                        validator: (value) => (value == null || value.isEmpty) ? 'Masukkan password' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _register(context),
                        child: Text('Daftar'),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text('Sudah punya akun? Masuk'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}