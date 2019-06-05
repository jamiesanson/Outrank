const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// The defaults for the glicko ranking algorithm. When this changes, all users ranks must be reset.
// Do no make changes to this unless you want to start a new "season".
const glickoDefaults = {};

// ---------------------------------------------
// Rank updating function
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

