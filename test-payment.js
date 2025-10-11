// Test script for Razorpay payment integration
// Run this in browser console to test payment flow

console.log('🧪 Testing Nabha Healthcare Payment Integration');

// Test 1: Check if PaymentService is loaded
async function testPaymentServiceLoad() {
  try {
    const PaymentService = await import('/src/services/PaymentService.js');
    console.log('✅ PaymentService loaded successfully');
    return PaymentService.default;
  } catch (error) {
    console.error('❌ Failed to load PaymentService:', error);
    return null;
  }
}

// Test 2: Test Razorpay SDK loading
async function testRazorpaySDK(paymentService) {
  if (!paymentService) return false;
  
  try {
    const result = await paymentService.testConnection();
    if (result) {
      console.log('✅ Razorpay SDK connection successful');
      return true;
    } else {
      console.error('❌ Razorpay SDK connection failed');
      return false;
    }
  } catch (error) {
    console.error('❌ Error testing Razorpay SDK:', error);
    return false;
  }
}

// Test 3: Test order creation
async function testOrderCreation(paymentService) {
  if (!paymentService) return false;
  
  try {
    const order = await paymentService.createOrder(100, 'INR');
    if (order.success) {
      console.log('✅ Order creation successful:', order);
      return order;
    } else {
      console.error('❌ Order creation failed:', order.error);
      return false;
    }
  } catch (error) {
    console.error('❌ Error creating order:', error);
    return false;
  }
}

// Test 4: Test payment processing (mock)
async function testPaymentProcessing(paymentService, orderId) {
  if (!paymentService || !orderId) return false;
  
  try {
    console.log('🔄 Testing payment processing...');
    
    // Mock order data
    const orderData = {
      orderId: orderId,
      amount: 100,
      customerName: 'Test Customer',
      email: 'test@example.com',
      phone: '9999999999',
      address: 'Test Address',
      city: 'Test City',
      pincode: '123456',
      onSuccess: (response) => {
        console.log('✅ Payment successful (mock):', response);
      },
      onFailure: (error) => {
        console.log('ℹ️ Payment failed/cancelled (expected for test):', error);
      }
    };
    
    // This will open Razorpay checkout for testing
    // Note: Cancel the payment to avoid actual charges in test mode
    await paymentService.processOnlinePayment(orderData);
    
    return true;
  } catch (error) {
    console.error('❌ Error in payment processing:', error);
    return false;
  }
}

// Run all tests
async function runAllTests() {
  console.log('🚀 Starting payment integration tests...');
  
  const paymentService = await testPaymentServiceLoad();
  if (!paymentService) return;
  
  const sdkLoaded = await testRazorpaySDK(paymentService);
  if (!sdkLoaded) return;
  
  const order = await testOrderCreation(paymentService);
  if (!order) return;
  
  console.log('🎯 All basic tests passed! Payment integration is working.');
  console.log('💡 To test actual payment flow, go to pharmacy page and add items to cart.');
  console.log('⚠️ Use test cards in Razorpay test mode to avoid real charges.');
  
  // Optionally test payment processing (will open Razorpay modal)
  const testActualPayment = confirm('Do you want to test the actual payment modal? (It will open Razorpay checkout - cancel to avoid charges)');
  if (testActualPayment) {
    await testPaymentProcessing(paymentService, order.orderId);
  }
}

// Auto-run tests
runAllTests();

// Export for manual testing
window.testPaymentIntegration = {
  runAllTests,
  testPaymentServiceLoad,
  testRazorpaySDK,
  testOrderCreation,
  testPaymentProcessing
};