// server.js
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load các biến môi trường từ file .env
dotenv.config();

const app = express();

// Middleware để parse JSON body
app.use(express.json());

// Kết nối đến MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected successfully!'))
  .catch(err => console.error('MongoDB connection error:', err));

// Import routes
const authRoutes = require('./routes/auth.route');
const userRoutes = require('./routes/user.route');
const paymentRoutes = require('./routes/payment.route');
const walletRoutes = require('./routes/wallet.route');
const cartRoutes = require('./routes/cart.route');
const menuItemRoutes = require('./routes/menuItem.route');
const orderRoutes = require('./routes/order.route');
const reviewRoutes = require ('./routes/review.route');
// Sử dụng routes
// Tất cả các route trong auth.route.js sẽ có tiền tố /api/auth
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/menu-items', menuItemRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/reviews', reviewRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});