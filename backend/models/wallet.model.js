
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const WalletSchema = new Schema({
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true // Đảm bảo mỗi user chỉ có 1 ví
    },
    balance: {
        type: Number,
        required: true,
        default: 0 // Số dư ban đầu là 0
    }
}, { timestamps: true });

module.exports = mongoose.model('Wallet', WalletSchema);