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
// Sử dụng routes
// Tất cả các route trong auth.route.js sẽ có tiền tố /api/auth
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});