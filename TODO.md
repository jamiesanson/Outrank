## TODO:
There's a bunch of things I want to get done before being ready to go:

* Setup cloud functions for business logic, node is fine
* Setup BLoC maybe? 
* Need to decide on architecture. How quick and dirty? 
* How will matchmaking work? a collection of matches?
* How will ranking work? Wins? Elo?

### Plan of attack:
* Onboarding - not needed. Start as anon, choose a name at the end of your first game that 
* Homescreen where you can choose your office (/)
* Trade Me rules, markdown rule set held in firestore, or storage? (/) This is now automated, running `node storage/upload.js`
* My games, has a history of your previous games, changes in score and total score.
* Rating system - part way there. Needs tweaking and results agregation.

* Navigation is needed - named routes?
* Keep Ranking screen widget alive when switching tabs
* Cloud function for starting game
* Authentication!!!
* My games screen - list of past matches


* Firebase auth implementation:
  * Sign in with Slack
  * Send custom Slack token to cloud function
  * Function creates account with UID == Slack UID
  * Send custom token to client
  * Client authenticates with custom token
  * If new user (no name): Call function to populate account with Slack token. Firebase creates user in store with that ID if not exists, populates users name and profile image
  * Auth is rule-based based on Firebase UID

* Make an OAuth screen with BloC pattern. This should be started, and asyncronously return some information. 
  * Wire up OAuth Bloc to screen with BloC provider
  * Add stuff to info.plist

* Match screen needs to use CloudFunctions Flutter SDK
* Need a join game function

