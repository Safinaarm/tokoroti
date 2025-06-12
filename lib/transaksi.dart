import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class TransaksiScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> rotiList;
  final List<Map<String, dynamic>> orderHistory;
  final bool showHistory;

  TransaksiScreen({
    required this.cart,
    required this.rotiList,
    required this.orderHistory,
    required this.showHistory,
  });

  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  late Client _client;
  late Databases _databases;
  final _nameController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _client = Client()
      ..setEndpoint('https://fra.cloud.appwrite.io/v1')
      ..setProject('684a553a0011273f7c07')
      ..setSelfSigned(status: true);
    _databases = Databases(_client);
  }

  Future<void> _checkout(BuildContext context) async {
    if (_nameController.text.isEmpty || _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama dan alamat wajib diisi!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionId = ID.unique();
      final total = widget.cart.entries.fold(0.0, (sum, entry) {
        final roti = widget.rotiList.firstWhere(
          (r) => r['nama'] == entry.key,
          orElse: () => {'nama': entry.key, 'harga': 0.0},
        );
        return sum + (roti['harga'].toDouble() * entry.value);
      }).toDouble();

      await _databases.createDocument(
        databaseId: '684a556400142abfb7ab',
        collectionId: '684a908600060ad5d7a0',
        documentId: transactionId,
        data: {
          'id': transactionId,
          'name': _nameController.text,
          'alamat': _alamatController.text,
          'total': total,
        },
      );

      // Simpan ke riwayat lokal
      final order = {
        'id': transactionId,
        'name': _nameController.text,
        'alamat': _alamatController.text,
        'total': total,
      };
      widget.orderHistory.add(order);

      // Kosongkan keranjang
      widget.cart.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout berhasil!')),
      );
      Navigator.pop(context); // Kembali ke RotiScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout gagal: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showHistory ? 'Riwayat Pesanan' : 'Keranjang Belanja'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/appwrite_logo.png'),
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: widget.showHistory
            ? _buildOrderHistory()
            : _buildCart(),
      ),
    );
  }

  Widget _buildCart() {
    if (widget.cart.isEmpty) {
      return Center(child: Text('Keranjang kosong!'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final entry = widget.cart.entries.elementAt(index);
              final roti = widget.rotiList.firstWhere(
                (r) => r['nama'] == entry.key,
                orElse: () => {'nama': entry.key, 'harga': 0.0},
              );
              final totalHarga = roti['harga'].toDouble() * entry.value;
              return ListTile(
                title: Text('${entry.key} x${entry.value}'),
                subtitle: Text('Rp ${totalHarga.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      if (widget.cart[entry.key]! > 1) {
                        widget.cart[entry.key] = widget.cart[entry.key]! - 1;
                      } else {
                        widget.cart.remove(entry.key);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Nama'),
        ),
        TextField(
          controller: _alamatController,
          decoration: InputDecoration(labelText: 'Alamat'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _checkout(context),
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Checkout'),
        ),
      ],
    );
  }

  Widget _buildOrderHistory() {
    if (widget.orderHistory.isEmpty) {
      return Center(child: Text('Riwayat pesanan kosong!'));
    }

    return ListView.builder(
      itemCount: widget.orderHistory.length,
      itemBuilder: (context, index) {
        final order = widget.orderHistory[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text('Pesanan #${order['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${order['name']}'),
                Text('Alamat: ${order['alamat']}'),
                Text('Total: Rp ${order['total'].toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}