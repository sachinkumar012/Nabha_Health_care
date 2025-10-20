import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderStorageService {
  static const String _ordersKey = 'pharmacy_orders';
  static const String _orderCounterKey = 'order_counter';

  // Singleton pattern
  static final OrderStorageService _instance = OrderStorageService._internal();
  factory OrderStorageService() => _instance;
  OrderStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a new order
  Future<bool> saveOrder(PharmacyOrder order) async {
    try {
      await _initPrefs();

      print('💾 Attempting to save order: ${order.orderId}');
      print('👤 User ID: ${order.userId}');

      final orders = await getAllOrders();
      print('📦 Current orders count: ${orders.length}');

      orders.add(order);

      final ordersJson = orders.map((order) => order.toJson()).toList();
      final success =
          await _prefs!.setString(_ordersKey, jsonEncode(ordersJson));

      if (success) {
        print('✅ Order saved successfully: ${order.orderId}');
        print('📦 Total orders now: ${orders.length}');
      } else {
        print('❌ Failed to save order to SharedPreferences');
      }

      return success;
    } catch (e) {
      print('❌ Error saving order: $e');
      return false;
    }
  }

  /// Get all orders for the current user
  Future<List<PharmacyOrder>> getAllOrders() async {
    try {
      await _initPrefs();

      final ordersJson = _prefs!.getString(_ordersKey);
      if (ordersJson == null) return [];

      final ordersList = jsonDecode(ordersJson) as List;
      return ordersList
          .map((orderJson) => PharmacyOrder.fromJson(orderJson))
          .toList();
    } catch (e) {
      print('❌ Error loading orders: $e');
      return [];
    }
  }

  /// Get orders for a specific user
  Future<List<PharmacyOrder>> getOrdersForUser(String userId) async {
    print('🔍 Getting orders for user ID: $userId');

    final allOrders = await getAllOrders();
    print('📦 Total orders in storage: ${allOrders.length}');

    final userOrders =
        allOrders.where((order) => order.userId == userId).toList();
    print('👤 Orders for user $userId: ${userOrders.length}');

    for (var order in userOrders) {
      print('   Found order: ${order.orderId} - ${order.status.name}');
    }

    return userOrders;
  }

  /// Get a specific order by ID
  Future<PharmacyOrder?> getOrderById(String orderId) async {
    final allOrders = await getAllOrders();
    try {
      return allOrders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing order
  Future<bool> updateOrder(PharmacyOrder updatedOrder) async {
    try {
      await _initPrefs();

      final orders = await getAllOrders();
      final index =
          orders.indexWhere((order) => order.orderId == updatedOrder.orderId);

      if (index == -1) {
        print('❌ Order not found: ${updatedOrder.orderId}');
        return false;
      }

      orders[index] = updatedOrder;

      final ordersJson = orders.map((order) => order.toJson()).toList();
      final success =
          await _prefs!.setString(_ordersKey, jsonEncode(ordersJson));

      print('✅ Order updated successfully: ${updatedOrder.orderId}');
      return success;
    } catch (e) {
      print('❌ Error updating order: $e');
      return false;
    }
  }

  /// Delete an order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _initPrefs();

      final orders = await getAllOrders();
      orders.removeWhere((order) => order.orderId == orderId);

      final ordersJson = orders.map((order) => order.toJson()).toList();
      final success =
          await _prefs!.setString(_ordersKey, jsonEncode(ordersJson));

      print('✅ Order deleted successfully: $orderId');
      return success;
    } catch (e) {
      print('❌ Error deleting order: $e');
      return false;
    }
  }

  /// Generate a unique order ID
  Future<String> generateOrderId() async {
    await _initPrefs();

    final counter = _prefs!.getInt(_orderCounterKey) ?? 1000;
    final newCounter = counter + 1;
    await _prefs!.setInt(_orderCounterKey, newCounter);

    // Format: NH + timestamp + counter
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'NH${timestamp.toString().substring(8)}$newCounter';
  }

  /// Get order statistics
  Future<OrderStatistics> getOrderStatistics(String userId) async {
    final orders = await getOrdersForUser(userId);

    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final pendingOrders = orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.packed ||
            o.status == OrderStatus.shipped ||
            o.status == OrderStatus.outForDelivery)
        .length;
    final cancelledOrders =
        orders.where((o) => o.status == OrderStatus.cancelled).length;

    final totalSpent = orders
        .where((o) => o.paymentInfo.paymentStatus == PaymentStatus.completed)
        .fold(0.0, (sum, order) => sum + order.totalAmount);

    return OrderStatistics(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      cancelledOrders: cancelledOrders,
      totalSpent: totalSpent,
    );
  }

  /// Clear all orders (for testing purposes)
  Future<bool> clearAllOrders() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_ordersKey);
      await _prefs!.remove(_orderCounterKey);
      print('✅ All orders cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing orders: $e');
      return false;
    }
  }

  /// Search orders by various criteria
  Future<List<PharmacyOrder>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var orders = await getOrdersForUser(userId);

    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      orders = orders
          .where((order) =>
              order.orderId.toLowerCase().contains(lowercaseQuery) ||
              order.items.any(
                  (item) => item.name.toLowerCase().contains(lowercaseQuery)) ||
              order.customerInfo.name.toLowerCase().contains(lowercaseQuery))
          .toList();
    }

    if (status != null) {
      orders = orders.where((order) => order.status == status).toList();
    }

    if (paymentMethod != null) {
      orders = orders
          .where((order) => order.paymentInfo.paymentMethod == paymentMethod)
          .toList();
    }

    if (fromDate != null) {
      orders = orders
          .where((order) =>
              order.orderDate.isAfter(fromDate) ||
              order.orderDate.isAtSameMomentAs(fromDate))
          .toList();
    }

    if (toDate != null) {
      orders = orders
          .where((order) =>
              order.orderDate.isBefore(toDate) ||
              order.orderDate.isAtSameMomentAs(toDate))
          .toList();
    }

    // Sort by order date (newest first)
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return orders;
  }
}

class OrderStatistics {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final double totalSpent;

  OrderStatistics({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.totalSpent,
  });
}
