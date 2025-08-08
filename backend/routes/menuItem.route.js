
const express = require('express');
const router = express.Router();
const menuItemController = require('../controllers/menuItem.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');

// [PUBLIC] Lấy danh sách món ăn - Bất kỳ ai cũng có thể xem
// GET /api/menu-items/
router.get('/', menuItemController.getAllMenuItems);
router.post('/add', menuItemController.addMenuItem);
// [PUBLIC] Tìm kiếm món ăn
router.get('/search',menuItemController.searchMenuItems);

// [ADMIN] Tạo món ăn mới
// POST /api/menu-items/
router.post('/', authMiddleware, adminMiddleware, menuItemController.createMenuItem);

// [ADMIN] Cập nhật món ăn
// PUT /api/menu-items/:id
router.put('/:id', authMiddleware, adminMiddleware, menuItemController.updateMenuItem);

// [ADMIN] Xóa món ăn
// DELETE /api/menu-items/:id
router.delete('/:id', authMiddleware, adminMiddleware, menuItemController.deleteMenuItem);

module.exports = router;