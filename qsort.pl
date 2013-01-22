conc([],L2,L2).
conc([X|L1],L2,[X|O]) :-
  conc(L1,L2,O).

split(_,[],[],[]).
split(X1/X2/X3,[E1/E2/E3|A],[E1/E2/E3|L],R) :-
  E3 >= X3,
  split(X1/X2/X3,A,L,R).
split(X1/X2/X3,[E1/E2/E3|A],L,[E1/E2/E3|R]) :-
  E3 < X3,
  split(X1/X2/X3,A,L,R).

qsort([],[]).

qsort([X|Input],Output) :-
  split(X,Input,Lower,Higher),
  qsort(Lower,SortedLower),
  qsort(Higher,SortedHigher),
  conc(SortedLower,[X|SortedHigher],Output),!.

