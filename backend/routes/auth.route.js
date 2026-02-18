// routes/auth.route.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller.js');

// POST /api/auth/signup
router.post('/signup', authController.signup);

// POST /api/auth/login
router.post('/login', authController.login);

router.post('/google', authController.googleLogin);

module.exports = router;