## TODO:
There's a bunch of things I want to get done before being ready to go:

* Setup cloud functions for business logic, node is fine
* Setup BLoC maybe? 
* Need to decide on architecture. How quick and dirty? 
* How will matchmaking work? a collection of matches?
* How will ranking work? Wins? Elo?

Plan of attack:
* Onboarding - not needed. Start as anon, choose a name at the end of your first game that 
* Homescreen where you can choose your office (/)
* Trade Me rules, markdown rule set held in firestore, or storage? (/) This is now automated, running `node storage/upload.js`
* My games, has a history of your previous games, changes in score and total score.
* Rating system - part way there. Needs tweaking and results agregation.

* Need to add Games to repository
* Behaviour when office changes on the backend (pops open drawer)
* Switching back and forth between tabs means lots of calls to update (maybe need to dispose/not dispose bloc?)
* Navigation is needed - named routes?

