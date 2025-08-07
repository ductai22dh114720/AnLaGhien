// backend/controllers/order.controller.js

const Order = require('../models/order.model');
const Cart = require('../models/cart.model');
const Wallet = require('../models/wallet.model');
const mongoose = require('mongoose');
// Hàm tạo một đơn hàng mới từ giỏ hàng của người dùng
exports.createOrder = async (req, res) => {
  // BẮT ĐẦU MỘT SESSION GIAO DỊCH
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const userId = req.userData.userId;
    const { address, paymentMethod } = req.body;

    // 1. Tìm giỏ hàng (trong session)
    const cart = await Cart.findOne({ user: userId }).session(session).populate('items.menuItem');
    if (!cart || cart.items.length === 0) {
      await session.abortTransaction(); // Hủy giao dịch
      return res.status(400).json({ message: 'Giỏ hàng của bạn đang trống.' });
    }

    // 2. Tính tổng tiền (trong session)
    const totalPrice = cart.items.reduce((sum, item) => {
      if (item.menuItem && typeof item.menuItem.price === 'number') {
        return sum + item.quantity * item.menuItem.price;
      }
      return sum;
    }, 0);

    // 3. XỬ LÝ THANH TOÁN BẰNG VÍ
    if (paymentMethod === 'wallet') {
      const wallet = await Wallet.findOne({ user: userId }).session(session);
      if (!wallet || wallet.balance < totalPrice) {
        await session.abortTransaction(); // Hủy giao dịch
        return res.status(400).json({ message: 'Số dư ví không đủ để thanh toán.' });
      }
      // Trừ tiền trong ví
      wallet.balance -= totalPrice;
      await wallet.save({ session }); // Lưu lại thay đổi trong session
    }

    // 4. Tạo đơn hàng mới (trong session)
    const newOrder = new Order({
      customer: userId,
      items: cart.items.map(item => ({
        menuItem: item.menuItem._id,
        quantity: item.quantity,
        priceAtOrder: item.menuItem.price,
      })),
      totalAmount: totalPrice,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      status: 'pending',
    });

    // Mongoose sẽ tự động thêm `newOrder` vào session khi tạo
    await newOrder.save({ session });

    // 5. Xóa giỏ hàng (trong session)
    cart.items = [];
    await cart.save({ session });

    // 6. COMMIT GIAO DỊCH - Tất cả thay đổi sẽ được áp dụng cùng lúc
    await session.commitTransaction();

    res.status(201).json({ message: 'Đặt hàng thành công!', order: newOrder });

  } catch (error) {
    // Nếu có bất kỳ lỗi nào, HỦY TẤT CẢ THAY ĐỔI
    await session.abortTransaction();
    console.error("Lỗi khi tạo đơn hàng (transaction):", error);
    res.status(500).json({
        message: 'Lỗi server khi tạo đơn hàng.',
        error: error.message
    });
  } finally {
    // Kết thúc session
    session.endSession();
  }
};
exports.getOrderHistory = async (req, res) => {
  try {
    const userId = req.userData.userId;

    // Tìm tất cả đơn hàng của user, sắp xếp từ mới nhất đến cũ nhất
    const orders = await Order.find({ customer: userId })
      .sort({ createdAt: -1 }) // -1 để sắp xếp giảm dần (mới nhất trước)
      .populate('items.menuItem', 'name imageUrl'); // Lấy thêm 'name' và 'imageUrl' của sản phẩm

    res.status(200).json(orders);
  } catch (error) {
    console.error("Lỗi khi lấy lịch sử đơn hàng:", error);
    res.status(500).json({ message: 'Lỗi server khi lấy lịch sử đơn hàng.' });
  }
};