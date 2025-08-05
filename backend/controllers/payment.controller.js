

const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

exports.createVnpayPayment = async (req, res) => {
    try {
        process.env.TZ = 'Asia/Ho_Chi_Minh'; // Set múi giờ Việt Nam

        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        let vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL;

        const date = new Date();
        const createDate = moment(date).format('YYYYMMDDHHmmss');
        const orderId = moment(date).format('HHmmss');

        const amount = req.body.amount;
        const bankCode = req.body.bankCode || '';
        // Quan trọng: Mã hóa orderInfo để tránh lỗi với ký tự đặc biệt/tiếng Việt
        const orderInfo = Buffer.from(req.body.orderDescription || 'Thanh toan don hang', 'utf8').toString();
        const orderType = req.body.orderType || 'other';
        const locale = 'vn';

        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = process.env.VNPAY_TMN_CODE;
        vnp_Params['vnp_Locale'] = locale;
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_TxnRef'] = orderId;
        vnp_Params['vnp_OrderInfo'] = orderInfo;
        vnp_Params['vnp_OrderType'] = orderType;
        vnp_Params['vnp_Amount'] = amount * 100;
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_CreateDate'] = createDate;
        if (bankCode !== '') {
            vnp_Params['vnp_BankCode'] = bankCode;
        }

        const sortedParams = {};
        Object.keys(vnp_Params).sort().forEach(key => {
            sortedParams[key] = vnp_Params[key];
        });

        const signData = querystring.stringify(sortedParams, { encode: false });

        // --- CÁC DÒNG LOG ĐỂ DEBUG ---
        console.log("==================== DEBUG VNPAY SIGNATURE ====================");
        console.log("VNPAY_HASH_SECRET (first 5 chars):", secretKey ? secretKey.substring(0, 5) : "NOT FOUND");
        console.log("Sorted Params:", sortedParams);
        console.log("String to Hash (signData):", signData);
        // --- KẾT THÚC DEBUG ---

        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        sortedParams['vnp_SecureHash'] = signed;

        vnpUrl += '?' + querystring.stringify(sortedParams, { encode: true });

        res.status(200).json({ paymentUrl: vnpUrl });
    } catch (error) {
        console.error("Lỗi khi tạo thanh toán VNPay:", error);
        res.status(500).json({ message: "Không thể tạo yêu cầu thanh toán." });
    }
};

// Hàm xử lý kết quả trả về từ VNPay (sau khi người dùng thanh toán)
exports.handleVnpayReturn = (req, res) => {
    // TODO:
    // 1. Lấy các tham số từ req.query.
    // 2. Xác thực chữ ký (vnp_SecureHash) để đảm bảo dữ liệu không bị thay đổi.
    // 3. Kiểm tra vnp_ResponseCode để xem giao dịch có thành công không (00 là thành công).
    // 4. Nếu thành công, tìm và cập nhật trạng thái Transaction trong DB.
    // 5. Cộng tiền vào Wallet của user.
    // 6. Trả về một trang HTML đơn giản để thông báo cho người dùng.

    console.log("VNPay return data:", req.query);
    res.send("<h1>Giao dịch đang được xử lý...</h1><p>Bạn có thể đóng cửa sổ này.</p>");
};