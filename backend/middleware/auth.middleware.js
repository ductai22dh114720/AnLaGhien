// File: backend/middleware/auth.middleware.js
const jwt = require('jsonwebtoken');

console.log(">>> ADMIN TOKEN:", process.env.JWT_SECRET, { expiresIn: '8h' });

module.exports = (req, res, next) => {
    try {
        // Lấy token từ header: "Authorization: Bearer <token>"
        const token = req.headers.authorization.split(" ")[1];
        if (!token) {
            return res.status(401).json({ message: 'Authentication failed: No token provided.' });
        }

        // Xác thực token
        const decodedToken = jwt.verify(token, process.env.JWT_SECRET);

        // Gắn thông tin user vào request để các controller sau có thể sử dụng
        req.userData = { userId: decodedToken.userId, email: decodedToken.email };

        next(); // Cho phép request đi tiếp đến controller
    } catch (error) {
        return res.status(401).json({ message: 'Authentication failed: Invalid token.' });
    }
};