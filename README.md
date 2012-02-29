In 2011 I attended a few plays at the Ottawa Fringe Festival, but there were tons that I never got to see.  Afterwards, I started wondering if it was even possible to see all of the plays at the Fringe.  Naturally, the answer was: write a Ruby script to find out!

This is the result.  So far it takes a hard-coded filename, reads in a list of plays, venues, and showtimes in CSV format, and then starts scheduling plays until it has found a time to attend each show.  So far I've only tested it on two datasets: a 4-play made-up set for simple validation, and the 2011 Ottawa Fringe schedule.  Suprisingly, one could have seen all the plays last year!

The next steps are:

* Detect if we are stuck and cannot find a solution, then schedule as many as possible
* Find some way to spread out the play viewing so that the user is seeing a minimum number of plays per day
* Add a web front-end so a user could pick only the plays or only the days they want

I'm hoping to have this all up and running for the 2012 Ottawa Fringe Festival, so as to see as many plays as possible.