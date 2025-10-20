import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import 'order_details_page.dart';

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage>
    with TickerProviderStateMixin {
  final OrderStorageService _orderService = OrderStorageService();
  final TextEditingController _searchController = TextEditingController();

  List<PharmacyOrder> _orders = [];
  List<PharmacyOrder> _filteredOrders = [];
  OrderStatistics? _statistics;
  bool _isLoading = true;

  OrderStatus? _selectedStatus;
  PaymentMethod? _selectedPaymentMethod;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider);
      print('🔍 Loading orders for user: ${user?.id}');

      if (user != null) {
        final orders = await _orderService.getOrdersForUser(user.id);

        // If no orders exist, create sample orders for testing
        if (orders.isEmpty) {
          print('📦 No orders found, creating sample orders for testing...');
          await _createSampleOrders(user.id);
          final updatedOrders = await _orderService.getOrdersForUser(user.id);
          final stats = await _orderService.getOrderStatistics(user.id);

          setState(() {
            _orders = updatedOrders;
            _filteredOrders = updatedOrders;
            _statistics = stats;
            _isLoading = false;
          });
        } else {
          final stats = await _orderService.getOrderStatistics(user.id);

          print('📦 Found ${orders.length} orders for user ${user.id}');
          for (var order in orders) {
            print(
                '   Order: ${order.orderId} - Status: ${order.status.name} - Amount: ₹${order.totalAmount}');
          }

          setState(() {
            _orders = orders;
            _filteredOrders = orders;
            _statistics = stats;
            _isLoading = false;
          });
        }
      } else {
        print('❌ No user logged in');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading orders: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createSampleOrders(String userId) async {
    print('🎯 Creating sample orders for user: $userId');

    try {
      // Sample Order 1 - Delivered
      final order1 = PharmacyOrder(
        orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}_1',
        userId: userId,
        items: [
          OrderItem(
            medicineId: 'med_001',
            name: 'Paracetamol 500mg',
            price: 25.0,
            quantity: 2,
            dosage: 'Tablet',
            manufacturer: 'Apollo Pharmacy',
          ),
          OrderItem(
            medicineId: 'med_002',
            name: 'Vitamin D3',
            price: 180.0,
            quantity: 1,
            dosage: 'Capsule',
            manufacturer: 'HealthKart',
          ),
        ],
        customerInfo: OrderCustomerInfo(
          name: 'Sachin Kumar Raj',
          email: 'sachinyadav887780@gmail.com',
          phone: '9318496221',
          address: 'Satnampura, Phagwara',
          street: 'Main Road',
          pincode: '144401',
        ),
        paymentInfo: OrderPaymentInfo(
          paymentMethod: PaymentMethod.online,
          paymentStatus: PaymentStatus.completed,
          paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
          transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          paymentDate: DateTime.now().subtract(const Duration(days: 5)),
          amountPaid: 205.0,
        ),
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 7)),
        estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
        totalAmount: 205.0,
        deliveryFee: 0.0,
        statusHistory: [
          OrderStatusUpdate(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
            message: 'Order placed successfully',
          ),
          OrderStatusUpdate(
            status: OrderStatus.confirmed,
            timestamp: DateTime.now().subtract(const Duration(days: 6)),
            message: 'Payment confirmed and order processing started',
          ),
          OrderStatusUpdate(
            status: OrderStatus.processing,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            message: 'Your medicines are being prepared',
          ),
          OrderStatusUpdate(
            status: OrderStatus.shipped,
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            message: 'Order shipped and out for delivery',
          ),
          OrderStatusUpdate(
            status: OrderStatus.delivered,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            message: 'Order delivered successfully',
          ),
        ],
      );

      // Sample Order 2 - In Transit
      final order2 = PharmacyOrder(
        orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}_2',
        userId: userId,
        items: [
          OrderItem(
            medicineId: 'med_003',
            name: 'Crocin Advance',
            price: 15.0,
            quantity: 1,
            dosage: 'Tablet',
            manufacturer: 'Apollo Pharmacy',
          ),
          OrderItem(
            medicineId: 'med_004',
            name: 'Hand Sanitizer',
            price: 45.0,
            quantity: 2,
            dosage: 'Bottle',
            manufacturer: 'MedPlus',
          ),
        ],
        customerInfo: OrderCustomerInfo(
          name: 'Sachin Kumar Raj',
          email: 'sachinyadav887780@gmail.com',
          phone: '9318496221',
          address: 'Satnampura, Phagwara',
          street: 'Main Road',
          pincode: '144401',
        ),
        paymentInfo: OrderPaymentInfo(
          paymentMethod: PaymentMethod.cod,
          paymentStatus: PaymentStatus.pending,
          paymentId: null,
          transactionId: null,
          paymentDate: null,
          amountPaid: 105.0,
        ),
        status: OrderStatus.shipped,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
        totalAmount: 105.0,
        deliveryFee: 0.0,
        statusHistory: [
          OrderStatusUpdate(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            message: 'Order placed successfully',
          ),
          OrderStatusUpdate(
            status: OrderStatus.confirmed,
            timestamp:
                DateTime.now().subtract(const Duration(days: 2, hours: 2)),
            message: 'Order confirmed and processing started',
          ),
          OrderStatusUpdate(
            status: OrderStatus.processing,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            message: 'Your medicines are being prepared',
          ),
          OrderStatusUpdate(
            status: OrderStatus.shipped,
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            message: 'Order shipped and out for delivery',
          ),
        ],
      );

      // Sample Order 3 - Processing
      final order3 = PharmacyOrder(
        orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}_3',
        userId: userId,
        items: [
          OrderItem(
            medicineId: 'med_005',
            name: 'Multivitamin Tablets',
            price: 320.0,
            quantity: 1,
            dosage: 'Bottle',
            manufacturer: 'HealthKart',
          ),
        ],
        customerInfo: OrderCustomerInfo(
          name: 'Sachin Kumar Raj',
          email: 'sachinyadav887780@gmail.com',
          phone: '9318496221',
          address: 'Satnampura, Phagwara',
          street: 'Main Road',
          pincode: '144401',
        ),
        paymentInfo: OrderPaymentInfo(
          paymentMethod: PaymentMethod.online,
          paymentStatus: PaymentStatus.completed,
          paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}_3',
          transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}_3',
          paymentDate: DateTime.now().subtract(const Duration(hours: 4)),
          amountPaid: 320.0,
        ),
        status: OrderStatus.processing,
        orderDate: DateTime.now().subtract(const Duration(hours: 4)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
        totalAmount: 320.0,
        deliveryFee: 0.0,
        statusHistory: [
          OrderStatusUpdate(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            message: 'Order placed successfully',
          ),
          OrderStatusUpdate(
            status: OrderStatus.confirmed,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            message: 'Payment confirmed and order processing started',
          ),
          OrderStatusUpdate(
            status: OrderStatus.processing,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            message: 'Your medicines are being prepared',
          ),
        ],
      );

      // Save all sample orders
      await _orderService.saveOrder(order1);
      await _orderService.saveOrder(order2);
      await _orderService.saveOrder(order3);

      print('✅ Sample orders created successfully!');
    } catch (e) {
      print('❌ Error creating sample orders: $e');
    }
  }

  void _filterOrders() {
    final user = ref.read(userProvider);
    if (user == null) return;

    setState(() {
      _filteredOrders = _orders.where((order) {
        bool matchesSearch = true;
        bool matchesStatus = true;
        bool matchesPayment = true;

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          matchesSearch = order.orderId.toLowerCase().contains(query) ||
              order.items
                  .any((item) => item.name.toLowerCase().contains(query));
        }

        // Status filter
        if (_selectedStatus != null) {
          matchesStatus = order.status == _selectedStatus;
        }

        // Payment method filter
        if (_selectedPaymentMethod != null) {
          matchesPayment =
              order.paymentInfo.paymentMethod == _selectedPaymentMethod;
        }

        return matchesSearch && matchesStatus && matchesPayment;
      }).toList();

      // Sort by order date (newest first)
      _filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedPaymentMethod = null;
      _filteredOrders = _orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                _buildStatisticsCard(),
                _buildSearchAndFilters(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(_filteredOrders),
                      _buildOrdersList(_filteredOrders
                          .where((o) => _isPendingStatus(o.status))
                          .toList()),
                      _buildOrdersList(_filteredOrders
                          .where((o) => o.status == OrderStatus.delivered)
                          .toList()),
                      _buildOrdersList(_filteredOrders
                          .where((o) => o.status == OrderStatus.cancelled)
                          .toList()),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _orders.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final user = ref.read(userProvider);
                if (user != null) {
                  await _createSampleOrders(user.id);
                  _loadOrders();
                }
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Sample Orders'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  bool _isPendingStatus(OrderStatus status) {
    return status == OrderStatus.pending ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.processing ||
        status == OrderStatus.packed ||
        status == OrderStatus.shipped ||
        status == OrderStatus.outForDelivery;
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Orders',
              _statistics!.totalOrders.toString(),
              Icons.shopping_bag,
              AppColors.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Completed',
              _statistics!.completedOrders.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Pending',
              _statistics!.pendingOrders.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Total Spent',
              '₹${_statistics!.totalSpent.toStringAsFixed(0)}',
              Icons.currency_rupee,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search orders by ID or medicine name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterOrders();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _filterOrders(),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Clear Filters'),
                  onSelected: (_) => _clearFilters(),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.title),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                          _filterOrders();
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<PharmacyOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start shopping to see your orders here',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(PharmacyOrder order) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(order: order),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status.title,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Order details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.orderDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.medical_services,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items preview
              Text(
                order.items.take(2).map((item) => item.name).join(', ') +
                    (order.items.length > 2
                        ? ' and ${order.items.length - 2} more'
                        : ''),
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        order.paymentInfo.paymentMethod == PaymentMethod.online
                            ? Icons.payment
                            : Icons.money,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentInfo.paymentMethod.title,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.processing:
      case OrderStatus.packed:
        return Colors.blue;
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
