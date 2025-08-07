const MenuItem = require('../models/menuItem.model');
const Restaurant = require('../models/restaurant.model');

// Lấy tất cả các món ăn (có thể thêm phân trang sau)
exports.getAllMenuItems = async (req, res) => {
    try {
        const menuItems = await MenuItem.find({});
        res.status(200).json(menuItems);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi lấy danh sách món ăn." });
    }
};
exports.addMenuItem = async (req, res) => {
    try {
        const { name, description, price, imageUrl, restaurantId, isAvailable } = req.body;

        // Dòng này bây giờ sẽ hợp lệ
        const restaurantExists = await Restaurant.findById(restaurantId);
        if (!restaurantExists) {
            return res.status(404).json({ message: "Không tìm thấy nhà hàng." });
        }

        const newMenuItem = new MenuItem({
            name,
            description,
            price,
            imageUrl,
            restaurant: restaurantId,
            isAvailable
        });

        const savedItem = await newMenuItem.save();

        res.status(201).json(savedItem);

    } catch (error) {
        console.error("Lỗi khi thêm món ăn:", error);
        res.status(500).json({ message: "Không thể thêm món ăn mới." });
    }
};