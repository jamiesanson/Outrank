var admin = require("firebase-admin");

var serviceAccount = require("../credentials/serviceAccount.json");

const bucketUrl = "gs://outrank-ba748.appspot.com/";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://outrank-ba748.firebaseio.com"
});

const storage = admin.storage().bucket(bucketUrl);

// Recursively traverse static/ and upload in the same pattern to Firebase storage
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

var filePaths = walkSync("static")

filePaths.forEach(function(path) {
        storage.upload("static/" + path, { "destination": "static/" + path }).then(function(snapshot) {
            console.log("Uploaded file from static/" + path + " to static/" + path + " in bucket " + bucketUrl);
        });
    });




