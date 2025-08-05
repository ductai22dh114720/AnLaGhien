const Transaction = require('../models/transaction.model');
const Wallet = require('../models/wallet.model');

// Lấy thông tin ví và lịch sử giao dịch
exports.getWalletInfo = async (req, res) => {
    try {
        const userId = req.userData.userId; // Lấy từ auth middleware
        const wallet = await Wallet.findOne({ user: userId });
        if (!wallet) {
            return res.status(404).json({ message: "Không tìm thấy ví" });
        }

        // Lấy 20 giao dịch gần nhất
        const transactions = await Transaction.find({ wallet: wallet._id })
            .sort({ createdAt: -1 }) // Sắp xếp theo ngày tạo mới nhất
            .limit(20);

        res.status(200).json({
            balance: wallet.balance,
            transactions: transactions
        });
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi lấy thông tin ví", error: error.message });
    }
};