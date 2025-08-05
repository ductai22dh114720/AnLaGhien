const express = require('express');
const router = express.Router();
const walletController = require('../controllers/wallet.controller');
const authMiddleware = require('../middleware/auth.middleware');

// GET /api/wallet/info - Lấy thông tin ví và lịch sử giao dịch
router.get('/info', authMiddleware, walletController.getWalletInfo);

module.exports = router;