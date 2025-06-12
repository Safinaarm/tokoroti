import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'main.dart'; // Pastikan main.dart mengandung definisi MyApp

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Client _client;
  late Databases _databases;
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _transaksiList = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    _client = Client()
      ..setEndpoint('https://fra.cloud.appwrite.io/v1')
      ..setProject('684a553a0011273f7c07')
      ..setSelfSigned(status: true);
    _databases = Databases(_client);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userResponse = await _databases.listDocuments(
        databaseId: '684a556400142abfb7ab',
        collectionId: '684a5f58002d02b22181',
      );

      final transaksiResponse = await _databases.listDocuments(
        databaseId: '684a556400142abfb7ab',
        collectionId: '684a908600060ad5d7a0',
      );

      setState(() {
        _userList = userResponse.documents.map((doc) {
          return {
            'id': doc.data['id']?.toString() ?? '',
            'email': doc.data['email']?.toString() ?? 'Tidak Diketahui',
            'username': doc.data['username']?.toString() ?? 'Tidak Diketahui',
            'created_at': doc.data['created_at']?.toString() ?? 'Tidak Diketahui',
          };
        }).toList();

        _transaksiList = transaksiResponse.documents.map((doc) {
          return {
            'id': doc.data['id']?.toString() ?? '',
            'name': doc.data['name']?.toString() ?? 'Tidak Diketahui',
            'alamat': doc.data['alamat']?.toString() ?? 'Tidak Diketahui',
            'total': doc.data['total']?.toString() ?? '0.0',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TokoRotiApp()), // Menggunakan MyApp dari main.dart
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: _selectedIndex == 0
                  ? _buildUserList()
                  : _buildTransaksiList(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        backgroundColor: Colors.blueAccent,
        tooltip: 'Refresh Data',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pengguna',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: _userList.isEmpty
              ? Center(child: Text('Tidak ada pengguna ditemukan'))
              : ListView.builder(
                  itemCount: _userList.length,
                  itemBuilder: (context, index) {
                    final user = _userList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          child: Text(user['username'][0].toUpperCase()),
                        ),
                        title: Text(
                          user['username'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text('ID: ${user['id']}'),
                            Text('Email: ${user['email']}'),
                            Text('Dibuat: ${user['created_at']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransaksiList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Transaksi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: _transaksiList.isEmpty
              ? Center(child: Text('Tidak ada transaksi ditemukan'))
              : ListView.builder(
                  itemCount: _transaksiList.length,
                  itemBuilder: (context, index) {
                    final transaksi = _transaksiList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.receipt, size: 20),
                        ),
                        title: Text(
                          transaksi['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text('ID: ${transaksi['id']}'),
                            Text('Alamat: ${transaksi['alamat']}'),
                            Text('Total: Rp ${transaksi['total']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}