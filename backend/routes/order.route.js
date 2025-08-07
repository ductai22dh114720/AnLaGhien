// backend/routes/order.route.js

const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');

// --- Routes cho Customer ---
// POST /api/orders/
router.post('/', authMiddleware, orderController.createOrder);

// GET /api/orders/
router.get('/', authMiddleware, orderController.getOrderHistory);


// --- Routes cho Admin ---

// GET /api/orders/all - Lấy tất cả đơn hàng
// <<<--- ĐẶT ROUTE NÀY LÊN TRƯỚC ROUTE '/:id' ---<<<
router.get('/all', authMiddleware, adminMiddleware, orderController.getAllOrders);


// --- Routes dùng chung ---

// GET /api/orders/:id - Lấy chi tiết một đơn hàng
// Route này phải nằm sau '/all' để không bị bắt nhầm
router.get('/:id', authMiddleware, orderController.getOrderDetail);


// --- Routes cho Admin ---

// PUT /api/orders/:id/status - Cập nhật trạng thái
router.put('/:id/status', authMiddleware, adminMiddleware, orderController.updateOrderStatus);


module.exports = router;