// ignore_for_file: prefer_final_fields, prefer_const_constructors_in_immutables
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'transaksi.dart';
import 'main.dart';

class RotiScreen extends StatefulWidget {
  const RotiScreen({Key? key}) : super(key: key);

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
            'harga': (doc.data['harga'] is num) ? doc.data['harga'].toInt() : 0,
            'lokasi': doc.data['lokasi']?.toString() ?? 'Unknown',
            'gambar': doc.data['images']?.toString() ?? _defaultImageUrl,
            'deskripsi': doc.data['deskripsi']?.toString() ??
                'Roti lezat dari ${doc.data['lokasi'] ?? 'toko kami'}',
          };
        }).toList();
        _isLoading = false;
      });

      if (_rotiList.isEmpty) {
        setState(() {
          _rotiList = _dummyRotiList;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data roti, menggunakan data dummy.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
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
        backgroundColor: const Color(0xFFF02E65),
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
        title: const Text('Konfirmasi Logout'),
        content: const Text('Anda yakin ingin log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TokoRotiApp()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Toko Roti',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF02E65), Color(0xFF4A4A4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransaksiScreen(
                        cart: _cart,
                        rotiList: _rotiList,
                        orderHistory: _orderHistory,
                        showHistory: false,
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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cart.values.fold(0, (sum, qty) => sum + qty).toString(),
                      style: const TextStyle(color: Color(0xFFF02E65), fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransaksiScreen(
                    cart: _cart,
                    rotiList: _rotiList,
                    orderHistory: _orderHistory,
                    showHistory: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF02E65)),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF02E65),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Lokasi Toko: Surabaya',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _rotiList.isEmpty
                      ? const Center(child: Text('Tidak ada data roti tersedia.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _rotiList.length,
                          itemBuilder: (context, index) {
                            final roti = _rotiList[index];
                            return InkWell(
                              onTap: () => _showDescriptionDialog(context, roti),
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.network(
                                        roti['gambar'] ?? _defaultImageUrl,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            roti['nama'] ?? 'Unnamed',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF02E65),
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${roti['harga'] ?? 0}',
                                            style: const TextStyle(
                                              color: Color(0xFF4A4A4F),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            roti['lokasi'] ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xFF4A4A4F),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _addToCart(
                                                  roti['nama'] ?? 'Unnamed',
                                                  roti['harga'] ?? 0,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF02E65),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                              ),
                                              child: const Text(
                                                'Tambah',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
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
        backgroundColor: const Color(0xFFF02E65),
        mini: true,
        tooltip: 'Logout',
        child: const Icon(Icons.logout, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _DescriptionPage extends StatelessWidget {
  final Map<String, dynamic> roti;
  final VoidCallback onAddToCart;

  const _DescriptionPage({Key? key, required this.roti, required this.onAddToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          roti['nama'] ?? 'Unnamed',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF02E65), Color(0xFF4A4A4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  roti['gambar'] ?? 'https://th.bing.com/th/id/OIP.fS97PLWosq8Lm7d6IWNrVQHaHa?rs=1&pid=ImgDetMain',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                roti['nama'] ?? 'Unnamed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF02E65),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                roti['deskripsi'] ?? 'Deskripsi tidak tersedia.',
                style: const TextStyle(color: Color(0xFF4A4A4F)),
              ),
              const SizedBox(height: 8),
              Text(
                'Harga: Rp ${roti['harga'] ?? 0}',
                style: const TextStyle(color: Color(0xFFF02E65)),
              ),
              Text(
                'Lokasi: ${roti['lokasi'] ?? 'Unknown'}',
                style: const TextStyle(color: Color(0xFFF02E65)),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    onAddToCart();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF02E65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}