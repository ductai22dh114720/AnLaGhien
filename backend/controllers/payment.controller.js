// File: backend/controllers/payment.controller.js

const moment = require('moment');
const querystring = require('qs');
const crypto = require("crypto");

// TODO: Sau này, bạn sẽ tạo các bản ghi Transaction trong DB ở đây

exports.createVnpayPayment = async (req, res) => {
    try {
        // Tắt CORS cho môi trường test (nếu cần, nhưng Render thường tự xử lý)
        res.header('Access-Control-Allow-Origin', '*');

        const ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const secretKey = process.env.VNPAY_HASH_SECRET;
        let vnpUrl = process.env.VNPAY_URL;
        const returnUrl = process.env.VNPAY_RETURN_URL;

        const date = new Date();
        const createDate = moment(date).format('YYYYMMDDHHmmss');
        const orderId = moment(date).format('HHmmss'); // Mã đơn hàng ngắn gọn

        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = process.env.VNPAY_TMN_CODE;
        vnp_Params['vnp_Amount'] = req.body.amount * 100;
        vnp_Params['vnp_CreateDate'] = createDate;
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_OrderInfo'] = 'Thanh toan cho ma GD:' + orderId;
        vnp_Params['vnp_OrderType'] = 'other'; // Hoặc 'billpayment'
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_TxnRef'] = orderId;

        // Sắp xếp các tham số theo thứ tự ABC
        const sortedParams = {};
        Object.keys(vnp_Params).sort().forEach(key => {
            sortedParams[key] = vnp_Params[key];
        });

        // Tạo chuỗi query string không mã hóa
        const signData = querystring.stringify(sortedParams, { encode: false });

        // Tạo chữ ký SHA512
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

        // Thêm chữ ký vào tham số
        sortedParams['vnp_SecureHash'] = signed;

        // Tạo URL cuối cùng có mã hóa
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