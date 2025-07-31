const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TransactionSchema = new Schema({
    wallet: {
        type: Schema.Types.ObjectId,
        ref: 'Wallet',
        required: true
    },
    amount: {
        type: Number,
        required: true
        // Số dương là nạp/hoàn tiền, số âm là thanh toán
    },
    type: {
        type: String,
        required: true,
        enum: ['deposit', 'payment', 'refund'] // Nạp tiền, Thanh toán, Hoàn tiền
    },
    status: {
        type: String,
        required: true,
        enum: ['pending', 'completed', 'failed'],
        default: 'pending'
    },
    paymentMethod: { // Ví dụ: 'vnpay', 'momo', 'app_wallet'
        type: String 
    },
    transactionCode: { // Mã giao dịch từ cổng thanh toán
        type: String 
    },
    relatedOrder: { // Liên kết đến đơn hàng (nếu là payment hoặc refund)
        type: Schema.Types.ObjectId,
        ref: 'Order'
    }
}, { timestamps: true });

module.exports = mongoose.model('Transaction', TransactionSchema);