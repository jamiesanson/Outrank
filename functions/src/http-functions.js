const functions = require('firebase-functions');
const admin = require('firebase-admin');

const firestore = admin.firestore();

// --------------------------------------------------------------------------
// |_| _|_ _|_ |) . This section has all the HTTP function exports, exported
// | |  |   |  |  . as an espress app.
// --------------------------------------------------------------------------

// ---------------------------------------------
// User initialise Function
// 
// An HTTP endpoint for performing a Slack login. 
// Expected body:
// { "access_token": "...", "id": "...", "name": "...", "avatar": "..." }
// Response:
// { "custom_token": "..." }
// ---------------------------------------------
exports.performSlackLogin = functions.https.onRequest(async (req, resp) => {
    if (req.method !== "POST") {
        resp.status(405).send({ "error": "Method must be post" });
        return;
    }

    const token = await admin.auth().createCustomToken(req.body.id);

    // Create user with user ID
    await firestore.doc("users/" + req.body.id).set(
        {
            "name": req.body.name,
            "avatar": req.body.avatar,
            "slack_access_token": req.body.access_token
        }, { merge: true}
    );

    resp.status(200).send({ "token": token });
});

exports.reportGameResult = functions.https.onCall(async (data, context) => {
    // Get the game
    const gameRef = firestore.doc("games/" + data.game_id);

    // Get the opponents
    const gameData = (await gameRef.get()).data();
    console.log("Reporting result for game", gameData);

    const op1Id = gameData.op_1.path.split('/').slice(-1)[0];
    const op2Id = gameData.op_2.path.split('/').slice(-1)[0];
    const isCurrentUserOp1 = context.auth.uid === op1Id;

    let winnerId;
    if (data.current_user_won) {
        winnerId = isCurrentUserOp1 ? op1Id : op2Id;
    } else {
        winnerId = isCurrentUserOp1 ? op2Id : op1Id;
    }
         
    // Update the game with the result
    let updateData;
    if (isCurrentUserOp1) {
        updateData = {
            "op_1_result": winnerId
        };
    } else {
        updateData = {
            "op_2_result": winnerId
        };
    }

    await gameRef.set(updateData, { merge: true });
});

exports.joinOrStartGame = functions.https.onCall(async (data, context) => {
    console.log("Joining or starting game", data, context.auth);

    let updateData;
    if (data.game_id) {
        // Join as OP2
        updateData = {
            "op_2": await firestore.doc("users/" + context.auth.uid),
            "op_2_name": context.auth.token.name
        };

        await firestore.doc("games/" + data.game_id).set(updateData, { merge: true });
        console.log("Joined game " + data.game_id);
    } else if (data.office_id) {
        // Start as OP1, with office ref
        updateData = {
            "office": await firestore.doc("offices/" + data.office_id),
            "op_1": await firestore.doc("users/" + context.auth.uid), 
            "op_1_name": context.auth.token.name
        };

        const randomstring = require('randomstring');

        let gameId = randomstring.generate(8);
        await firestore.doc("/games/" + gameId).set(updateData);
        console.log("Started game " + gameId, updateData);
    } else {
       throw Error("game_id or office_id parameters are required");
    }
});