// backend/config/cloudinary.config.js
const cloudinary = require('cloudinary').v2;
const dotenv = require('dotenv');
dotenv.config();

cloudinary.config({
    cloud_name: process.env.dk51zjydi,
    api_key: process.env.357646773326621,
    api_secret: process.env.NlL68P784IQoXY9JBHkP0N5_7so
});

module.exports = cloudinary;