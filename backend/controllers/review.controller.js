const Review = require('../models/review.model');
const Order = require('../models/order.model');
const mongoose = require('mongoose');

// --- TẠO MỘT ĐÁNH GIÁ MỚI ---
exports.createReview = async (req, res) => {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
        const userId = req.userData.userId;
        const { orderId, rating, comment } = req.body;

        // 1. Kiểm tra xem đơn hàng có tồn tại và thuộc về user này không
        const order = await Order.findOne({ _id: orderId, customer: userId }).session(session);

        if (!order) {
            await session.abortTransaction();
            return res.status(404).json({ message: 'Không tìm thấy đơn hàng hoặc bạn không có quyền đánh giá đơn này.' });
        }

        // 2. Kiểm tra xem đơn hàng đã được giao chưa
        if (order.status !== 'delivered') {
            await session.abortTransaction();
            return res.status(400).json({ message: 'Chỉ có thể đánh giá những đơn hàng đã được giao.' });
        }

        // 3. Kiểm tra xem đơn hàng đã được đánh giá chưa
        if (order.isReviewed) {
            await session.abortTransaction();
            return res.status(400).json({ message: 'Bạn đã đánh giá đơn hàng này rồi.' });
        }

        // 4. Lấy thông tin nhà hàng từ đơn hàng (giả sử bạn đã populate nó hoặc có ID)
        // Cần populate restaurant khi get order, hoặc truy vấn lại
        const populatedOrder = await Order.findById(orderId).populate({
            path: 'items.menuItem',
            populate: { path: 'restaurant' }
        });
        const restaurantId = populatedOrder.items[0]?.menuItem?.restaurant?._id;

        if (!restaurantId) {
             await session.abortTransaction();
             return res.status(500).json({ message: 'Lỗi: Không tìm thấy thông tin nhà hàng trong đơn hàng.' });
        }


        // 5. Tạo review mới
        const newReview = new Review({
            customer: userId,
            restaurant: restaurantId,
            order: orderId,
            rating: rating,
            comment: comment
        });
        await newReview.save({ session });

        // 6. Cập nhật trạng thái 'isReviewed' của đơn hàng
        order.isReviewed = true;
        await order.save({ session });

        // 7. Commit transaction
        await session.commitTransaction();

        res.status(201).json({ message: 'Cảm ơn bạn đã đánh giá!', review: newReview });

    } catch (error) {
        await session.abortTransaction();
        console.error("Lỗi khi tạo review:", error);
        res.status(500).json({ message: 'Lỗi server khi tạo đánh giá.' });
    } finally {
        session.endSession();
    }
};

// --- LẤY TẤT CẢ ĐÁNH GIÁ CỦA MỘT USER ---
exports.getMyReviews = async (req, res) => {
    try {
        const userId = req.userData.userId;
        const reviews = await Review.find({ customer: userId })
            .sort({ createdAt: -1 })
            .populate('restaurant', 'name imageUrl')
            .populate('customer', 'name avatarUrl')// Lấy thông tin nhà hàng
            .populate({
                path: 'order',
                select: 'items',
                populate: {
                    path: 'items.menuItem',
                    select: 'name imageUrl'
                }
            });

        res.status(200).json(reviews);
    } catch (error) {
        console.error("Lỗi khi lấy đánh giá của tôi:", error);
        res.status(500).json({ message: 'Lỗi server khi lấy danh sách đánh giá.' });
    }
};

// --- LẤY CHI TIẾT MỘT ĐÁNH GIÁ (DỰA TRÊN ORDER ID) ---
exports.getReviewByOrderId = async (req, res) => {
     try {
        const userId = req.userData.userId;
        const { orderId } = req.params;

        // <<< CẬP NHẬT TRUY VẤN Ở ĐÂY >>>
        const review = await Review.findOne({ order: orderId, customer: userId })
            .populate('restaurant', 'name imageUrl')
            // Thêm dòng populate này để lấy thông tin chi tiết của khách hàng
            .populate('customer', 'name avatarUrl')
            .populate({
                path: 'order',
                populate: {
                    path: 'items.menuItem',
                    select: 'name imageUrl'
                }
            });

        if (!review) {
            return res.status(404).json({ message: 'Không tìm thấy đánh giá cho đơn hàng này.' });
        }

        res.status(200).json(review);
    } catch (error) {
        console.error("Lỗi khi lấy chi tiết đánh giá:", error);
        res.status(500).json({ message: 'Lỗi server khi lấy chi tiết đánh giá.' });
    }
};