// File: backend/routes/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middleware/auth.middleware');

// GET /api/user/profile - Lấy thông tin cá nhân
// authMiddleware sẽ chạy trước, nếu token hợp lệ mới đến userController.getUserProfile
router.get('/profile', authMiddleware, userController.getUserProfile);

// PUT /api/user/profile - Cập nhật thông tin cá nhân
router.put('/profile', authMiddleware, userController.updateUserProfile);

router.post('/avatar', authMiddleware, uploadMiddleware.single('avatar'), userController.updateAvatar);

module.exports = router;