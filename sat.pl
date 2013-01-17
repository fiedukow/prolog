example(pos(dziadek(dziadekEdka,edek))).
example(pos(ojciec(ojciecEdka,edek))).
example(pos(ojciec(dziadekEdka,ojciecEdka))).

% [[dziadek,edek,chuj],...]
% [dziadek(edek,chuj),...]
satisfy(Successor,Examples,Conjunction,OutputList) :-
  findall(Covered,
                  (member(Covered,Examples),
                   covered(Examples,Covered,Conjunction)),
                  OutputList).

lastVar(3).

%coveredExt(Object,Conjunction) :-
%  lastVar(RuleVarNum), % ilosc rule_var'ow w systemie
%  generateAssocList(RuleVarNum,AssocList),

% Object = dziadek(rule_var(1),rule_var(2))
% Conjunction = [ojciec(rule_var(3),rule_var(2)), ojciec(rule_var(1),rule_var(3))]

%sprawdza czy Conjunction pokrywa Object w kontekscie Examples
covered(Examples,Object,Conjunction) :-
  lastVar(RuleVarNum),
  extractPeople(Examples,People),
  generateAssocList(People,RuleVarNum,AssocList),
  coversCond(Examples,Conjunction,AssocList,Output),
  Object =.. [Successor|RuleVars], %sprawdz czy dziadek(), dla podanych rule_var(1),rule_var(2)
  assocLists(RuleVars,AssocList,AssociatedVars),
  ReadyRule =.. [Successor|AssociatedVars],
  checkExamples(Examples,[ReadyRule]).
  

%iteruje po elementach listy i weryfikuje czy po podstawieniu (rule_var) pokrywa przyklady
coversCond(_,[],_,[]) :- !.
coversCond(Examples,[Cond|Rest],AssocList,[ReadyRule|Output]) :-
%  getElement(Conjunction,[Pred|RuleVars]), % wyciagnij kolejny element z Conjunction
  Cond =.. [Pred|RuleVars],
  assocLists(RuleVars,AssocList,ReadyRuleVars),
  ReadyRule =.. [Pred|ReadyRuleVars],
  coversCond(Examples,Rest,AssocList,Output),
  checkExamples(Examples,Output).

checkExamples(_,[]) :- !.
checkExamples(Examples,[X|Predicates]) :-
  checkExamples(Examples,Predicates),
  member(X,Examples),!.

assocLists([],_,[]).
assocLists([R|RuleVars],AssocList,[X|Output]) :-
  getAssocVar(AssocList,R,X),
  assocLists(RuleVars,AssocList,Output).

extractPeople([],[]).
extractPeople(Examples,People) :-
  findall(Mem,
              (member(A,Examples),
               A =.. [_|Out],
               member(Mem,Out)),
              Output),
  removeDuplications(Output,People).

generateAssocList(Examples,Num,Result) :-
  generateAssocListImpl(Examples,Num,Result).

generateAssocListImpl(Input,Num,RuleVars) :-
  generateCombination(Num,Input,Values),
  permutation(Values,Permutation),
  tagList(Permutation,Num,RuleVars).

tagList(_,0,[]).
tagList([X|List],Num,[Num=X|Output]) :-
  N1 is Num-1,
  tagList(List,N1,Output).

generateCombination(0,_,[]).
generateCombination(N,[X|T],[X|Comb]) :- 
  N>0,
  N1 is N-1,
  generateCombination(N1,T,Comb).
generateCombination(N,[_|T],Comb) :- 
  N>0,
  generateCombination(N,T,Comb).

getElement([X|_],Element) :-
  X =.. Element.
getElement([_|List],Element) :-
  getElement(List,Element).

getAssocVar([Id=V|_],rule_var(Id),V) :- !.
getAssocVar([Id=_|AssocList],rule_var(GivenID),Output) :-
  GivenID \= Id,
  getAssocVar(AssocList,rule_var(GivenID),Output).

% wyciagamy osoby (zdzich, janek, jurek etc.)
extractAttributes(Output) :-
  findall(Mem,
            (example(pos(A)),
             A =.. List,
             removeFirstN(List,1,Out),
             member(Mem,Out)),
            Output).

% usun powtorzenia na InputList
removeDuplications([],[]).
removeDuplications([X|InputList],[X|OutputList]) :-
  removeAll(X,InputList,TempOutput),
  removeDuplications(TempOutput,OutputList).

% usun wszystkie wystapienia Element z InputList
removeAll(_,[],[]).
removeAll(Element,[Element|InputList],OutputList) :-
  removeAll(Element,InputList,OutputList).
removeAll(Element,[X|InputList],[X|OutputList]) :-
  Element \= X,
  removeAll(Element,InputList,OutputList).

removeFirstN(InputList,0,InputList).
removeFirstN([_|InputList],N,Output) :-
  N > 0,
  N1 is N-1,
  removeFirstN(InputList,N1,Output).
