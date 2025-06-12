// ignore_for_file: prefer_final_fields, prefer_const_constructors_in_immutables
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'transaksi.dart'; // Import the new TransaksiScreen
import 'main.dart'; // Import main.dart untuk navigasi logout

class RotiScreen extends StatefulWidget {
  @override
  _RotiScreenState createState() => _RotiScreenState();
}

class _RotiScreenState extends State<RotiScreen> {
  late Client _client;
  late Databases _databases;
  List<Map<String, dynamic>> _rotiList = [];
  final Map<String, int> _cart = {};
  final List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = true;

  final String _defaultImageUrl =
      'https://th.bing.com/th/id/OIP.fS97PLWosq8Lm7d6IWNrVQHaHa?rs=1&pid=ImgDetMain';

  final List<Map<String, dynamic>> _dummyRotiList = [
    {
      'id': '1',
      'nama': 'Roti Coklat',
      'harga': 15000,
      'lokasi': 'Surabaya',
      'gambar': 'https://th.bing.com/th/id/OIP.fS97PLWosq8Lm7d6IWNrVQHaHa?rs=1&pid=ImgDetMain',
      'deskripsi': 'Roti lembut dengan isian coklat meleleh yang kaya rasa.',
    },
    {
      'id': '2',
      'nama': 'Roti Keju',
      'harga': 18000,
      'lokasi': 'Surabaya',
      'gambar': 'https://th.bing.com/th/id/OIP.fS97PLWosq8Lm7d6IWNrVQHaHa?rs=1&pid=ImgDetMain',
      'deskripsi': 'Roti gurih dengan taburan keju cheddar premium.',
    },
    {
      'id': '3',
      'nama': 'Roti Tawar',
      'harga': 12000,
      'lokasi': 'Surabaya',
      'gambar': 'https://th.bing.com/th/id/OIP.fS97PLWosq8Lm7d6IWNrVQHaHa?rs=1&pid=ImgDetMain',
      'deskripsi': 'Roti tawar klasik, cocok untuk sarapan atau camilan.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _client = Client()
        .setEndpoint('https://fra.cloud.appwrite.io/v1')
        .setProject('684a553a0011273f7c07');
    _databases = Databases(_client);
    _fetchRotiData();
  }

  Future<void> _fetchRotiData() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: '684a556400142abfb7ab',
        collectionId: '684a8c8a001a68d11bed',
      );

      setState(() {
        _rotiList = response.documents.map((doc) {
          return {
            'id': doc.data['id']?.toString() ?? '',
            'nama': doc.data['nama']?.toString() ?? 'Unnamed',
            'harga': doc.data['harga'] ?? 0,
            'lokasi': doc.data['lokasi']?.toString() ?? 'Unknown',
            'gambar': _defaultImageUrl,
            'deskripsi': 'Roti lezat dari ${doc.data['lokasi'] ?? 'toko kami'}',
          };
        }).toList();
        _isLoading = false;
      });

      if (_rotiList.isEmpty) {
        print('No documents found. Using dummy data.');
        setState(() {
          _rotiList = _dummyRotiList;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data roti, menggunakan data dummy.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching data: $e\n$stackTrace');
      setState(() {
        _rotiList = _dummyRotiList;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data roti: $e. Menggunakan data dummy.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addToCart(String nama, int harga) {
    setState(() {
      _cart[nama] = (_cart[nama] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nama ditambahkan ke keranjang!'),
        backgroundColor: Colors.pink[300],
      ),
    );
  }

  void _showDescriptionDialog(BuildContext context, Map<String, dynamic> roti) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DescriptionPage(
          roti: roti,
          onAddToCart: () => _addToCart(roti['nama'], roti['harga']),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Anda yakin ingin log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TokoRotiApp()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Roti', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransaksiScreen(
                        cart: _cart,
                        rotiList: _rotiList,
                        orderHistory: _orderHistory,
                        showHistory: false, // Buka keranjang
                      ),
                    ),
                  );
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cart.values.fold(0, (sum, qty) => sum + qty).toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransaksiScreen(
                    cart: _cart,
                    rotiList: _rotiList,
                    orderHistory: _orderHistory,
                    showHistory: true, // Buka riwayat
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pink[400]))
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.pink[300],
                  child: Row(
                    children: [
                      Icon(Icons.store, color: Colors.white),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Lokasi Toko: Surabaya',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _rotiList.isEmpty
                      ? Center(child: Text('Tidak ada data roti tersedia.'))
                      : GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _rotiList.length,
                          itemBuilder: (context, index) {
                            final roti = _rotiList[index];
                            return GestureDetector(
                              onTap: () => _showDescriptionDialog(context, roti),
                              child: Card(
                                elevation: 4,
                                color: Colors.pink[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        roti['gambar'],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) => Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            roti['nama'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pink[800],
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Rp ${roti['harga']}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          ),
                                          Text(
                                            roti['lokasi'],
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          ),
                                          SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _addToCart(
                                                    roti['nama'], roti['harga']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.pink[400],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                              ),
                                              child: Text(
                                                'Tambah',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLogoutDialog,
        backgroundColor: Colors.pink[400],
        mini: true,
        child: Icon(Icons.logout, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _DescriptionPage extends StatelessWidget {
  final Map<String, dynamic> roti;
  final VoidCallback onAddToCart;

  _DescriptionPage({required this.roti, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roti['nama'], style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  roti['gambar'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                roti['nama'],
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800]),
              ),
              SizedBox(height: 8),
              Text(roti['deskripsi'], style: TextStyle(color: Colors.grey[800])),
              SizedBox(height: 8),
              Text('Harga: Rp ${roti['harga']}',
                  style: TextStyle(color: Colors.pink[600])),
              Text('Lokasi: ${roti['lokasi']}',
                  style: TextStyle(color: Colors.pink[600])),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    onAddToCart();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Tambah ke Keranjang',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}