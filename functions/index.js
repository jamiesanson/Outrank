const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const firestore = admin.firestore();

// ---------------------------------------------
//                MANUAL FUNCTIONS
// ---------------------------------------------

// ---------------------------------------------
//              AUTOMATION FUNCTIONS
// ---------------------------------------------

// The defaults for the glicko ranking algorithm. When this changes, all users ranks must be reset.
// Do no make changes to this unless you want to start a new "season".
const glickoDefaults = {};

// ---------------------------------------------
// Rank updating function
// 
// On every new result logged, this function is called. It gets the
// players current ratings from Firestore and runs them through a 
// single iteration of the Glicko-2 algorithm. The results are then
// fed back in to Firestore, and logged to console.
// ---------------------------------------------
exports.updateUserRankingsOnResult = functions.firestore
    .document('results/{resultId}')
    .onCreate(async (snap, context) => {
        var glicko2 = require('glicko2');
        var ratingSystem = new glicko2.Glicko2(glickoDefaults);

        var matchResult = snap.data();

        // Access user documents and take a snapshot
        var winnerRef = matchResult.winner;
        var loserRef = matchResult.loser;

        var winnerSnap = (await winnerRef.get()).data();
        var loserSnap = (await loserRef.get()).data();

        // Calculate new ratings
        var winnerRanking = ratingSystem.makePlayer(winnerSnap.rating, winnerSnap.rd, winnerSnap.vol);
        var loserRanking = ratingSystem.makePlayer(loserSnap.rating, loserSnap.rd, loserSnap.vol);

        var matches = [];
        matches.push([winnerRanking, loserRanking, 1]);
        ratingSystem.updateRatings(matches);

        // Update users ratings
        await winnerRef.update({
            "rating": winnerRanking.getRating(),
            "rd": winnerRanking.getRd(),
            "vol": winnerRanking.getVol(),
            "gameCount": (winnerSnap.gameCount || 0) + 1
        });

        await loserRef.update({
            "rating": loserRanking.getRating(),
            "rd": loserRanking.getRd(),
            "vol": loserRanking.getVol(),
            "gameCount": (loserSnap.gameCount || 0) + 1
        });

        // Log the update info
        console.log("Updated %s: Δr=%d, ΔRD=%d, ΔRV=%d", winnerSnap.name, winnerRanking.getRating() - winnerSnap.rating, winnerRanking.getRd() - winnerSnap.rd, winnerRanking.getVol() - winnerSnap.vol);
        console.log("Updated %s: Δr=%d, ΔRD=%d, ΔRV=%d", loserSnap.name, loserRanking.getRating() - loserSnap.rating, loserRanking.getRd() - loserSnap.rd, loserRanking.getVol() - loserSnap.vol);
    });

// ---------------------------------------------
// Games processing function
// 
// ---------------------------------------------
exports.onGamesUpdates = functions.firestore
    .document('games/{gameId}')
    .onUpdate(async (change, context) => {
        const newValue = change.after.data();

        // If there aren't two players, return.
        if (!newValue.op_1 || !newValue.op_2) {
            console.log("Not all users have joined game " + change.after.id + ", exiting.");
            return;
        }

        // Validate if this change finalises the game. If not, return and leave as is.
        if (!newValue.op_1_result || !newValue.op_2_result) {
            console.log("Not all users have reported results for game " + change.after.id + ", exiting.");
            return;
        }

        // If there's conflicting results, update game counts then delete the document and return
        if ((await newValue.op_1_result.get()).id !== (await newValue.op_2_result.get()).id) {
            console.log("Conflicting results for game with results " + newValue.op_1_result + ", " + newValue.op_2_result + ", incrementing game counts and removing game.");
            await newValue.op_1.update({
                "gameCount": ((await newValue.op_1.get()).data().gameCount || 0) + 1
            });

            await newValue.op_2.update({
                "gameCount": ((await newValue.op_2.get()).data().gameCount || 0) + 1
            });

            await change.after.ref.delete();
            return;
        }

        // Filled out fully with non-conflicting results. Add a new result.
        const winnerPath = newValue.op_1_result.path;
        const op_1_winner = newValue.op_1.path === winnerPath;

        if (op_1_winner) {
            console.log(newValue.op_1.path + " won! Adding a new result.");
            await firestore.collection('results').add({
                winner: newValue.op_1,
                loser: newValue.op_2
            });
        } else {
            console.log(newValue.op_2.path + " won! Adding a new result.");
            await firestore.collection('results').add({
                winner: newValue.op_2,
                loser: newValue.op_1
            });
        }
        
        // Finally, delete the game.
        await change.after.ref.delete();
    });
