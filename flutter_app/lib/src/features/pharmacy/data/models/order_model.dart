class PharmacyOrder {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final OrderCustomerInfo customerInfo;
  final OrderPaymentInfo paymentInfo;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final double totalAmount;
  final double deliveryFee;
  final String? trackingNumber;
  final List<OrderStatusUpdate> statusHistory;
  final String? notes;

  PharmacyOrder({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.customerInfo,
    required this.paymentInfo,
    required this.status,
    required this.orderDate,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.totalAmount,
    this.deliveryFee = 0.0,
    this.trackingNumber,
    required this.statusHistory,
    this.notes,
  });

  factory PharmacyOrder.fromJson(Map<String, dynamic> json) {
    return PharmacyOrder(
      orderId: json['orderId'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      customerInfo: OrderCustomerInfo.fromJson(json['customerInfo']),
      paymentInfo: OrderPaymentInfo.fromJson(json['paymentInfo']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate']),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'])
          : null,
      totalAmount: json['totalAmount'].toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0.0,
      trackingNumber: json['trackingNumber'],
      statusHistory: (json['statusHistory'] as List)
          .map((update) => OrderStatusUpdate.fromJson(update))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'customerInfo': customerInfo.toJson(),
      'paymentInfo': paymentInfo.toJson(),
      'status': status.name,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'trackingNumber': trackingNumber,
      'statusHistory': statusHistory.map((update) => update.toJson()).toList(),
      'notes': notes,
    };
  }

  PharmacyOrder copyWith({
    String? orderId,
    String? userId,
    List<OrderItem>? items,
    OrderCustomerInfo? customerInfo,
    OrderPaymentInfo? paymentInfo,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    double? totalAmount,
    double? deliveryFee,
    String? trackingNumber,
    List<OrderStatusUpdate>? statusHistory,
    String? notes,
  }) {
    return PharmacyOrder(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      customerInfo: customerInfo ?? this.customerInfo,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      statusHistory: statusHistory ?? this.statusHistory,
      notes: notes ?? this.notes,
    );
  }
}

class OrderItem {
  final String medicineId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final String? dosage;
  final String? manufacturer;

  OrderItem({
    required this.medicineId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.dosage,
    this.manufacturer,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      medicineId: json['medicineId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      dosage: json['dosage'],
      manufacturer: json['manufacturer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'dosage': dosage,
      'manufacturer': manufacturer,
    };
  }

  double get totalPrice => price * quantity;
}

class OrderCustomerInfo {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? street;
  final String? pincode;
  final String? city;
  final String? state;

  OrderCustomerInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.street,
    this.pincode,
    this.city,
    this.state,
  });

  factory OrderCustomerInfo.fromJson(Map<String, dynamic> json) {
    return OrderCustomerInfo(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      street: json['street'],
      pincode: json['pincode'],
      city: json['city'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'street': street,
      'pincode': pincode,
      'city': city,
      'state': state,
    };
  }
}

class OrderPaymentInfo {
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final String? transactionId;
  final DateTime? paymentDate;
  final double amountPaid;

  OrderPaymentInfo({
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentId,
    this.transactionId,
    this.paymentDate,
    required this.amountPaid,
  });

  factory OrderPaymentInfo.fromJson(Map<String, dynamic> json) {
    return OrderPaymentInfo(
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
        orElse: () => PaymentMethod.cod,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      paymentId: json['paymentId'],
      transactionId: json['transactionId'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      amountPaid: json['amountPaid'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'paymentId': paymentId,
      'transactionId': transactionId,
      'paymentDate': paymentDate?.toIso8601String(),
      'amountPaid': amountPaid,
    };
  }
}

class OrderStatusUpdate {
  final OrderStatus status;
  final DateTime timestamp;
  final String? message;
  final String? location;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
    this.location,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'location': location,
    };
  }
}

enum OrderStatus {
  pending('Pending', 'Order is being processed'),
  confirmed('Confirmed', 'Order confirmed'),
  processing('Processing', 'Preparing your medicines'),
  packed('Packed', 'Order packed and ready'),
  shipped('Shipped', 'Order is on the way'),
  outForDelivery('Out for Delivery', 'Order is out for delivery'),
  delivered('Delivered', 'Order delivered successfully'),
  cancelled('Cancelled', 'Order cancelled'),
  returned('Returned', 'Order returned');

  const OrderStatus(this.title, this.description);
  final String title;
  final String description;
}

enum PaymentMethod {
  cod('Cash on Delivery'),
  online('Online Payment');

  const PaymentMethod(this.title);
  final String title;
}

enum PaymentStatus {
  pending('Pending'),
  completed('Completed'),
  failed('Failed'),
  refunded('Refunded');

  const PaymentStatus(this.title);
  final String title;
}
