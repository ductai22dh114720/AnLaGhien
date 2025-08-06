const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Áp dụng middleware cho tất cả các route trong file này
router.use(authMiddleware);

// GET /api/cart - Lấy giỏ hàng
router.get('/', cartController.getCart);

// POST /api/cart/add - Thêm sản phẩm
router.post('/add', cartController.addItemToCart);

// DELETE /api/cart/remove/:menuItemId - Xóa một sản phẩm
router.delete('/remove/:menuItemId', cartController.removeItemFromCart);

// DELETE /api/cart/clear - Xóa toàn bộ giỏ hàng
router.delete('/clear', cartController.clearCart);

module.exports = router;