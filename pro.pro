%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                   PROJEKT Z COBOLA                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                         %%
%%   Autorzy:                                              %%
%%      -> Andrzej Fiedukowicz                             %%
%%      -> Maciej Grzybek                                  %%
%%                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

candidate(Relation, LastVar, Result) :-
  findall(Dopasowania/LastVarAfter, generateFit(LastVar,Relation,Dopasowania,LastVarAfter), Result).

pokazWszystko(LastVar, Relacja) :-
  findall(Dopasowania/LastVarAfter, generateFit(LastVar,Relacja,Dopasowania,LastVarAfter), Lista),
  writeList(Lista),nl.

writeList([]).

writeList([E | Lista]) :-
  write(E), nl,
  writeList(Lista).
  
generateFit([], _, _) :-
  write('Tak byc nie moze!'), nl.

%przeklada relacje na ilosc jej arguementow bowiem zeby wygenerowac mozliwe dopasowania zmiennych
%nie trzeba wiedziec do jakiej relacji dopasowywujemy ale tylko ile argumentow jest do dopasowania
%oraz ile zmiennych zostalo uzytych do tej pory (licznik).
generateFit(LastVar, Relacja, Dopasowanie, LastVarAfter) :-
  op(RelExample),
  functor(RelExample,Relacja,ArgNo), !, %ustalamy jaka krotnosc ma relacja, nie przegladamy wszystkich
                                        %faktow operacyjnych dla danej relacji - odciecie.
  write(ArgNo), nl,
  genFitKnownLimit(LastVar, ArgNo, Dopasowanie, LastVarAfter).

genFitKnownLimit(LastVar, ArgNo, Dopasowanie, LastVarAfter) :-
  constructOldList(ArgNo, LastVar, Stare), 
  length(Stare, IleStarych),
  IleStarych > 0,
  IleNowych is ArgNo - IleStarych,
  constructNList(IleNowych, Nowe, LastVar, LastVar, LastVarAfter), 
  appendRandom(Nowe, Stare, Dopasowanie).
  
constructOldList(0, _,  []) :- !.

constructOldList(MaxLenght, VarOld, Lista) :-
  constructNListFromCands(MaxLenght, Lista, VarOld).

constructOldList(MaxLenght, Zmienne, Lista) :-
  MaxLenght1 is MaxLenght - 1, 
  constructOldList(MaxLenght1, Zmienne, Lista).

constructNListFromCands(0, [], _) :- !.

constructNListFromCands(N, [Var | List], VarOld) :-
  N > 0,
  getVarSmallerEqThen(VarOld, Var),
  N1 is N - 1, 
  constructNListFromCands(N1, List, VarOld).

getVarSmallerEqThen(Limit, rule_var(Limit)).

getVarSmallerEqThen(Limit, Result) :-
  Limit > 1,
  Limit1 is Limit - 1,
  getVarSmallerEqThen(Limit1, Result).

getVarBetween(Var,_,ruleVar(Var)).

getVarBetween(Beg,End,Var) :-
  Beg \= End,
  Beg1 is Beg + 1,
  getVarBetween(Beg1,End,Var).

constructNList(0, [], _, X, X) :- !.

%wersja dodajaca nowa zmienna do aktualnej listy
constructNList(N, [rule_var(LastVarAfter1) | List], LastVar, LastVarAfter, LastVarEnd) :-
  N > 0,
  N1 is N - 1,
  LastVarAfter1 is LastVarAfter + 1,
  constructNList(N1, List, LastVar, LastVarAfter1, LastVarEnd).

%wersja korzystajaca z nowo dodanych zmiennych ale nie dodajaca wlasnych
constructNList(N, [X | List], LastVar, LastVarAfter, LastVarEnd) :-
  LastVarAfter > LastVar,
  N > 0,
  N1 is N - 1, 
  Beg is LastVar + 1,
  End is LastVarAfter,
  getVarBetween(Beg, End, X),
  constructNList(N1, List, LastVar, LastVarAfter, LastVarEnd).

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
op(siostra(iga, darek)).
op(rodzenstwo(iga, darek)).
op(rodzenstwo(darek, iga)).
op(kobieta(iga)).
op(mezczyzna(darek)).

example(pos(dziadek(swirski, iga))).
example(pos(dziadek(swirski, darek))).
example(pos(babcia(dominika, iga))).
example(pos(babcia(dominika, darek))).

relations([ojciec/2,matka/7,mezczyzna/1,kobieta/1,rodzic/2,brat/3,siostra/2,rodzenstwo/2]).
people([franek, darek, iga, gosia, swirski, dominika]).
