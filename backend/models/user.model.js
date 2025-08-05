const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UserSchema = new Schema({
    name: { 
        type: String, 
        required: true 
    },
    email: { 
        type: String, 
        required: true, 
        unique: true,
        trim: true,
        lowercase: true
    },
    password: {
        type: String,
        required: true
    },
    phone: {
        type: String,
        // Bỏ required để user Google có thể đăng ký mà không cần SĐT ban đầu
    },
    address: {
        type: String,
        // Bỏ required để user Google có thể đăng ký mà không cần địa chỉ ban đầu
    },
    location: {
        type: {
          type: String,
          enum: ['Point'],
          default: 'Point'
        },
        coordinates: {
          type: [Number], // [longitude, latitude]
          default: [0, 0]
        }
    },
    role: {
        type: String,
        enum: ['customer', 'delivery_personnel', 'admin'],
        default: 'customer'
    },
    // Các trường dành riêng cho người giao hàng
    vehicle: {
        type: Schema.Types.ObjectId,
        ref: 'Vehicle'
    },
    availabilityStatus: {
        type: String,
        enum: ['available', 'unavailable', 'on_delivery'],
        default: 'unavailable'
    },
    avatarUrl: { // Thêm trường avatar
        type: String,
        default: ''
    }
// Dấu ngoặc đóng của schema phải ở đây, chỉ có một khối timestamps
}, {
    timestamps: true
});

// UserSchema.index phải được gọi sau khi đã định nghĩa xong Schema
UserSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('User', UserSchema);