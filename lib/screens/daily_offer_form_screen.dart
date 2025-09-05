import 'dart:convert';
import 'dart:io';
import 'package:bookstore_backoffice/utils/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _limitQuantityController = TextEditingController();

  File? _selectedImage;
  String? _imageBase64;
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
      _limitQuantityController.text =
          widget.offer!.limitQuantity?.toString() ?? '';
      _startDate = widget.offer!.startDate;
      _endDate = widget.offer!.endDate;
      _isActive = widget.offer!.isActive;
      _imageBase64 = widget.offer!.image;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _offerPriceController.dispose();
    _limitQuantityController.dispose();
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
                title: const Text('المعرض'),
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
                title: const Text('الكاميرا'),
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
                  title: const Text('حذف الصورة'),
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
        image: _imageBase64,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        limitQuantity:
            _limitQuantityController.text.trim().isEmpty
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
                  ? 'تم إنشاء العرض بنجاح'
                  : 'تم تعديل العرض بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
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
        title: Text(widget.offer == null ? 'عرض جديد' : 'تعديل العرض'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _saveOffer,
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
                _isLoading ? 'جارٍ الحفظ...' : 'حفظ',
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
              // Header
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
                      Icons.local_offer,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.offer == null
                                ? 'إنشاء عرض جديد'
                                : 'تعديل العرض',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'قم بتكوين عرضك الترويجي',
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

              // Basic Information
              Text(
                'المعلومات الأساسية',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان العرض *',
                  hintText: 'مثال: عرض خاص على كتب الخيال العلمي',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'العنوان مطلوب';
                  }
                  if (value.trim().length < 2 || value.trim().length > 150) {
                    return 'يجب أن يحتوي العنوان على ما بين 2 و150 حرفًا';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف *',
                  hintText: 'صف عرضك الترويجي',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الوصف مطلوب';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 32),

              // Offer Image
              Text(
                'صورة العرض',
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
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              _selectedImage != null
                                  ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : ImageHelper.buildImageFromBase64(
                                    _imageBase64,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(
                          _selectedImage != null || _imageBase64 != null
                              ? 'تغيير الصورة'
                              : 'إضافة صورة',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Pricing
              Text(
                'التسعير',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر الأصلي (€) *',
                        hintText: '29.99',
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'السعر الأصلي مطلوب';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'يجب أن يكون السعر أكبر من 0';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _offerPriceController,
                      decoration: const InputDecoration(
                        labelText: 'سعر العرض (€) *',
                        hintText: '19.99',
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'سعر العرض مطلوب';
                        }
                        final offerPrice = double.tryParse(value.trim());
                        final originalPrice = double.tryParse(
                          _originalPriceController.text.trim(),
                        );
                        if (offerPrice == null || offerPrice <= 0) {
                          return 'يجب أن يكون السعر أكبر من 0';
                        }
                        if (originalPrice != null &&
                            offerPrice >= originalPrice) {
                          return 'يجب أن يكون سعر العرض أقل من السعر الأصلي';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),

              if (calculatedDiscount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'الخصم: $calculatedDiscount%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'التوفير: ${(double.tryParse(_originalPriceController.text) ?? 0) - (double.tryParse(_offerPriceController.text) ?? 0)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Period and Quantity
              Text(
                'شروط العرض',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاريخ البدء *',
                          prefixIcon: Icon(Icons.calendar_today),
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
                          labelText: 'تاريخ الانتهاء *',
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _limitQuantityController,
                decoration: const InputDecoration(
                  labelText: 'الكمية المحدودة (اختياري)',
                  hintText: 'اتركه فارغًا لكمية غير محدودة',
                  prefixIcon: Icon(Icons.inventory),
                  helperText: 'يحدد عدد العناصر في العرض الترويجي',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final quantity = int.tryParse(value.trim());
                    if (quantity == null || quantity <= 0) {
                      return 'يجب أن تكون الكمية موجبة';
                    }
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 32),

              // Status
              Text(
                'حالة العرض',
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
                  title: const Text('العرض نشط'),
                  subtitle: Text(
                    _isActive ? 'العرض متاح ومرئي' : 'العرض غير مفعل',
                    style: TextStyle(
                      color: _isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  secondary: Icon(
                    _isActive ? Icons.visibility : Icons.visibility_off,
                    color: _isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
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
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveOffer,
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
                                  Text('جارٍ الحفظ...'),
                                ],
                              )
                              : Text(
                                widget.offer == null
                                    ? 'إنشاء العرض'
                                    : 'تعديل العرض',
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
