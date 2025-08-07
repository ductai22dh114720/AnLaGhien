// admin.middleware.js
const User = require('../models/user.model');

const adminMiddleware = async (req, res, next) => {
    try {
        // Giả sử authMiddleware đã chạy trước và gắn req.userData
        const user = await User.findById(req.userData.userId);
        if (user && user.role === 'admin') {
            next(); // Nếu là admin, cho phép đi tiếp
        } else {
            res.status(403).json({ message: 'Truy cập bị từ chối. Yêu cầu quyền admin.' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Lỗi xác thực quyền admin.' });
    }
};

module.exports = adminMiddleware;