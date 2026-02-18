const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const RestaurantSchema = new Schema({
    name: { 
        type: String, 
        required: true 
    },
    address: { 
        type: String, 
        required: true 
    },
    cuisineType: { 
        type: String, 
        required: true 
    },
    contactNumber: { 
        type: String, 
        required: true 
    },
    // Thêm trường để biết ai là chủ nhà hàng (nếu cần)
    owner: {
        type: Schema.Types.ObjectId,
        ref: 'User'
    }
}, { 
    timestamps: true 
});

module.exports = mongoose.model('Restaurant', RestaurantSchema);