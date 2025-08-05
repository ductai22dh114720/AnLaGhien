const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const BankAccountSchema = new Schema({
    user: { // Chủ sở hữu của tài khoản ngân hàng này
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    bankName: { // Tên ngân hàng (NCB, Vietcombank...)
        type: String,
        required: true
    },
    accountNumber: { // Số tài khoản/số thẻ
        type: String,
        required: true
    },
    accountName: { // Tên chủ tài khoản
        type: String,
        required: true
    },
    isDefault: { // Có phải là tài khoản mặc định không?
        type: Boolean,
        default: false
    }
}, { timestamps: true });

// Đảm bảo một user không thể thêm cùng một số tài khoản nhiều lần
BankAccountSchema.index({ user: 1, accountNumber: 1 }, { unique: true });

module.exports = mongoose.model('BankAccount', BankAccountSchema);