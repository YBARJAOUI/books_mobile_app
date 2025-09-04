import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/daily_offer.dart';
import '../services/daily_offer_service.dart';
import '../utils/responsive_layout.dart';
import '../utils/image_helper.dart';

class DailyOffersScreen extends StatefulWidget {
  const DailyOffersScreen({super.key});

  @override
  State<DailyOffersScreen> createState() => _DailyOffersScreenState();
}

class _DailyOffersScreenState extends State<DailyOffersScreen> {
  List<DailyOffer> offers = [];
  List<DailyOffer> filteredOffers = [];
  bool isLoading = false;
  String searchQuery = '';
  bool showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedOffers = await DailyOfferService.getAllDailyOffers();
      setState(() {
        offers = loadedOffers;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des offres: $e'),
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
    filteredOffers =
        offers.where((offer) {
          final matchesSearch =
              searchQuery.isEmpty ||
              offer.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              offer.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          final matchesStatus = !showActiveOnly || offer.isActive;

          return matchesSearch && matchesStatus;
        }).toList();
  }

  Future<void> _deleteOffer(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette offre ?',
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
        await DailyOfferService.deleteDailyOffer(id);
        _loadOffers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offre supprimée avec succès'),
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

  void _showOfferActions(DailyOffer offer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Offer info
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageHelper.buildImageFromBase64(
                          offer.image,
                          fit: BoxFit.cover,
                          placeholder: Icon(
                            Icons.local_offer,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${offer.originalPrice.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${offer.offerPrice.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${offer.calculatedDiscountPercentage}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go(
                            '/daily-offers/edit/${offer.id}',
                            extra: offer.toJson(),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteOffer(offer.id!);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  int _getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 3; // Desktop: 3 offres par ligne
    if (screenWidth > 768) return 2; // Tablette: 2 offres par ligne
    return 1; // Mobile: 1 offre par ligne
  }

  @override
  Widget build(BuildContext context) {
    final activeOffers = offers.where((o) => o.isActive).length;
    final expiredOffers =
        offers.where((o) => DateTime.now().isAfter(o.endDate)).length;

    return Scaffold(
      appBar:
          ResponsiveLayout.isMobile(context)
              ? AppBar(
                title: const Text('Offres Spéciales'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: _loadOffers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualiser',
                  ),
                ],
              )
              : null,
      body: Column(
        children: [
          _buildHeaderSection(activeOffers, expiredOffers),
          Expanded(child: _buildOffersContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/daily-offers/new'),
        child: const Icon(Icons.add),
        tooltip: 'Nouvelle offre',
      ),
    );
  }

  Widget _buildHeaderSection(int activeOffers, int expiredOffers) {
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
          // Statistiques
          ResponsiveLayout(
            mobile: _buildMobileStats(activeOffers, expiredOffers),
            tablet: _buildDesktopStats(activeOffers, expiredOffers),
            desktop: _buildDesktopStats(activeOffers, expiredOffers),
          ),
          SizedBox(height: ResponsiveSpacing.md),

          // Filtres
          ResponsiveLayout(
            mobile: _buildMobileFilters(),
            tablet: _buildDesktopFilters(),
            desktop: _buildDesktopFilters(),
          ),
          SizedBox(height: ResponsiveSpacing.sm),
          _buildStatsAndActions(),
        ],
      ),
    );
  }

  Widget _buildMobileStats(int activeOffers, int expiredOffers) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                offers.length.toString(),
                Colors.blue,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Actives',
                activeOffers.toString(),
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Expirées',
                expiredOffers.toString(),
                Colors.orange,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStats(int activeOffers, int expiredOffers) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total', offers.length.toString(), Colors.blue),
        ),
        SizedBox(width: ResponsiveSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Actives',
            activeOffers.toString(),
            Colors.green,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Expirées',
            expiredOffers.toString(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveSpacing.sm,
        horizontal: ResponsiveSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveLayout.isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher par titre ou description...',
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
        SizedBox(height: ResponsiveSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('Actives uniquement'),
                selected: showActiveOnly,
                onSelected: (selected) {
                  setState(() {
                    showActiveOnly = selected;
                    _applyFilters();
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.green.withValues(alpha: 0.2),
                checkmarkColor: Colors.green,
              ),
            ),
          ],
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
              hintText: 'Rechercher par titre ou description...',
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
        FilterChip(
          label: const Text('Actives uniquement'),
          selected: showActiveOnly,
          onSelected: (selected) {
            setState(() {
              showActiveOnly = selected;
              _applyFilters();
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.green.withValues(alpha: 0.2),
          checkmarkColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatsAndActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${filteredOffers.length} offre(s) affichée(s)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        if (!ResponsiveLayout.isMobile(context))
          ElevatedButton.icon(
            onPressed: () => context.go('/daily-offers/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle Offre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildOffersContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des offres...'),
          ],
        ),
      );
    }

    if (filteredOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || showActiveOnly
                  ? 'Aucune offre trouvée avec ces critères'
                  : 'Aucune offre disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/daily-offers/new'),
              icon: const Icon(Icons.add),
              label: const Text('Créer la première offre'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridColumns(context),
        childAspectRatio: ResponsiveLayout.isMobile(context) ? 1.2 : 1.1,
        crossAxisSpacing: ResponsiveSpacing.md,
        mainAxisSpacing: ResponsiveSpacing.md,
      ),
      itemCount: filteredOffers.length,
      itemBuilder: (context, index) {
        final offer = filteredOffers[index];
        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildOfferCard(DailyOffer offer) {
    final isValid = offer.isValidOffer;
    final isExpired = DateTime.now().isAfter(offer.endDate);

    return GestureDetector(
      onTap: () => _showOfferActions(offer),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'offre
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageHelper.buildImageFromBase64(
                      offer.image,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.local_offer,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),

                    // Badge de remise
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '-${offer.calculatedDiscountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    // Statut
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              offer.isActive
                                  ? (isValid
                                      ? Colors.green
                                      : (isExpired
                                          ? Colors.grey
                                          : Colors.orange))
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer.isActive
                              ? (isValid
                                  ? 'Valide'
                                  : (isExpired ? 'Expirée' : 'En attente'))
                              : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(ResponsiveSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Prix
                    Row(
                      children: [
                        Text(
                          '${offer.originalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${offer.offerPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Période
                    Text(
                      '${DateFormat('dd/MM').format(offer.startDate)} - ${DateFormat('dd/MM/yy').format(offer.endDate)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
