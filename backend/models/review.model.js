const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ReviewSchema = new Schema({
    customer: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    restaurant: {
        type: Schema.Types.ObjectId,
        ref: 'Restaurant',
        required: true
    },
    order: { // Để xác thực là khách đã đặt hàng
        type: Schema.Types.ObjectId,
        ref: 'Order',
        required: true
    },
    rating: {
        type: Number,
        required: true,
        min: 1,
        max: 5
    },
    comment: {
        type: String
    }
}, {
    timestamps: true // reviewDate chính là createdAt
});

module.exports = mongoose.model('Review', ReviewSchema);