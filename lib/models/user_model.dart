class Address {
  final String id;
  final String title;
  final String address;
  final String building;
  final String floor;
  final String apartment;
  final String phone;
  final double lat;
  final double lng;
  final bool isDefault;

  const Address({
    required this.id,
    required this.title,
    required this.address,
    required this.building,
    required this.floor,
    required this.apartment,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  String get fullAddress {
    final parts = [
      address,
      if (building.isNotEmpty) 'عمارة $building',
      if (floor.isNotEmpty) 'الدور $floor',
      if (apartment.isNotEmpty) 'شقة $apartment',
    ];
    return parts.join(' - ');
  }

  Address copyWith({
    String? id,
    String? title,
    String? address,
    String? building,
    String? floor,
    String? apartment,
    String? phone,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'address': address,
    'building': building,
    'floor': floor,
    'apartment': apartment,
    'phone': phone,
    'lat': lat,
    'lng': lng,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    title: json['title'] as String,
    address: json['address'] as String,
    building: json['building'] as String? ?? '',
    floor: json['floor'] as String? ?? '',
    apartment: json['apartment'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble() ?? 30.0444,
    lng: (json['lng'] as num?)?.toDouble() ?? 31.2357,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}

class UserModel {
  final String uid;
  final String phone;
  final String name;
  final List<Address> addresses;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.phone,
    required this.name,
    required this.addresses,
    required this.createdAt,
  });

  Address? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  UserModel copyWith({
    String? uid,
    String? phone,
    String? name,
    List<Address>? addresses,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'phone': phone,
    'name': name,
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    phone: json['phone'] as String,
    name: json['name'] as String? ?? '',
    addresses: ((json['addresses'] as List?) ?? [])
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num).toInt(),
    ),
  );
}
