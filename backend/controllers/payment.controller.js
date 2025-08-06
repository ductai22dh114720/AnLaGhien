const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

const Wallet = require('../models/wallet.model');
const Transaction = require('../models/transaction.model');

// --- HÀM TẠO THANH TOÁN VNPAY ---
exports.createVnpayPayment = async (req, res) => {
    try {
        process.env.TZ = 'Asia/Ho_Chi_Minh';
        const date = new Date();

        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const tmnCode = process.env.VNPAY_TMN_CODE;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        const vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL;

        const orderId = moment(date).format('HHmmss');
        const amount = req.body.amount;
        const orderInfo = 'Nap tien vao vi GD ' + orderId;

        // Tạo giao dịch trong DB
        const userId = req.userData.userId;
        const wallet = await Wallet.findOne({ user: userId });
        if (!wallet) {
            return res.status(404).json({ message: "Không tìm thấy ví của người dùng." });
        }
        const newTransaction = new Transaction({
            wallet: wallet._id, amount: amount, type: 'deposit',
            status: 'pending', paymentMethod: 'vnpay',
        });
        await newTransaction.save();

        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = tmnCode;
        vnp_Params['vnp_Amount'] = amount * 100;
        vnp_Params['vnp_CreateDate'] = moment(date).format('YYYYMMDDHHmmss');
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_OrderInfo'] = orderInfo;
        vnp_Params['vnp_OrderType'] = 'other';
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_TxnRef'] = newTransaction._id.toString();

        // Sắp xếp các key
        const sortedParams = {};
        Object.keys(vnp_Params).sort().forEach(key => {
            sortedParams[key] = vnp_Params[key];
        });

        // Tạo chuỗi query string không mã hóa
        const signData = querystring.stringify(sortedParams, { encode: false });

        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        // Thêm chữ ký vào tham số
        sortedParams['vnp_SecureHash'] = signed;

        // Tạo URL cuối cùng có mã hóa
        const finalUrl = vnpUrl + '?' + querystring.stringify(sortedParams, { encode: true });

        res.status(200).json({ paymentUrl: finalUrl });

    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};


// --- HÀM XỬ LÝ KẾT QUẢ TRẢ VỀ TỪ VNPAY ---
exports.handleVnpayReturn = async (req, res) => {
    try {
        let vnp_Params = req.query;
        const secureHash = vnp_Params['vnp_SecureHash'];
        const transactionId = vnp_Params['vnp_TxnRef'];

        delete vnp_Params['vnp_SecureHash'];
        delete vnp_Params['vnp_SecureHashType'];

        // Sắp xếp lại
        const sortedParams = {};
        Object.keys(vnp_Params).sort().forEach(key => {
            sortedParams[key] = vnp_Params[key];
        });

        // Tạo lại signData để kiểm tra
        const secretKey = process.env.VNPAY_HASH_SECRET;
        const signData = querystring.stringify(sortedParams, { encode: false });
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        if (secureHash === signed) {
            const transaction = await Transaction.findById(transactionId);
            if (!transaction) {
                return res.send("<h1>Giao dịch không tồn tại</h1>");
            }
            if (transaction.status !== 'pending') {
                return res.send("<h1>Giao dịch đã được xử lý.</h1>");
            }

            if (vnp_Params['vnp_ResponseCode'] === '00') {
                transaction.status = 'completed';
                transaction.transactionCode = vnp_Params['vnp_TransactionNo'];
                await transaction.save();
                await Wallet.findByIdAndUpdate(transaction.wallet, { $inc: { balance: transaction.amount } });
                return res.send("<h1>Thanh toán thành công!</h1><p>Bạn có thể đóng cửa sổ này.</p>");
            } else {
                transaction.status = 'failed';
                await transaction.save();
                return res.send("<h1>Thanh toán thất bại!</h1>");
            }
        } else {
            return res.send("<h1>Chữ ký không hợp lệ!</h1>");
        }
    } catch (error) {
        console.error("Lỗi khi xử lý VNPay return:", error);
        return res.status(500).send("<h1>Đã có lỗi xảy ra</h1>");
    }
};