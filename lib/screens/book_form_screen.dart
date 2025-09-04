import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  String? _imageBase64;

  String _selectedLanguage = 'francais';
  String _selectedCategory = 'Fiction';
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _languages = ['francais', 'arabe', 'anglais'];
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'Histoire',
    'Philosophie',
    'Art',
    'Cuisine',
    'Technologie',
    'Santé',
    'Jeunesse',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _descriptionController.text = widget.book!.description ?? '';
      _priceController.text = widget.book!.price.toString();
      _selectedLanguage = widget.book!.language;
      _selectedCategory = widget.book!.category;
      _isAvailable = widget.book!.isAvailable;
      _imageBase64 = widget.book!.image;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _selectedImage = File(image.path);
                      _imageBase64 = base64Encode(bytes);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _selectedImage = File(image.path);
                      _imageBase64 = base64Encode(bytes);
                    });
                  }
                },
              ),
              if (_selectedImage != null || _imageBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Supprimer l\'image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImage = null;
                      _imageBase64 = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final book = Book(
        id: widget.book?.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        language: _selectedLanguage,
        category: _selectedCategory,
        isAvailable: _isAvailable,
        image: _imageBase64,
      );

      if (widget.book == null) {
        await BookService.createBook(book);
      } else {
        await BookService.updateBook(book);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.book == null
                  ? 'Livre créé avec succès'
                  : 'Livre modifié avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
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
        title: Text(
          widget.book == null ? 'Nouveau Livre' : 'Modifier le Livre',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _saveBook,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isLoading ? 'Enregistrement...' : 'Enregistrer',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book == null
                                ? 'Créer un nouveau livre'
                                : 'Modifier le livre',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Remplissez les informations du livre',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Informations principales
              Text(
                'Informations principales',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  hintText: 'Entrez le titre du livre',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  if (value.trim().length < 2 || value.trim().length > 200) {
                    return 'Le titre doit contenir entre 2 et 200 caractères';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Auteur *',
                  hintText: 'Entrez le nom de l\'auteur',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'auteur est requis';
                  }
                  if (value.trim().length < 2 || value.trim().length > 100) {
                    return 'L\'auteur doit contenir entre 2 et 100 caractères';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez le livre (optionnel)',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 32),

              // Image Section
              Text(
                'Image du livre',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null || _imageBase64 != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image:
                              _selectedImage != null
                                  ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : _imageBase64 != null
                                  ? DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(_imageBase64!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(
                          _selectedImage != null || _imageBase64 != null
                              ? 'Changer l\\image'
                              : 'Ajouter une image',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Prix
              Text(
                'Prix',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (€) *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prix est requis';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Le prix doit être supérieur à 0';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 32),

              // Catégorie et langue
              Text(
                'Classification',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Langue *',
                  prefixIcon: Icon(Icons.language),
                ),
                items:
                    _languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Row(
                          children: [
                            Icon(
                              language == 'francais'
                                  ? Icons.flag
                                  : language == 'arabe'
                                  ? Icons.flag_outlined
                                  : Icons.flag_circle,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(language.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une langue';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Disponibilité
              Text(
                'Disponibilité',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Livre disponible'),
                  subtitle: Text(
                    _isAvailable
                        ? 'Le livre est disponible à la vente'
                        : 'Le livre n\'est pas disponible à la vente',
                    style: TextStyle(
                      color: _isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                  secondary: Icon(
                    _isAvailable ? Icons.check_circle : Icons.cancel,
                    color: _isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Enregistrement...'),
                                ],
                              )
                              : Text(
                                widget.book == null ? 'Créer' : 'Modifier',
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
