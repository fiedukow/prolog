satisfy(RuleVarNum, Example, Conjunction) :-
  people(People),
  Example =.. [_|Args],
  generateAssocList(People, RuleVarNum, Args, AssocList),
  coversCond(Conjunction, AssocList), !.

% GENEROWANIE LISTY ASOCJACYJNEJ
generateAssocList(People,Num,Args,Result) :-
  length(Args,ArgsCount),
  ToCombine is Num-ArgsCount,
  generateCombination(ToCombine,People,Values),
  permutation(Values,Permutation),				
  append(Args,Permutation,Input),
  tagList(1,Input,Result).

generateCombination(0,_,[]).
generateCombination(N,[X|T],[X|Comb]) :-
  N>0,
  N1 is N-1,
  generateCombination(N1,T,Comb).
generateCombination(N,[_|T],Comb) :-
  N>0,
  generateCombination(N,T,Comb).

tagList(_,[],[]).
tagList(N,[X|List],[N=X|Output]) :-
  N1 is N+1,
  tagList(N1,List,Output).

% SPRAWDZENIE POKRYCIA REGULY
coversCond([],_) :- !.
coversCond([Cond|Rest],AssocList) :-
  Cond =.. [Pred|RuleVars],
  assocLists(RuleVars,AssocList,ReadyRuleVars),
  ReadyRule =.. [Pred|ReadyRuleVars],
  op(ReadyRule),
  coversCond(Rest,AssocList).

assocLists([],_,[]).
assocLists([rule_var(Id)|RuleVars],AssocList,[X|Output]) :-
  getVal(Id,AssocList,X),
  assocLists(RuleVars,AssocList,Output).

getVal(Id,[Id=Val|_],Val) :- !.
getVal(Id,[_|AssocList],Val) :-
  getVal(Id,AssocList,Val).
