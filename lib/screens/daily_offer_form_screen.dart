import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_offer.dart';
import '../services/daily_offer_service.dart';

class DailyOfferFormScreen extends StatefulWidget {
  final DailyOffer? offer;

  const DailyOfferFormScreen({super.key, this.offer});

  @override
  State<DailyOfferFormScreen> createState() => _DailyOfferFormScreenState();
}

class _DailyOfferFormScreenState extends State<DailyOfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _limitQuantityController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _titleController.text = widget.offer!.title;
      _descriptionController.text = widget.offer!.description;
      _originalPriceController.text = widget.offer!.originalPrice.toString();
      _offerPriceController.text = widget.offer!.offerPrice.toString();
      _imageUrlController.text = widget.offer!.imageUrl ?? '';
      _limitQuantityController.text = widget.offer!.limitQuantity?.toString() ?? '';
      _startDate = widget.offer!.startDate;
      _endDate = widget.offer!.endDate;
      _isActive = widget.offer!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _offerPriceController.dispose();
    _imageUrlController.dispose();
    _limitQuantityController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  int get calculatedDiscount {
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final offer = double.tryParse(_offerPriceController.text) ?? 0;
    if (original > 0 && offer > 0 && offer < original) {
      return ((original - offer) / original * 100).round();
    }
    return 0;
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final offer = DailyOffer(
        id: widget.offer?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        originalPrice: double.parse(_originalPriceController.text.trim()),
        offerPrice: double.parse(_offerPriceController.text.trim()),
        imageUrl: _imageUrlController.text.trim().isEmpty 
            ? null 
            : _imageUrlController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        limitQuantity: _limitQuantityController.text.trim().isEmpty 
            ? null 
            : int.parse(_limitQuantityController.text.trim()),
        soldQuantity: widget.offer?.soldQuantity ?? 0,
      );

      if (widget.offer == null) {
        await DailyOfferService.createDailyOffer(offer);
      } else {
        await DailyOfferService.updateDailyOffer(offer);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.offer == null 
                  ? 'Offre créée avec succès'
                  : 'Offre modifiée avec succès',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
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
        title: Text(widget.offer == null ? 'Nouvelle Offre' : 'Modifier l\'Offre'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveOffer,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(color: Colors.white),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'offre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  if (value.trim().length < 2 || value.trim().length > 150) {
                    return 'Le titre doit contenir entre 2 et 150 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix original (€) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prix original est requis';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Le prix doit être supérieur à 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _offerPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix de l\'offre (€) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prix de l\'offre est requis';
                        }
                        final offerPrice = double.tryParse(value.trim());
                        final originalPrice = double.tryParse(_originalPriceController.text.trim());
                        if (offerPrice == null || offerPrice <= 0) {
                          return 'Le prix doit être supérieur à 0';
                        }
                        if (originalPrice != null && offerPrice >= originalPrice) {
                          return 'Le prix d\'offre doit être inférieur au prix original';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (calculatedDiscount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Remise: $calculatedDiscount%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantité limitée (optionnel)',
                  border: OutlineInputBorder(),
                  helperText: 'Laissez vide pour une quantité illimitée',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final quantity = int.tryParse(value.trim());
                    if (quantity == null || quantity <= 0) {
                      return 'La quantité doit être positive';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_endDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Offre active'),
                subtitle: const Text('L\'offre est-elle disponible ?'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}