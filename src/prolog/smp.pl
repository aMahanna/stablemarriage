stableMatching([], _, []).
stableMatching(_, [], []).
stableMatching(EF, SF, Z) :-
	findStableMatch(EF, SF, EPL, SPL),
	fetchEmployerList(EPL, E),
	fetchStudentList(SPL, S),
	permutation(S,S1),
	match(E,S1,M),
	\+ unstableSolution(M, EPL, SPL),
	writeCSV(M),
	permutation(M, Z).

findStableMatch(EmployerFile, StudentFile, EPL, SPL) :- 
	import(EmployerFile, EmployerTable), import(StudentFile, StudentTable), 
	parseEmployerTable(EmployerTable, EPL), parseStudentTable(StudentTable, SPL).

import(File, Rows) :- csv_read_file(File, Rows, [functor(table), arity(11)]),
   maplist(assert, Rows).

parseStudentTable([], _).
parseStudentTable([table(S, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10) | TL], [studentPrefers(S, [E1, E2, E3, E4, E5, E6, E7, E8, E9, E10]) | SPL]) :- parseStudentTable(TL, SPL).
parseEmployerTable([], _).
parseEmployerTable([table(E, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10) | TL], [employerPrefers(E, [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10]) | EPL]) :- parseEmployerTable(TL, EPL).

fetchStudentList([], _).
fetchStudentList([studentPrefers(S, _) | Z], [S | SL]) :- fetchStudentList(Z, SL).
fetchEmployerList([], _).
fetchEmployerList([employerPrefers(E, _) | Z], [E | EL]) :- fetchEmployerList(Z, EL).

permutation([],[]).
permutation([A|As],Bs) :-
	permutation(As,Cs),
	insert(A,Cs,Bs).

insert(A,As,[A|As]).
insert(A,[B|Bs],[B|Cs]) :-
	insert(A,Bs,Cs).

match([],[], []).  
match([E|EL],[S|SL], [pair(E,S)|ESL]) :- 
	match(EL,SL,ESL).

unstableSolution(ML, EPL, SPL) :-
	member(pair(E1,S1), ML),
	member(pair(E2,S2), ML),
	E1 \== E2,
	unstablePair(pair(E1,S1),pair(E2,S2), EPL, SPL).

unstablePair(pair(E1,S1), pair(E2,S2), EPL, SPL) :-
	fetchEmployerPreferenceList(E1, EPL, L1), 
	fetchStudentPreferenceList(S2, SPL, L2), 
	prefers(E1,S2,S1, L1),
	prefers(S2,E1,E2, L2).

unstablePair(pair(E1,S1), pair(E2,S2), EPL, SPL) :-
	fetchEmployerPreferenceList(S1, SPL, L1),  
	fetchStudentPreferenceList(E2, EPL, L2),  
	prefers(S1,E2,E1, L1),
	prefers(E2,S1,S2, L2).

fetchStudentPreferenceList(S, [studentPrefers(S, L) | _], L).
fetchStudentPreferenceList(S, [studentPrefers(X, Y) | Z], L) :- X \== S, Y \== L, fetchStudentPreferenceList(S, Z, L).
fetchEmployerPreferenceList(E, [employerPrefers(E, L) | _], L).
fetchEmployerPreferenceList(E, [employerPrefers(X, Y) | Z], L) :- X \== E, Y \== L, fetchEmployerPreferenceList(E, Z, L). 

prefers(X, Y1, Y2, L) :-
	choice(X,Y1, L, N1),
	choice(X,Y2, L, N2),
	N1 < N2. 

choice(_, Y, [Y|_], 1). 
choice(X, Y, [_|A], M) :- choice(X, Y, A, MP), M is 1 + MP.

writeCSV(M) :- findall(row(E,S), (member(pair(E,S), M), member(pair(E,S), M)), Rows),csv_write_file('matches_prolog_10x10.csv', Rows).
