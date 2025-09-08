import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(BookstoreApp());
}

class BookstoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookstore Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    BooksScreen(),
    ClientsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المكتبة'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'الكتب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'العملاء',
          ),
        ],
      ),
    );
  }
}

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/books'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((json) => Book.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showAddBookDialog(),
            child: Text('إضافة كتاب جديد'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المؤلف: ${book.auteur}'),
                      Text('السعر: ${book.prix} \$'),
                      Text('الفئة: ${book.categorie}'),
                      Text('الحالة: ${book.available ? "متوفر" : "غير متوفر"}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteBook(book.title);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteBook(String title) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:8080/api/books/$title'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _loadBooks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الكتاب بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف الكتاب: ${e.toString()}')),
      );
    }
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final auteurController = TextEditingController();
    final prixController = TextEditingController();
    final categorieController = TextEditingController();
    final descriptionController = TextEditingController();
    bool available = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('إضافة كتاب جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'عنوان الكتاب'),
                ),
                TextField(
                  controller: auteurController,
                  decoration: InputDecoration(labelText: 'المؤلف'),
                ),
                TextField(
                  controller: prixController,
                  decoration: InputDecoration(labelText: 'السعر'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'الفئة'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: Text('متوفر'),
                  value: available,
                  onChanged: (value) => setState(() => available = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                await _addBook(
                  titleController.text,
                  auteurController.text,
                  double.tryParse(prixController.text) ?? 0.0,
                  categorieController.text,
                  descriptionController.text,
                  available,
                );
                Navigator.pop(context);
              },
              child: Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBook(String title, String auteur, double prix, String categorie, String description, bool available) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/books'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'auteur': auteur,
          'prix': prix,
          'categorie': categorie,
          'description': description,
          'available': available,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadBooks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة الكتاب بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إضافة الكتاب: ${e.toString()}')),
      );
    }
  }
}

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/clients'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clients = data.map((json) => Client.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showAddClientDialog(),
            child: Text('إضافة عميل جديد'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(client.nom),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رقم الهاتف: ${client.phoneNumber}'),
                      Text('العنوان: ${client.address}'),
                      Text('المدينة: ${client.city}'),
                      Text('الحالة: ${client.blacklisted ? "محظور" : "نشط"}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteClient(client.id!);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteClient(int id) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:8080/api/clients/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _loadClients();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف العميل بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف العميل: ${e.toString()}')),
      );
    }
  }

  void _showAddClientDialog() {
    final nomController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    bool blacklisted = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('إضافة عميل جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'الاسم'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'رقم الهاتف'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'العنوان'),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: 'المدينة'),
                ),
                SwitchListTile(
                  title: Text('محظور'),
                  value: blacklisted,
                  onChanged: (value) => setState(() => blacklisted = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                await _addClient(
                  nomController.text,
                  phoneController.text,
                  addressController.text,
                  cityController.text,
                  blacklisted,
                );
                Navigator.pop(context);
              },
              child: Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addClient(String nom, String phone, String address, String city, bool blacklisted) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/clients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nom,
          'phoneNumber': phone,
          'address': address,
          'city': city,
          'blacklisted': blacklisted,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadClients();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة العميل بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إضافة العميل: ${e.toString()}')),
      );
    }
  }
}

class Book {
  final String title;
  final String auteur;
  final String? description;
  final double prix;
  final String? imageBase64;
  final bool available;
  final String categorie;

  Book({
    required this.title,
    required this.auteur,
    this.description,
    required this.prix,
    this.imageBase64,
    this.available = true,
    required this.categorie,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      auteur: json['auteur'] ?? '',
      description: json['description'],
      prix: (json['prix'] ?? 0).toDouble(),
      imageBase64: json['imageBase64'],
      available: json['available'] ?? true,
      categorie: json['categorie'] ?? 'Non-Fiction',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'auteur': auteur,
      'description': description,
      'prix': prix,
      'imageBase64': imageBase64,
      'available': available,
      'categorie': categorie,
    };
  }
}

class Client {
  final int? id;
  final String nom;
  final String phoneNumber;
  final String address;
  final String city;
  final bool blacklisted;

  Client({
    this.id,
    required this.nom,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.blacklisted = false,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      blacklisted: json['blacklisted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'blacklisted': blacklisted,
    };
  }
}