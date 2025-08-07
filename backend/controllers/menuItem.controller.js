const MenuItem = require('../models/menuItem.model');
const Restaurant = require('../models/restaurant.model');

// [PUBLIC] Lấy tất cả các món ăn
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
// [ADMIN] Tạo một món ăn mới
exports.createMenuItem = async (req, res) => {
    try {
        // Bóc tách các trường cần thiết từ body
        const { name, description, price, imageUrl, restaurant, category, isAvailable } = req.body;

        // Kiểm tra các trường bắt buộc
        if (!name || !price || !restaurant || !category) {
            return res.status(400).json({ message: "Vui lòng cung cấp đủ thông tin: name, price, restaurant, category." });
        }

        const newMenuItem = new MenuItem({
            name,
            description,
            price,
            imageUrl,
            restaurant,
            category,
            isAvailable
        });

        const savedItem = await newMenuItem.save();
        res.status(201).json(savedItem);

    } catch (error) {
        console.error("Lỗi khi tạo món ăn:", error);
        res.status(500).json({ message: "Không thể tạo món ăn mới." });
    }
};
// [ADMIN] Cập nhật một món ăn
exports.updateMenuItem = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        const updatedItem = await MenuItem.findByIdAndUpdate(id, updates, { new: true });

        if (!updatedItem) {
            return res.status(404).json({ message: "Không tìm thấy món ăn." });
        }
        res.status(200).json(updatedItem);
    } catch (error) {
        console.error("Lỗi khi cập nhật món ăn:", error);
        res.status(500).json({ message: "Không thể cập nhật món ăn." });
    }
};

// [ADMIN] Xóa một món ăn
exports.deleteMenuItem = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedItem = await MenuItem.findByIdAndDelete(id);

        if (!deletedItem) {
            return res.status(404).json({ message: "Không tìm thấy món ăn." });
        }
        res.status(200).json({ message: "Xóa món ăn thành công." });
    } catch (error) {
        console.error("Lỗi khi xóa món ăn:", error);
        res.status(500).json({ message: "Không thể xóa món ăn." });
    }
};