// File: backend/routes/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');
const uploadMiddleware = require('../middleware/upload.middleware');

// GET /api/user/profile - Lấy thông tin cá nhân
router.get('/profile', authMiddleware, userController.getUserProfile);
// PUT /api/user/profile - Cập nhật thông tin cá nhân
router.put('/profile', authMiddleware, userController.updateUserProfile);
// POST /api/user/avatar - Up avatar từ máy ảo
router.post('/avatar', authMiddleware, uploadMiddleware.single('avatar'), userController.updateAvatar);


// --- Routes chỉ dành cho ADMIN ---

// [ADMIN] Lấy danh sách tất cả người dùng
// GET /api/user/
router.get('/', authMiddleware, adminMiddleware, userController.getAllUsers);

// [ADMIN] Cập nhật quyền của một người dùng
// PUT /api/user/:id/role
router.put('/:id/role', authMiddleware, adminMiddleware, userController.updateUserRole);
module.exports = router;