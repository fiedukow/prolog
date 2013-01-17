%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%            INDUKCJA REGUŁ - PROJEKT JPS                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                         %%
%%   Autorzy:                                              %%
%%      -> Marcin Bożek                                    %%
%%      -> Andrzej Fiedukowicz                             %%
%%      -> Maciej Grzybek                                  %%
%%      -> Edward Miedziński                               %%
%%                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

showCandidates(LastVar) :-
  findall(Cand/LastVarAfter, candidate(LastVar, Cand, LastVarAfter), List),
  writeList(List), nl.

% Zwraca jako listę struktur rule_var, 
% kolejnego kandydata dla zadanej relacji przy LastVar dotychczas uzytych zmiennych rule_var
% candidate(+Relation, +LastVar, -Result)
candidate(LastVar, Candidate, LastVarAfter) :-
  setof(X/ArgNo, R^(op(R), functor(R,X,ArgNo)), Relations),
  member(Relation, Relations),
  generateCandidate(LastVar,Relation,Candidate,LastVarAfter).

writeList([]).

writeList([E | Lista]) :-
  write(E), nl,
  writeList(Lista).
  
generateCandidate(0, _, _, _) :-
  !, write('Tak byc nie moze!'), nl,
  fail.

%przeklada relacje na ilosc jej arguementow bowiem zeby wygenerowac mozliwe dopasowania zmiennych
%nie trzeba wiedziec do jakiej relacji dopasowywujemy ale tylko ile argumentow jest do dopasowania
%oraz ile zmiennych zostalo uzytych do tej pory (licznik).
generateCandidate(LastVar, Relacja/ArgNo, Cand, LastVarAfter) :-
  generateCandidateArgNo(LastVar, ArgNo, Dopasowanie, LastVarAfter),
  Cand =.. [Relacja|Dopasowanie].

generateCandidateArgNo(LastVar, ArgNo, Dopasowanie, LastVarAfter) :-
  constructOldList(ArgNo, LastVar, Stare), 
  length(Stare, IleStarych),
  IleNowych is ArgNo - IleStarych,
  constructNList(IleNowych, Nowe, LastVar, LastVar, LastVarAfter), 
  appendRandom(Nowe, Stare, Dopasowanie).
  
constructOldList(0, _,  []) :- !, fail.

constructOldList(MaxLenght, VarOld, Lista) :-
  constructNListFromCands(MaxLenght, Lista, VarOld).

constructOldList(MaxLenght, Zmienne, Lista) :-
  MaxLenght1 is MaxLenght - 1, 
  constructOldList(MaxLenght1, Zmienne, Lista).

constructNListFromCands(0, [], _) :- !.

constructNListFromCands(N, [Var | List], VarOld) :-
  N1 is N - 1, 
  getVarBetween(1, VarOld, Var),
  constructNListFromCands(N1, List, VarOld).

getVarBetween(Var,_,ruleVar(Var)).

getVarBetween(Beg,End,Var) :-
  Beg < End,
  Beg1 is Beg + 1,
  getVarBetween(Beg1,End,Var).


constructNList(N, List, LastVar, LastVarEnd) :-
  constructNList(N, List, LastVar, LastVar, LastVarEnd).

constructNList(0, [], _, X, X) :- !.

%wersja dodajaca nowa zmienna do aktualnej listy
constructNList(N, [rule_var(LastVarAfter1) | List], LastVar, LastVarAfter, LastVarEnd) :-
  N1 is N - 1,
  LastVarAfter1 is LastVarAfter + 1,
  constructNList(N1, List, LastVar, LastVarAfter1, LastVarEnd).

%wersja korzystajaca z nowo dodanych zmiennych ale nie dodajaca wlasnych
constructNList(N, [X | List], LastVar, LastVarAfter, LastVarEnd) :-
  LastVarAfter > LastVar,
  N1 is N - 1, 
  Beg is LastVar + 1,
  End is LastVarAfter,
  getVarBetween(Beg, End, X),
  constructNList(N1, List, LastVar, LastVarAfter, LastVarEnd).


%Losowe laczenie dwoch list z zachowaniem kolejnosci w obrebie elementow
%pochodzacych z list pierwotnych
%np [a,b], [c,d] -> [a,b,c,d], [a,c,b,d], [a,c,d,b], [c,d,a,b], [c,a,d,b], [c,a,b,d]
appendRandom([], Lista2, Lista2) :- !.
appendRandom(Lista1, [], Lista1) :- !.

appendRandom([P | Lista1Rest], Lista2, [P | RestWynik]) :-
  appendRandom(Lista1Rest, Lista2, RestWynik).

appendRandom(Lista1, [P | Lista2Rest], [P | RestWynik]) :-
  appendRandom(Lista1, Lista2Rest, RestWynik).
  
  
op(ojciec(swirski, franek)).
op(matka(dominika, franek)).
op(kobieta(dominika)).
op(mezczyzna(swirski)).
op(ojciec(franek, darek)).
op(ojciec(franek, iga)).
op(matka(gosia, darek)).
op(matka(gosia, iga)).
op(mezczyzna(franek)).
op(rodzic(franek, darek)).
op(rodzic(franek, iga)).
op(rodzic(gosia, darek)).
op(rodzic(gosia, iga)).
op(brat(darek, iga, ktos)).
op(brat(darek, iga, kto)).
op(siostra(iga, darek)).
op(rodzenstwo(iga, darek)).
op(rodzenstwo(darek, iga)).
op(kobieta(iga)).
op(mezczyzna(darek)).

example(pos(dziadek(swirski, iga))).
example(pos(dziadek(swirski, darek))).
example(pos(babcia(dominika, iga))).
example(pos(babcia(dominika, darek))).

