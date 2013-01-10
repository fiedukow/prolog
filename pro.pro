%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                   PROJEKT Z COBOLA                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                         %%
%%   Autorzy:                                              %%
%%      -> Andrzej Fiedukowicz                             %%
%%      -> Maciej Grzybek                                  %%
%%                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

learn([Relacja | Zmienne]) :-
  

pokazWszystko(Zmienne, Relacja) :-
  findall(Dopasowania, getAndFit(Zmienne,Relacja,Dopasowania), Lista),
  writeList(Lista),nl.

writeList([]).

writeList([E | Lista]) :-
  write(E), nl,
  writeList(Lista).
  
filterOnlyCovered(Zmienne, Relacja, Dopasowanie) :-
  example([Relacja | ConcreteVariables]),
  

getAndFit(Zmienne, Relacja, Dopasowania) :-
  generateFit(Zmienne, Relacja, Wynik, DodaneZmienne),
  append(Zmienne,DodaneZmienne,WszystkieZmienne),
  fitVariables(WszystkieZmienne, Dopasowania).

fitVariables(Zmienne, Dopasowania) :-
  fitVariables(Zmienne, Dopasowania, []).

fitVariables([], [], _).

fitVariables([Zmienna | ResztaZmiennych], [Zmienna=Osoba | ResztaDopasowan], Zakazy) :-
  people(People),
  member(Osoba, People),
  not(member(Osoba, Zakazy)),
  fitVariables(ResztaZmiennych, ResztaDopasowan, [Osoba | Zakazy]).
  
  
generateFit([], _, _) :-
  write('Tak byc nie moze!'), nl.

generateFit(Zmienne, Relacja, Dopasowanie, DodaneZmienne) :-
  relations(Relacje),
  member(Relacja/ArgNo, Relacje),
  genFitKnownLimit(Zmienne, ArgNo, Dopasowanie, DodaneZmienne).

genFitKnownLimit(Zmienne, ArgNo, Dopasowanie, Nowe) :-
  constructOldList(ArgNo, Zmienne, Stare), 
  length(Stare, IleStarych),
  IleStarych > 0,
  IleNowych is ArgNo - IleStarych,
  constructNList(IleNowych, Nowe), 
  appendRandom(Nowe, Stare, Dopasowanie).
  
constructOldList(0, _,  []) :- !.

constructOldList(MaxLenght, Zmienne, Lista) :-
  constructNListFromCands(MaxLenght, Lista, Zmienne).

constructOldList(MaxLenght, Zmienne, Lista) :-
  MaxLenght1 is MaxLenght - 1, 
  constructOldList(MaxLenght1, Zmienne, Lista).

constructNListFromCands(0, [], _) :- !.

constructNListFromCands(N, [Zmienna | List], Cands) :-
  N > 0,
  member(Zmienna, Cands),
  N1 is N - 1, 
  constructNListFromCands(N1, List, Cands).

constructNList(0, []) :- !.

constructNList(N, [N | List]) :-
  N > 0,
  N1 is N - 1, 
  constructNList(N1, List).

appendRandom([], Lista2, Lista2) :- !.
appendRandom(Lista1, [], Lista1) :- !.

appendRandom([P | Lista1Rest], Lista2, [P | RestWynik]) :-
  appendRandom(Lista1Rest, Lista2, RestWynik).

appendRandom(Lista1, [P | Lista2Rest], [P | RestWynik]) :-
  appendRandom(Lista1, Lista2Rest, RestWynik).
  
  
example([ojciec, franek, darek]).
example([ojciec, franek, iga]). 
example([matka, gosia, darek]). %
example([matka, gosia, iga]).
example([mezczyzna, franek]). %
example([kobieta, gosia]).
example([rodzic, franek, darek]). %
example([rodzic, franek, iga]). %
example([rodzic, gosia, darek]). %
example([rodzic, gosia, iga]).
example([brat, darek, iga]). %
example([siostra, iga, darek]). %
example([rodzenstwo, iga, darek]). %
example([rodzenstwo, darek, iga]). %
example([kobieta, iga]).
example([mezczyzna, darek]). %

relations([ojciec/2,matka/2,mezczyzna/1,kobieta/1,rodzic/2,brat/2,siostra/2,rodzenstwo/2]).
people([franek, darek, iga, gosia]).
