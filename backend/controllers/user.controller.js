// File: backend/controllers/user.controller.js
const User = require('../models/user.model');

// Lấy thông tin của user đang đăng nhập
exports.getUserProfile = async (req, res) => {
    try {
        // Lấy userId từ middleware
        const userId = req.userData.userId;

        // Tìm user trong DB, không trả về mật khẩu
        const user = await User.findById(userId).select('-password');

        if (!user) {
            return res.status(404).json({ message: 'User not found.' });
        }

        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: 'Fetching user failed.', error: error.message });
    }
};

// Cập nhật thông tin user
exports.updateUserProfile = async (req, res) => {
    try {
        const userId = req.userData.userId;
        const updates = req.body; // { name: "New Name", phone: "123" }

        // Tìm và cập nhật user
        // { new: true } để trả về document đã được cập nhật
        const updatedUser = await User.findByIdAndUpdate(userId, updates, { new: true }).select('-password');

        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found.' });
        }

        res.status(200).json({ message: 'Profile updated successfully!', user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: 'Updating user failed.', error: error.message });
    }
};