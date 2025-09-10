const express = require('express');
const router = express.Router();
const checkAuth = require('../middleware/check-auth');
const reviewController = require('../controllers/review.controller');

// POST /api/reviews - Tạo một review mới
router.post('/', checkAuth, reviewController.createReview);

// GET /api/reviews/my-reviews - Lấy tất cả review của user đang đăng nhập
router.get('/my-reviews', checkAuth, reviewController.getMyReviews);

// GET /api/reviews/by-order/:orderId - Lấy review theo ID của đơn hàng
router.get('/by-order/:orderId', checkAuth, reviewController.getReviewByOrderId);

module.exports = router;