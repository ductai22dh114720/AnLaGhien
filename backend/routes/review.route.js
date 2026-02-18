const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const reviewController = require('../controllers/review.controller');

// POST /api/reviews - Tạo một review mới
router.post('/', authMiddleware, reviewController.createReview);

// GET /api/reviews/my-reviews - Lấy tất cả review của user đang đăng nhập
router.get('/my-reviews', authMiddleware, reviewController.getMyReviews);

// GET /api/reviews/by-order/:orderId - Lấy review theo ID của đơn hàng
router.get('/by-order/:orderId', authMiddleware, reviewController.getReviewByOrderId);

module.exports = router;