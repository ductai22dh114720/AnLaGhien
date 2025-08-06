const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

const Wallet = require('../models/wallet.model');
const Transaction = require('../models/transaction.model');

exports.createVnpayPayment = async (req, res) => {
    try {
        process.env.TZ = 'Asia/Ho_Chi_Minh';

        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        let vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL;

        const date = new Date();
        const createDate = moment(date).format('YYYYMMDDHHmmss');
        const orderId = moment(date).format('HHmmss');
        const amount = req.body.amount;

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
        vnp_Params['vnp_TmnCode'] = process.env.VNPAY_TMN_CODE;
        vnp_Params['vnp_Amount'] = amount * 100;
        vnp_Params['vnp_CreateDate'] = createDate;
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_OrderInfo'] = 'Nap tien vao vi GD ' + orderId;
        vnp_Params['vnp_OrderType'] = 'other';
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_TxnRef'] = orderId;

        // --- BẮT ĐẦU LOGIC TẠO CHỮ KÝ MỚI, ĐÚNG CHUẨN ---

        // 1. Sắp xếp các key
        const sortedKeys = Object.keys(vnp_Params).sort();

        // 2. Tạo chuỗi signData thủ công
        let signData = "";
        for (const key of sortedKeys) {
            if (vnp_Params[key] !== '' && vnp_Params[key] !== undefined && vnp_Params[key] !== null) {
                // Nối key=value&
                signData += (signData.length === 0 ? '' : '&') + key + '=' + vnp_Params[key];
            }
        }

        // 3. Tạo chữ ký
        const hmac = crypto.createHmac("sha512", secretKey);
        const vnp_SecureHash = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        // 4. Thêm chữ ký vào cuối chuỗi query string
        const queryString = querystring.stringify(vnp_Params, { encode: true });
        const finalUrl = vnpUrl + '?' + queryString + '&vnp_SecureHash=' + vnp_SecureHash;
        // --- KẾT THÚC LOGIC MỚI ---

        res.status(200).json({ paymentUrl: finalUrl });

    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};


// --- HÀM XỬ LÝ KẾT QUẢ TRẢ VỀ TỪ VNPAY (ĐÃ HOÀN THIỆN) ---
exports.handleVnpayReturn = async (req, res) => {
    try {
        let vnp_Params = req.query;
        const secureHash = vnp_Params['vnp_SecureHash'];

        delete vnp_Params['vnp_SecureHash'];
        delete vnp_Params['vnp_SecureHashType'];

        // Sắp xếp
        const sortedKeys = Object.keys(vnp_Params).sort();
        const sortedParams = {};
        for (const key of sortedKeys) {
            sortedParams[key] = vnp_Params[key];
        }

        // Tạo lại signData để kiểm tra
        const signData = querystring.stringify(sortedParams, { encode: false });

        const secretKey = process.env.VNPAY_HASH_SECRET;
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        if (secureHash === signed) {
            // Chữ ký hợp lệ, tiếp tục xử lý
            const transaction = await Transaction.findById(transactionId);
            if (!transaction) {
                return res.status(200).json({ RspCode: '01', Message: 'Order not found' });
            }

            // Chỉ xử lý nếu giao dịch đang chờ
            if (transaction.status !== 'pending') {
                return res.status(200).json({ RspCode: '02', Message: 'Order already confirmed' });
            }

            // Kiểm tra mã kết quả từ VNPay
            if (vnp_Params['vnp_ResponseCode'] === '00') {
                // Giao dịch thành công trên VNPay
                transaction.status = 'completed';
                transaction.transactionCode = vnp_Params['vnp_TransactionNo']; // Lưu mã GD của VNPay
                await transaction.save();

                // Cộng tiền vào ví của người dùng
                await Wallet.findByIdAndUpdate(transaction.wallet, { $inc: { balance: transaction.amount } });

                // Trả về trang HTML thông báo thành công
                return res.send("<h1>Thanh toán thành công!</h1><p>Giao dịch của bạn đã được xử lý. Bạn có thể đóng cửa sổ này.</p>");
            } else {
                // Giao dịch thất bại trên VNPay
                transaction.status = 'failed';
                await transaction.save();
                return res.send("<h1>Thanh toán thất bại!</h1><p>Đã có lỗi xảy ra trong quá trình thanh toán.</p>");
            }
        } else {
            // Chữ ký không hợp lệ
            return res.send("<h1>Giao dịch không hợp lệ!</h1><p>Chữ ký không khớp.</p>");
        }
    } catch (error) {
        console.error("Lỗi khi xử lý VNPay return:", error);
        return res.status(500).send("<h1>Đã có lỗi xảy ra</h1>");
    }
};
