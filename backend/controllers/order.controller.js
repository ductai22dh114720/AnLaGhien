
const Order = require('../models/order.model');
const Cart = require('../models/cart.model');

// Hàm tạo một đơn hàng mới từ giỏ hàng của người dùng
exports.createOrder = async (req, res) => {
  try {
    const userId = req.userData.userId; // Lấy từ authMiddleware
    const { paymentMethod, address } = req.body; // Lấy phương thức thanh toán và địa chỉ từ frontend

    // 1. Tìm giỏ hàng của người dùng
    const cart = await Cart.findOne({ user: userId }).populate('items.menuItem');
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Giỏ hàng của bạn đang trống.' });
    }

    // 2. Tính tổng tiền từ giỏ hàng
    const totalPrice = cart.items.reduce((sum, item) => {
      return sum + item.quantity * item.menuItem.price;
    }, 0);

    // 3. Tạo một đơn hàng mới
    const newOrder = new Order({
      user: userId,
      items: cart.items.map(item => ({
        menuItem: item.menuItem._id,
        quantity: item.quantity,
        price: item.menuItem.price,
      })),
      totalPrice: totalPrice,
      paymentMethod: paymentMethod, // 'COD' hoặc 'Wallet'
      address: address, // Địa chỉ giao hàng
      status: 'Pending', // Trạng thái ban đầu
    });

    // 4. Lưu đơn hàng vào database
    await newOrder.save();

    // 5. Xóa giỏ hàng sau khi đã đặt hàng thành công
    cart.items = [];
    await cart.save();

    // 6. Trả về thông tin đơn hàng đã tạo
    res.status(201).json({ message: 'Đặt hàng thành công!', order: newOrder });

  } catch (error) {
    console.error("Lỗi khi tạo đơn hàng:", error);
    res.status(500).json({ message: 'Đã có lỗi xảy ra ở server.' });
  }
};