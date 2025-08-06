const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

const Wallet = require('../models/wallet.model');
const Transaction = require('../models/transaction.model');

// --- HÀM TẠO THANH TOÁN VNPAY (Lấy lại phiên bản ĐÃ HOẠT ĐỘNG) ---
exports.createVnpayPayment = async (req, res) => {
    try {
        process.env.TZ = 'Asia/Ho_Chi_Minh';
        const date = new Date();

        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        let vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL;

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
        vnp_Params['vnp_CreateDate'] = moment(date).format('YYYYMMDDHHmmss');
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_OrderInfo'] = 'Nap tien vao vi GD ' + newTransaction._id.toString();
        vnp_Params['vnp_OrderType'] = 'other';
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_TxnRef'] = newTransaction._id.toString();

        // SỬ DỤNG LẠI LOGIC sortObject CŨ ĐÃ HOẠT ĐỘNG
        vnp_Params = sortObject(vnp_Params);

        const signData = querystring.stringify(vnp_Params, { encode: false });

        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        vnp_Params['vnp_SecureHash'] = signed;

        vnpUrl += '?' + querystring.stringify(vnp_Params, { encode: false });

        res.status(200).json({ paymentUrl: vnpUrl });

    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};


// --- HÀM XỬ LÝ KẾT QUẢ TRẢ VỀ TỪ VNPAY (ĐÃ SỬA LỖI hasOwnProperty) ---
exports.handleVnpayReturn = async (req, res) => {
    try {
        let vnp_Params = req.query;
        const secureHash = vnp_Params['vnp_SecureHash'];
        const transactionId = vnp_Params['vnp_TxnRef']; // Lấy lại ID giao dịch

        delete vnp_Params['vnp_SecureHash'];
        delete vnp_Params['vnp_SecureHashType'];

        // Sắp xếp lại các tham số để tạo lại chữ ký
        vnp_Params = sortObject(vnp_Params);

        const secretKey = process.env.VNPAY_HASH_SECRET;
        const signData = querystring.stringify(vnp_Params, { encode: false });
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest("hex");

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

// HÀM sortObject NGUYÊN BẢN TỪ CODE DEMO (Đã hoạt động trước đó)
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