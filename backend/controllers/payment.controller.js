const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");
// Import các model cần thiết
const Wallet = require('../models/wallet.model');
const Transaction = require('../models/transaction.model');
const User = require('../models/user.model');

// --- HÀM TẠO THANH TOÁN VNPAY ---
exports.createVnpayPayment = async (req, res) => {
    try {
        // GIẢ SỬ BẠN ĐÃ CÓ MIDDLEWARE XÁC THỰC TOKEN
         const userId = req.userData.userId;


        const { amount, orderDescription = 'Nap tien vao vi' } = req.body;

        // 1. Tìm ví của người dùng
        const wallet = await Wallet.findOne({ user: userId });
        if (!wallet) {
            return res.status(404).json({ message: "Không tìm thấy ví của người dùng." });
        }

        // 2. Tạo một giao dịch mới với trạng thái 'pending'
        const newTransaction = new Transaction({
            wallet: wallet._id,
            amount: amount,
            type: 'deposit', // Nạp tiền
            status: 'pending',
            paymentMethod: 'vnpay',
        });
        await newTransaction.save();

        // 3. Chuẩn bị các tham số cho VNPay
        process.env.TZ = 'Asia/Ho_Chi_Minh';
        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        const tmnCode = process.env.VNPAY_TMN_CODE;
        let vnpUrl = process.env.VNPAY_URL;
        // Gắn ID của giao dịch vào returnUrl để biết cần cập nhật giao dịch nào
        const returnUrl = `${process.env.VNPAY_RETURN_URL}?transactionId=${newTransaction._id}`;

        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = tmnCode;
        vnp_Params['vnp_Amount'] = amount * 100;
        vnp_Params['vnp_CreateDate'] = moment().format('YYYYMMDDHHmmss');
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_Locale'] = 'vn';
        // Gắn ID giao dịch vào OrderInfo để dễ tra cứu
        vnp_Params['vnp_OrderInfo'] = `Nap tien cho giao dich ${newTransaction._id}`;
        vnp_Params['vnp_OrderType'] = 'other';
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_TxnRef'] = newTransaction._id.toString(); // Dùng ID giao dịch làm mã tham chiếu

        // 4. Tạo chữ ký và URL (logic giữ nguyên)
        vnp_Params = sortObject(vnp_Params);
        const signData = querystring.stringify(vnp_Params, { encode: false });
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");
        vnp_Params['vnp_SecureHash'] = signed;
        vnpUrl += '?' + querystring.stringify(vnp_Params, { encode: true });

        res.status(200).json({ paymentUrl: vnpUrl });

    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};


// --- HÀM XỬ LÝ KẾT QUẢ TRẢ VỀ TỪ VNPAY ---
exports.handleVnpayReturn = async (req, res) => {
    let vnp_Params = req.query;
    const secureHash = vnp_Params['vnp_SecureHash'];
    const transactionId = vnp_Params['vnp_TxnRef']; // Lấy lại ID giao dịch

    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];

    vnp_Params = sortObject(vnp_Params);

    const secretKey = process.env.VNPAY_HASH_SECRET;
    const signData = querystring.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac("sha512", secretKey);
    const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest("hex");

    if (secureHash === signed) {
        const transaction = await Transaction.findById(transactionId);
        if (!transaction) {
            return res.status(404).send("<h1>Giao dịch không tồn tại</h1>");
        }

        // Chỉ xử lý nếu giao dịch đang ở trạng thái 'pending'
        if (transaction.status === 'pending') {
            if (vnp_Params['vnp_ResponseCode'] === '00') {
                // Giao dịch thành công
                transaction.status = 'completed';
                transaction.transactionCode = vnp_Params['vnp_TransactionNo']; // Lưu mã GD của VNPay
                await transaction.save();

                // Cộng tiền vào ví
                await Wallet.findByIdAndUpdate(transaction.wallet, { $inc: { balance: transaction.amount } });

                return res.send("<h1>Thanh toán thành công!</h1><p>Bạn có thể đóng cửa sổ này.</p>");
            } else {
                // Giao dịch thất bại
                transaction.status = 'failed';
                await transaction.save();
                return res.send("<h1>Thanh toán thất bại!</h1><p>Bạn có thể đóng cửa sổ này.</p>");
            }
        } else {
            // Giao dịch đã được xử lý trước đó (ví dụ qua IPN)
             return res.send("<h1>Giao dịch đã được xử lý.</h1><p>Bạn có thể đóng cửa sổ này.</p>");
        }
    } else {
        res.send("<h1>Chữ ký không hợp lệ!</h1>");
    }
};
// HÀM sortObject TỪ CODE DEMO CỦA VNPAY
function sortObject(obj) {
	let sorted = {};
	let str = [];
	let key;
	for (key in obj){
		if (obj.hasOwnProperty(key)) {
		str.push(encodeURIComponent(key));
		}
	}
	str.sort();
    for (key = 0; key < str.length; key++) {
        sorted[str[key]] = encodeURIComponent(obj[str[key]]).replace(/%20/g, "+");
    }
    return sorted;
}