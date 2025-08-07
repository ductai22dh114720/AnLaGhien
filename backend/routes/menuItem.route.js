const express = require('express');
const router = express.Router();
const menuItemController = require('../controllers/menuItem.controller');
// API này có thể public, không cần authMiddleware

// GET /api/menu-items
router.get('/', menuItemController.getAllMenuItems);
router.post('/add', menuItemController.addMenuItem);

module.exports = router;