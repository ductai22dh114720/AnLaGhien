// models/user.model.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: { type: String, required: true },
  address: { type: String, required: true },
  dob: { type: Date }, // Date of Birth
  gender: { type: String },
  // Thêm các trường khác nếu cần
}, { timestamps: true }); // Tự động thêm createdAt và updatedAt

module.exports = mongoose.model('User', UserSchema);