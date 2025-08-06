const Cart = require('../models/cart.model');
const MenuItem = require('../models/menuItem.model');

// Lấy giỏ hàng của người dùng hiện tại
exports.getCart = async (req, res) => {
    try {
        const userId = req.userData.userId;
        // KIỂM TRA LẠI LOGIC POPULATE
        const cart = await Cart.findOne({ user: userId }).populate({
            path: 'items.menuItem',
            model: 'MenuItem' // Chỉ định rõ model để populate
        });

        if (!cart) {
            // Nếu không có giỏ hàng, có thể tạo mới một cái
            const newCart = new Cart({ user: userId, items: [] });
            await newCart.save();
            return res.status(200).json(newCart);
        }
        res.status(200).json(cart);
    } catch (error) {
        console.error("Lỗi khi getCart:", error); // Thêm log lỗi
        res.status(500).json({ message: "Lỗi khi lấy giỏ hàng." });
    }
};

// Thêm một sản phẩm vào giỏ hoặc cập nhật số lượng
exports.addItemToCart = async (req, res) => {
    try {
        const userId = req.userData.userId;
        const { menuItemId, quantity } = req.body;

        const cart = await Cart.findOne({ user: userId });
        if (!cart) { // Thêm kiểm tra nếu không có giỏ
             return res.status(404).json({ message: "Không tìm thấy giỏ hàng." });
        }
        const menuItem = await MenuItem.findById(menuItemId);
        if (!menuItem) {
            return res.status(404).json({ message: "Không tìm thấy sản phẩm." });
        }

        const itemIndex = cart.items.findIndex(item => item.menuItem.toString() === menuItemId);

        if (itemIndex > -1) {
            cart.items[itemIndex].quantity += quantity;
        } else {
            cart.items.push({ menuItem: menuItemId, quantity });
        }

        const updatedCart = await cart.save();
        await updatedCart.populate({ path: 'items.menuItem', model: 'MenuItem' });

        res.status(200).json(updatedCart);
    } catch (error) {
        console.error("Lỗi khi addItemToCart:", error); // Thêm log lỗi
        res.status(500).json({ message: "Lỗi khi thêm sản phẩm vào giỏ." });
    }
};

// Xóa một sản phẩm khỏi giỏ hàng
exports.removeItemFromCart = async (req, res) => {
    try {
        const userId = req.userData.userId;
        const { menuItemId } = req.params; // Lấy từ URL

        const cart = await Cart.findOne({ user: userId });
        cart.items = cart.items.filter(item => !item.menuItem.equals(menuItemId));

        const updatedCart = await cart.save();
        await updatedCart.populate('items.menuItem');

        res.status(200).json(updatedCart);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi xóa sản phẩm khỏi giỏ." });
    }
};

// Xóa toàn bộ giỏ hàng
exports.clearCart = async (req, res) => {
    try {
        const userId = req.userData.userId;
        const cart = await Cart.findOne({ user: userId });
        cart.items = [];
        await cart.save();
        res.status(200).json({ message: "Đã xóa toàn bộ giỏ hàng." });
    } catch (error) {
         res.status(500).json({ message: "Lỗi khi xóa giỏ hàng." });
    }
};