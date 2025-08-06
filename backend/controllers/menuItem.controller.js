const MenuItem = require('../models/menuItem.model');

// Lấy tất cả các món ăn (có thể thêm phân trang sau)
exports.getAllMenuItems = async (req, res) => {
    try {
        const menuItems = await MenuItem.find({});
        res.status(200).json(menuItems);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi lấy danh sách món ăn." });
    }
};