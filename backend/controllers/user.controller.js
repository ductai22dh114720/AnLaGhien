
const User = require('../models/user.model');
const cloudinary = require('../config/cloudinary.config');

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

        // Chỉ cho phép cập nhật các trường an toàn
        const { name, phone, address } = req.body;
        const updates = { name, phone, address };

        // Tìm và cập nhật user
        // { new: true } để trả về document đã được cập nhật
        const updatedUser = await User.findByIdAndUpdate(userId, updates, { new: true }).select('-password');

        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found.' });
        }

        res.status(200).json({ message: 'Cập nhật thông tin thành công!', user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: 'Cập nhật thông tin thất bại.', error: error.message });
    }
};
// HÀM MỚI: Cập nhật ảnh đại diện
exports.updateAvatar = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'Vui lòng chọn một file ảnh.' });
        }

        const userId = req.userData.userId;
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
        }

        // Upload ảnh lên Cloudinary
        // Chuyển đổi buffer thành base64 string
        const b64 = Buffer.from(req.file.buffer).toString("base64");
        let dataURI = "data:" + req.file.mimetype + ";base64," + b64;

        const result = await cloudinary.uploader.upload(dataURI, {
            folder: "avatars", // Thư mục lưu trên Cloudinary
            public_id: user._id, // Dùng user ID làm tên file để dễ quản lý
            overwrite: true,
            resource_type: "auto"
        });

        // Cập nhật URL avatar mới vào database
        user.avatarUrl = result.secure_url;
        await user.save();

        res.status(200).json({ message: 'Cập nhật ảnh đại diện thành công!', user: user });

    } catch (error) {
        console.error("Lỗi khi upload avatar:", error);
        res.status(500).json({ message: 'Lỗi server khi upload ảnh.' });
    }
};

// [ADMIN] Lấy danh sách tất cả người dùng
exports.getAllUsers = async (req, res) => {
    try {
        // Lấy tất cả user, không trả về mật khẩu, sắp xếp theo ngày tạo
        const users = await User.find({}).select('-password').sort({ createdAt: -1 });
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy danh sách người dùng.', error: error.message });
    }
};

// [ADMIN] Cập nhật quyền của một người dùng
exports.updateUserRole = async (req, res) => {
    try {
        const { id } = req.params; // ID của người dùng cần cập nhật
        const { role } = req.body; // Quyền mới ('customer', 'admin', 'delivery')

        // Kiểm tra xem role có hợp lệ không
        const allowedRoles = ['customer', 'admin', 'delivery'];
        if (!role || !allowedRoles.includes(role)) {
            return res.status(400).json({ message: 'Quyền không hợp lệ.' });
        }

        const updatedUser = await User.findByIdAndUpdate(id, { role: role }, { new: true }).select('-password');

        if (!updatedUser) {
            return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
        }

        res.status(200).json({ message: 'Cập nhật quyền thành công!', user: updatedUser });

    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi cập nhật quyền.', error: error.message });
    }
};