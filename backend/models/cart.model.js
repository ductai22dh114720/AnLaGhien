const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Tái sử dụng định nghĩa của một món hàng
const CartItemSchema = new Schema({
    menuItem: {
        type: Schema.Types.ObjectId,
        ref: 'MenuItem',
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 1
    },
    // Chúng ta không cần priceAtOrder ở đây vì giá có thể thay đổi
    // Giá sẽ được tính lại lần cuối khi checkout
}, { _id: false });

const CartSchema = new Schema({
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true // Mỗi user chỉ có MỘT giỏ hàng
    },
    items: [CartItemSchema],
    // Chúng ta có thể thêm các trường khác như `updatedAt` để tự động xóa giỏ hàng cũ
}, { timestamps: true }); // createdAt và updatedAt sẽ hữu ích

module.exports = mongoose.model('Cart', CartSchema);