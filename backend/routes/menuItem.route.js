const express = require('express');
const router = express.Router();
const menuItemController = require('../controllers/menuItem.controller');
// API này có thể public, không cần authMiddleware
// Nếu muốn chỉ user đăng nhập mới xem được, hãy thêm authMiddleware

// GET /api/menu-items
router.get('/', menuItemController.getAllMenuItems);

module.exports = router;