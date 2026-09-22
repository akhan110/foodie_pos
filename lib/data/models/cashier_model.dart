class CashierModel {
  final String id;
  final String name;
  final String? email;
  final String role;
  final String storeName;
  final bool isActive;

  CashierModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    required this.storeName,
    required this.isActive,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    return CashierModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'cashier',
      storeName: json['store_name']?.toString() ?? 'Store #01',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'store_name': storeName,
      'is_active': isActive,
    };
  }
}

class AuthDataModel {
  final String accessToken;
  final String tokenType;
  final CashierModel user;

  AuthDataModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    return AuthDataModel(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      user: CashierModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}
