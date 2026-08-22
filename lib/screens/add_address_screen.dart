import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../widgets/animated_button.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? existing;

  const AddAddressScreen({super.key, this.existing});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.existing?.address ?? '',
  );
  late final TextEditingController _building = TextEditingController(
    text: widget.existing?.building ?? '',
  );
  late final TextEditingController _floor = TextEditingController(
    text: widget.existing?.floor ?? '',
  );
  late final TextEditingController _apartment = TextEditingController(
    text: widget.existing?.apartment ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text:
        widget.existing?.phone ??
        (context.read<UserProvider>().user?.phone ?? ''),
  );
  late final double _lat = widget.existing?.lat ?? 30.0444;
  late final double _lng = widget.existing?.lng ?? 31.2357;
  late bool _isDefault = widget.existing?.isDefault ?? false;
  bool _located = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _located = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('تم تحديد موقعك الحالي على الخريطة 📡'),
      ),
    );
  }

  Future<void> _save() async {
    if (_address.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب العنوان بالتفصيل يا صاحبي')),
      );
      return;
    }
    if (!RegExp(
      r'^01[0125][0-9]{8}$',
    ).hasMatch(_phone.text.replaceAll(RegExp(r'\s'), ''))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم التواصل لازم يبقى رقم موبايل مصري صحيح'),
        ),
      );
      return;
    }
    final user = context.read<UserProvider>();
    await user.upsertAddress(
      Address(
        id: widget.existing?.id ?? 'a_${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim().isEmpty ? 'عنواني' : _title.text.trim(),
        address: _address.text.trim(),
        building: _building.text.trim(),
        floor: _floor.text.trim(),
        apartment: _apartment.text.trim(),
        phone: _phone.text.trim(),
        lat: _lat,
        lng: _lng,
        isDefault:
            _isDefault ||
            widget.existing == null && user.user!.addresses.isEmpty,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('العنوان اتحفظ ✅'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'إضافة عنوان' : 'تعديل العنوان'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _field(_title, 'اسم العنوان', hint: 'المنزل، العمل...'),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('افتراضي'),
                selected: _isDefault,
                onSelected: (_) => setState(() => _isDefault = !_isDefault),
                avatar: Icon(
                  _isDefault ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            _address,
            'العنوان بالتفصيل',
            hint: 'الشارع والحي والمنطقة',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(_building, 'رقم العمارة')),
              const SizedBox(width: 10),
              Expanded(child: _field(_floor, 'الدور')),
              const SizedBox(width: 10),
              Expanded(child: _field(_apartment, 'الشقة')),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            _phone,
            'رقم للتواصل عند التوصيل',
            keyboard: TextInputType.phone,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.map_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'الموقع على الخريطة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.background,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _MapGridPainter(),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutBack,
                          transform: Matrix4.translationValues(
                            0,
                            _located ? -6 : 4,
                            0,
                          )..rotateZ(_located ? .1 : -.06),
                          child: const Text(
                            '📍',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    _located
                        ? 'تم التحديد (${_lat.toStringAsFixed(3)}, ${_lng.toStringAsFixed(3)})'
                        : 'تحديد موقعي الحالي',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AnimatedButton(
            label: 'حفظ العنوان',
            icon: Icons.save_outlined,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboard,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: .6)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final road = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-10, size.height * .62),
      Offset(size.width, size.height * .35),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
