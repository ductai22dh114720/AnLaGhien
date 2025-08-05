const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Định nghĩa schema cho một mục trong đơn hàng
const OrderItemSchema = new Schema({
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
    priceAtOrder: { // Lưu lại giá tại thời điểm đặt hàng
        type: Number,
        required: true
    }
}, { _id: false }); // Không cần _id cho sub-document này

const OrderSchema = new Schema({
    customer: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    deliveryPersonnel: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        default: null // Ban đầu chưa có ai giao
    },
    items: [OrderItemSchema], // Mảng các món hàng
    totalAmount: {
        type: Number,
        required: true
    },
    deliveryAddress: {
        type: String,
        required: true
    },
   status: {
       type: String,
       enum: {
           values: ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'],
       },
       default: 'pending'
   },
    // Có thể thêm các trường khác như ghi chú của khách hàng
    notes: {
        type: String
    }
}, {
    timestamps: true // Lưu lại orderDate (createdAt) và updatedAt
});

module.exports = mongoose.model('Order', OrderSchema);