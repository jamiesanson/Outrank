var admin = require("firebase-admin");

var serviceAccount = require("../credentials/serviceAccount.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://outrank-ba748.firebaseio.com"
});

const storage = admin.storage().bucket("gs://outrank-ba748.appspot.com/");

// Recursively traverse data/ and upload in the same pattern to Firebase storage
var walkSync = function(dir, filelist) {
    var path = path || require('path');
    var fs = fs || require('fs'),
        files = fs.readdirSync(dir);
    filelist = filelist || [];
    files.forEach(function(file) {
        if (fs.statSync(path.join(dir, file)).isDirectory()) {
        filelist = walkSync(path.join(dir, file), filelist);
        }
        else {
        filelist.push(file);
        }
    });
    return filelist;
};

var filePaths = walkSync("data")

filePaths.forEach(function(path) {
        storage.upload("data/" + path, { "destination": path }).then(function(snapshot) {
            console.log("Uploaded file from data/" + path + " to " + path);
        });
    });




