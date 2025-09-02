import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_offer.dart';
import '../services/daily_offer_service.dart';
import 'daily_offer_form_screen.dart';

class DailyOffersScreen extends StatefulWidget {
  const DailyOffersScreen({super.key});

  @override
  State<DailyOffersScreen> createState() => _DailyOffersScreenState();
}

class _DailyOffersScreenState extends State<DailyOffersScreen> {
  List<DailyOffer> offers = [];
  bool isLoading = false;
  String searchQuery = '';

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
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des offres: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteOffer(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette offre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
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
            const SnackBar(content: Text('Offre supprimée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  List<DailyOffer> get filteredOffers {
    if (searchQuery.isEmpty) {
      return offers;
    }
    return offers.where((offer) {
      return offer.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          offer.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres du Jour'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadOffers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par titre ou description...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyOfferFormScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadOffers();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle Offre'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOffers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune offre trouvée',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOffers.length,
                        itemBuilder: (context, index) {
                          final offer = filteredOffers[index];
                          final isValid = offer.isValidOffer;
                          final isExpired = DateTime.now().isAfter(offer.endDate);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${offer.calculatedDiscountPercentage}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                offer.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${offer.originalPrice.toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${offer.offerPrice.toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Période: ${DateFormat('dd/MM/yyyy').format(offer.startDate)} - ${DateFormat('dd/MM/yyyy').format(offer.endDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (offer.limitQuantity != null)
                                    Text(
                                      'Quantité limitée: ${offer.soldQuantity}/${offer.limitQuantity}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: offer.isActive 
                                              ? (isValid 
                                                  ? Colors.green 
                                                  : (isExpired ? Colors.grey : Colors.orange))
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          offer.isActive 
                                              ? (isValid 
                                                  ? 'Valide' 
                                                  : (isExpired ? 'Expirée' : 'En attente'))
                                              : 'Inactive',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DailyOfferFormScreen(
                                            offer: offer,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadOffers();
                                      }
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteOffer(offer.id!),
                                    icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}