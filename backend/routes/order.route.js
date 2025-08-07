

const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const authMiddleware = require('../middleware/auth.middleware'); // Giả sử bạn có middleware này

// Định nghĩa route để tạo đơn hàng mới
// POST /api/orders/
router.post('/', authMiddleware, orderController.createOrder);
router.get('/', authMiddleware, orderController.getOrderHistory);

router.get('/:id', authMiddleware, orderController.getOrderDetail);


module.exports = router;