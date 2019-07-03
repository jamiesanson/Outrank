const admin = require('firebase-admin');
admin.initializeApp();

module.exports = {
    ...require("./src/http-functions.js"),
    ...require("./src/firestore-callbacks.js"),
};