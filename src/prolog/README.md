# Prolog SMP

A Gale-Shapley approach implemented in Prolog.  

To run (requires SWI-Prolog): 
1) Run `swipl -s smp.pl` in a terminal set to this directory
2) Run `stableMatching('list_employers.csv', 'list_students.csv', Z).` 

(This takes about 60 seconds to terminate & generate the new CSV file containing results)

Student preferences: `list_students.csv`
Employer preferneces: `list_employers.csv`

Also creates a new CSV file containing the matches.

