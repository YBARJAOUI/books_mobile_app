import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/responsive_layout.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = false;
  String searchQuery = '';
  String selectedCategory = 'Tous';

  // FIXED: Remove duplicates and ensure consistency
  final List<String> categories = [
    'Tous',
    'Fiction',
    'Non-Fiction',
    'Science-Fiction', // This was the problematic duplicate
    'Science',
    'Histoire',
    'Philosophie',
    'Art',
    'Cuisine',
    'Technologie',
    'Santé',
    'Jeunesse',
    'Romance',
    'Thriller',
    'Fantasy',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedBooks = await BookService.getAllBooks();
      setState(() {
        books = loadedBooks;

        // FIXED: Validate selectedCategory exists in books or reset to 'Tous'
        final bookCategories = books.map((book) => book.category).toSet();
        if (selectedCategory != 'Tous' &&
            !bookCategories.contains(selectedCategory)) {
          selectedCategory = 'Tous';
        }

        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des livres: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredBooks =
        books.where((book) {
          final matchesSearch =
              searchQuery.isEmpty ||
              book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              book.author.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesCategory =
              selectedCategory == 'Tous' || book.category == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();
  }

  Future<void> _deleteBook(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer ce livre ?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await BookService.deleteBook(id);
        _loadBooks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Livre supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          ResponsiveLayout.isMobile(context)
              ? AppBar(
                title: const Text('Gestion des Livres'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: _loadBooks,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualiser',
                  ),
                ],
              )
              : null,
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(child: _buildBooksContent()),
        ],
      ),
      floatingActionButton:
          ResponsiveLayout.isMobile(context)
              ? FloatingActionButton(
                onPressed: () => context.go('/books/new'),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: ResponsiveSpacing.getAllPadding(context),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius:
            ResponsiveLayout.isMobile(context)
                ? null
                : const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
      ),
      child: Column(
        children: [
          ResponsiveLayout(
            mobile: _buildMobileFilters(),
            tablet: _buildDesktopFilters(),
            desktop: _buildDesktopFilters(),
          ),
          SizedBox(height: ResponsiveSpacing.md),
          _buildStatsAndActions(),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher par titre, auteur ou ISBN...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              _applyFilters();
            });
          },
        ),
        SizedBox(height: ResponsiveSpacing.md),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items:
              categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
              _applyFilters();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher par titre, auteur ou ISBN...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _applyFilters();
              });
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.md),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items:
                categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
                _applyFilters();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsAndActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${filteredBooks.length} livre(s) trouvé(s)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        if (!ResponsiveLayout.isMobile(context))
          ElevatedButton.icon(
            onPressed: () => context.go('/books/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau Livre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildBooksContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des livres...'),
          ],
        ),
      );
    }

    if (filteredBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || selectedCategory != 'Tous'
                  ? 'Aucun livre trouvé avec ces critères'
                  : 'Aucun livre disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/books/new'),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter le premier livre'),
            ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildBooksList(),
      tablet: _buildBooksGrid(2),
      desktop: _buildBooksGrid(ResponsiveLayout.getGridColumns(context)),
    );
  }

  Widget _buildBooksList() {
    return ListView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        return _buildBookListTile(filteredBooks[index]);
      },
    );
  }

  Widget _buildBooksGrid(int columns) {
    return GridView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: _getResponsiveCardAspectRatio(
          context,
        ), // FIXED: Responsive aspect ratio
        crossAxisSpacing: ResponsiveSpacing.md,
        mainAxisSpacing: ResponsiveSpacing.md,
      ),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        return _buildBookCard(filteredBooks[index]);
      },
    );
  }

  // FIXED: Dynamic aspect ratio based on screen size
  double _getResponsiveCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 0.8; // Desktop - taller cards
    } else if (screenWidth > 768) {
      return 0.75; // Tablet - medium cards
    } else {
      return 0.7; // Mobile - shorter cards for better fit
    }
  }

  Widget _buildBookCard(Book book) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED: Responsive image container
          Expanded(
            flex: ResponsiveLayout.isMobile(context) ? 2 : 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child:
                  book.image != null && book.image!.isNotEmpty
                      ? _buildBookImage(book.image!)
                      : Icon(
                        Icons.book,
                        size: ResponsiveLayout.isMobile(context) ? 32 : 48,
                        color: Colors.grey[400],
                      ),
            ),
          ),
          // FIXED: Responsive content section
          Expanded(
            flex: ResponsiveLayout.isMobile(context) ? 3 : 2,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and author - takes most space
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                ResponsiveLayout.isMobile(context) ? 12 : 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveSpacing.xs),
                        Text(
                          book.author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize:
                                ResponsiveLayout.isMobile(context) ? 10 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveSpacing.xs),
                        // Category chip
                        if (book.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              book.category,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveLayout.isMobile(context) ? 8 : 10,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Price and stock info
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${book.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize:
                                ResponsiveLayout.isMobile(context) ? 12 : 14,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    book.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.isAvailable
                                    ? 'Disponible'
                                    : 'Indisponible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      ResponsiveLayout.isMobile(context)
                                          ? 8
                                          : 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed:
                              () => context.go(
                                '/books/edit/${book.id}',
                                extra: book.toJson(),
                              ),
                          icon: Icon(
                            Icons.edit,
                            size: ResponsiveLayout.isMobile(context) ? 16 : 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          tooltip: 'Modifier',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteBook(book.id!),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: ResponsiveLayout.isMobile(context) ? 16 : 20,
                          ),
                          tooltip: 'Supprimer',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookImage(String imageBase64) {
    try {
      if (imageBase64.startsWith('data:')) {
        final uri = Uri.parse(imageBase64);
        return Image.memory(
          uri.data!.contentAsBytes(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.book,
              size: ResponsiveLayout.isMobile(context) ? 32 : 48,
              color: Colors.grey[400],
            );
          },
        );
      } else {
        return Icon(
          Icons.book,
          size: ResponsiveLayout.isMobile(context) ? 32 : 48,
          color: Colors.grey[400],
        );
      }
    } catch (e) {
      return Icon(
        Icons.book,
        size: ResponsiveLayout.isMobile(context) ? 32 : 48,
        color: Colors.grey[400],
      );
    }
  }

  Widget _buildBookListTile(Book book) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.all(ResponsiveSpacing.md),
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child:
              book.image != null && book.image!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildBookImage(book.image!),
                  )
                  : const Icon(Icons.book),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auteur: ${book.author}'),
            Text('Prix: ${book.price.toStringAsFixed(2)} €'),
            Text('Catégorie: ${book.category}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: book.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book.isAvailable ? 'Disponible' : 'Indisponible',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed:
                  () => context.go(
                    '/books/edit/${book.id}',
                    extra: book.toJson(),
                  ),
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
            ),
            IconButton(
              onPressed: () => _deleteBook(book.id!),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
