// backend/controllers/order.controller.js

const Order = require('../models/order.model');
const Cart = require('../models/cart.model');

// Hàm tạo một đơn hàng mới từ giỏ hàng của người dùng
exports.createOrder = async (req, res) => {
  try {
    const userId = req.userData.userId; // Lấy từ authMiddleware
    // SỬA LẠI: Tên biến phải khớp với những gì frontend gửi: address và paymentMethod
    const { address, paymentMethod } = req.body;

    // 1. Tìm giỏ hàng của người dùng và populate thông tin sản phẩm
    const cart = await Cart.findOne({ user: userId }).populate('items.menuItem');
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Giỏ hàng của bạn đang trống.' });
    }

    // 2. Tính tổng tiền từ giỏ hàng một cách an toàn ở backend
    const totalPrice = cart.items.reduce((sum, item) => {
      // Đảm bảo item.menuItem không null
      if (item.menuItem && typeof item.menuItem.price === 'number') {
        return sum + item.quantity * item.menuItem.price;
      }
      return sum;
    }, 0);

    // 3. Tạo một đối tượng đơn hàng mới với ĐẦY ĐỦ CÁC TRƯỜNG YÊU CẦU
    const newOrder = new Order({
      // SỬA LẠI: Tên trường trong model là 'customer', không phải 'user'
      customer: userId,

      // SỬA LẠI: Map lại items để có đầy đủ các trường yêu cầu, đặc biệt là 'priceAtOrder'
      items: cart.items.map(item => ({
        menuItem: item.menuItem._id,
        quantity: item.quantity,
        priceAtOrder: item.menuItem.price, // <<-- THÊM TRƯỜNG NÀY
      })),

      // SỬA LẠI: Cung cấp các trường còn thiếu
      totalAmount: totalPrice, // <<-- THÊM TRƯỜNG NÀY
      deliveryAddress: address, // <<-- SỬA TÊN TRƯỜDNG CHO ĐÚNG
      paymentMethod: paymentMethod,

      // SỬA LẠI: Viết hoa chữ 'P' trong 'Pending' để khớp với enum trong model (khả năng cao)
      status: 'Pending',
    });

    // 4. Lưu đơn hàng vào database
    await newOrder.save();

    // 5. Xóa giỏ hàng sau khi đã đặt hàng thành công
    cart.items = [];
    await cart.save();

    // 6. Trả về thông tin đơn hàng đã tạo
    res.status(201).json({ message: 'Đặt hàng thành công!', order: newOrder });

  } catch (error) {
    // Log lỗi validation chi tiết hơn
    console.error("Lỗi khi tạo đơn hàng:", error);
    res.status(500).json({
        message: 'Lỗi validation khi tạo đơn hàng.',
        error: error.message // Gửi thông điệp lỗi cụ thể
    });
  }
};