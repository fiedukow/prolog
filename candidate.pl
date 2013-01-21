%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%            INDUKCJA REGUŁ - PROJEKT JPS                 %%
%%          Implementacja funkcji Candidate                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                         %%
%%   Autorzy:                                              %%
%%      -> Marcin Bożek                                    %%
%%      -> Andrzej Fiedukowicz                             %%
%%      -> Maciej Grzybek                                  %%
%%      -> Edward Miedziński                               %%
%%                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tymczasowa funkcja pokazujaca wszystkich kandydatow dla danej wartosci
% ilosci dotychczas uzytych zmiennych.
showCandidates(LastVar) :-
  findall(Cand/LastVarAfter, candidate(LastVar, Cand, LastVarAfter), List),
  writeList(List), nl.

% Zwraca kolejnych kandydatow z zalozeniem ze do  tej pory uzyto LastVar zmiennych rule_var 
% candidate(+LastVar, -Candidate, -NewValueOfLastVar)
candidate(LastVar, Candidate, LastVarAfter) :-
  setof(X/ArgNo, R^(op(R), functor(R,X,ArgNo)), Relations),
  member(Relation, Relations),
  generateCandidate(LastVar,Relation,Candidate,LastVarAfter).

% Funkcja pomocnicza wypisujaca kolejne elementy listy w nowych liniach
% writeList(+List)
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
%generateCandidate(+LastVar, +Relacja/ArgNo, -Cand, -NewValueOfLastVar)
generateCandidate(LastVar, Relacja/ArgNo, Cand, LastVarAfter) :-
  generateCandidateArguments(LastVar, ArgNo, Dopasowanie, LastVarAfter),
  Cand =.. [Relacja|Dopasowanie].

%generuje liste rule_varow o wielkosci ArgNo (lista argumentow dla danego kandydata)
%generateCandidateArguments(+LastVar, +ArgNo, -Dopasowanie, -NewValueOfLastVar)
generateCandidateArguments(LastVar, ArgNo, Dopasowanie, LastVarAfter) :-
  constructOldList(ArgNo, LastVar, Stare), 
  length(Stare, IleStarych),
  IleNowych is ArgNo - IleStarych,
  constructNList(IleNowych, LastVar, Nowe, LastVarAfter), 
  appendRandom(Nowe, Stare, Dopasowanie).
  
%konstruuje liste zmiennych o dlugosci mniejszej lub rownej MaxLenght
%ta funkcja NIE może dodawać swoich zmiennych, może tylko wykorzystywać stare
%constructOldList(+MaxLenght, +LastVar, -ListOfVariables)
constructOldList(0, _,  []) :- !, fail.

constructOldList(MaxLenght, VarOld, Lista) :-
  constructNListOld(MaxLenght, VarOld, Lista).

constructOldList(MaxLenght, Zmienne, Lista) :-
  MaxLenght1 is MaxLenght - 1, 
  constructOldList(MaxLenght1, Zmienne, Lista).

%konstruuje liste zmiennych o dlugosci rownej Length
%ta funkcja NIE może dodawać swoich zmiennych, może tylko wykorzystywać stare
%constructNListOld(+Length, +LastVar, -ListOfVariables)
constructNListOld(0, _, []) :- !.

constructNListOld(N, VarOld, [Var | List]) :-
  N1 is N - 1, 
  getVarBetween(1, VarOld, Var),
  constructNListOld(N1, VarOld, List).

%tworzy kolejne zmienne z zakresu od Beg do End (wlaczajac Beg i End)
%getVarBetween(+Beg,+End,-Var)
getVarBetween(Var,_,rule_var(Var)).

getVarBetween(Beg,End,Var) :-
  Beg < End,
  Beg1 is Beg + 1,
  getVarBetween(Beg1,End,Var).

%Tworzy liste zmiennych dlugosci N korzystajac tylko z nowych zmiennych
%W szczegolnosci nowe zmienne moga byc wykorzystane wielokrotnie
%Zwraca nowa wartosc LastVar!
%constructNList(+N, +LastVar, -List, -NewValueOfLastVar)
constructNList(N, LastVar, List, LastVarEnd) :-
  constructNList(N, LastVar, LastVar, List, LastVarEnd).

%Tworzy liste zmiennych dlugosci N korzystajac tylko z nowych zmiennych
%W szczegolnosci nowe zmienne moga byc wykorzystane wielokrotnie
%Zwraca nowa wartosc LastVar.
%Wersja z dodatkowym argumentem LastVarAfter ktory jest inkrementowany
%przy przejsciach przez wersje funkcji dodajaca nowe zmienne
%a na koniec przepisywany jako LastVarEnd.
%Z tej funkcji nalezy korzystac przez zaslepke 4ro argumentowa
%constructNList(+N, +LastVar, +LastVarAfter, -List, -LastVarEnd).
constructNList(0, _, X, [], X) :- !.

%wersja dodajaca nowa zmienna do aktualnej listy
constructNList(N, LastVar, LastVarAfter, [rule_var(LastVarAfter1) | List], LastVarEnd) :-
  N1 is N - 1,
  LastVarAfter1 is LastVarAfter + 1,
  constructNList(N1, LastVar, LastVarAfter1, List, LastVarEnd).

%wersja korzystajaca z nowo dodanych zmiennych ale nie dodajaca wlasnych
constructNList(N, LastVar, LastVarAfter, [X | List], LastVarEnd) :-
  LastVarAfter > LastVar,
  N1 is N - 1, 
  Beg is LastVar + 1,
  End is LastVarAfter,
  getVarBetween(Beg, End, X),
  constructNList(N1, LastVar, LastVarAfter, List, LastVarEnd).


%Losowe laczenie dwoch list z zachowaniem kolejnosci w obrebie elementow
%pochodzacych z list pierwotnych
%np [a,b], [c,d] -> [a,b,c,d], [a,c,b,d], [a,c,d,b], [c,d,a,b], [c,a,d,b], [c,a,b,d]
%appendRandom(+L1, +L2, -OutList)
appendRandom([], Lista2, Lista2) :- !.
appendRandom(Lista1, [], Lista1) :- !.

appendRandom([P | Lista1Rest], Lista2, [P | RestWynik]) :-
  appendRandom(Lista1Rest, Lista2, RestWynik).

appendRandom(Lista1, [P | Lista2Rest], [P | RestWynik]) :-
  appendRandom(Lista1, Lista2Rest, RestWynik).
  
  

