// File: backend/routes/payment.route.js
const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');

// Định nghĩa endpoint để tạo URL thanh toán VNPay
// Client sẽ gọi: POST /api/payment/vnpay-create
router.post('/vnpay-create', paymentController.createVnpayPayment);

// Định nghĩa endpoint mà VNPay sẽ gọi lại sau khi thanh toán
// Client (trình duyệt) sẽ được chuyển hướng đến: GET /api/payment/vnpay-return
router.get('/vnpay-return', paymentController.handleVnpayReturn);

module.exports = router;