% Examples of usage:
%  covered(3,[dziadekEdka,ojciecEdka,edek],[ojciec(ojciecEdka,edek),ojciec(dziadekEdka,ojciecEdka)],[dziadek(dziadekEdka,edek)],dziadek(rule_var(1),rule_var(2)),[ojciec(rule_var(3),rule_var(2)),ojciec(rule_var(1),rule_var(3))]).

op(ojciec(ojciecEdka,edek)).
op(ojciec(dziadekEdka,ojciecEdka)).
op(ojciec(pradziadekEdka,dziadekEdka)).

%satisfy(Successor,Examples,Conjunction,OutputList) :-
%  findall(Covered,
%                  (member(Covered,Examples),
%                   covered(Examples,Covered,Conjunction)),
%                  OutputList).

%coveredExt(Object,Conjunction) :-
%  lastVar(RuleVarNum), % ilosc rule_var'ow w systemie
%  generateAssocList(RuleVarNum,AssocList),

% Object = dziadek(rule_var(1),rule_var(2))
% Conjunction = [ojciec(rule_var(3),rule_var(2)), ojciec(rule_var(1),rule_var(3))]

%Interfejs opakowujacy Przyklad - podaje jako liste jednoelementowa do dalszej obrobki.
satisfy(RuleVarNum,Example,Object,Conjunction) :-
  covered(RuleVarNum,[Example],Object,Conjunction).

%Sprawdza czy Conjunction pokrywa Object w kontekscie Examples
%RuleVarNum to maksymalny indeks w rule_var(X),
% przechowujemy liczbe, zeby uniknac przechowywania listy rule_var'ow
%Examples w postaci relacja(argument1,argument2,...)
%Object to nastepnik implikacji (do udowodnienia, bez uzgodnionych zmiennych (rule_var zamiast zmiennej)
%Conjunction to koniunkcja Cond'ow, reprezentowana jako lista relacji, bez uzgodnionych zmiennych (rule_vary).
%
%covered(+RuleVarNum,+Examples,+Object,+Conjunction).
covered(RuleVarNum,Examples,Object,Conjunction) :-
  extractPeople(Examples,People),
  generateAssocList(People,RuleVarNum,AssocList),
  Object =.. [Successor|RuleVars],
  assocLists(RuleVars,AssocList,AssociatedVars),
  ReadyRule =.. [Successor|AssociatedVars],
  checkExamples(Examples,[ReadyRule]),
  coversCond(Conjunction,AssocList).
  

%iteruje po elementach listy i weryfikuje czy po podstawieniu (rule_var) pokrywa przyklady
%Examples lista przykladow, patrz covered
%Conjunction koniunkcja Cond'ów, patrz covered
%AssocList lista dopasowan, postaci 1=a, 2=b, ...
%Output lista Cond'ów z podstawieniami
%coversCond(+Examples,+Conjunction,+AssocList)
coversCond(Conjunction,AssocList) :-
  coversCondImpl(Conjunction,AssocList,_).

coversCondImpl([],_,[]) :- !.
coversCondImpl([Cond|Rest],AssocList,[ReadyRule|Output]) :-
  Cond =.. [Pred|RuleVars],
  assocLists(RuleVars,AssocList,ReadyRuleVars),
  ReadyRule =.. [Pred|ReadyRuleVars],
  coversCondImpl(Rest,AssocList,Output),
  check(Output).

%sprawdza czy zbudowany (przy zasocjowanych rule_var'y->zmienne) kazdy Cond ma pokrycie w faktach operacyjnych
%check(+Predicates).
check([]) :- !.
check([X|Predicates]) :-
  check(Predicates),
  op(X),!.

%sprawdza czy zbudowany (przy zasocjowanych rule_var'y->zmienne) kazdy Cond ma pokrycie w podanej liscie Examples
%check(+Examples,+Predicates).
checkExamples(_,[]) :- !.
checkExamples(Examples,[X|Predicates]) :-
  checkExamples(Examples,Predicates),
  member(X,Examples),!.

%buduje liste dopasowan na podstawie listy asocjacji
%np. dla RuleVars = [rule_var(1),rule_var(2)], AssocList = [1=a,2=b], Output daje postaci [a, b]
%assocLists(+RuleVars,+AssocList,-Output)
assocLists([],_,[]).
assocLists([R|RuleVars],AssocList,[X|Output]) :-
  getAssocVar(AssocList,R,X),
  assocLists(RuleVars,AssocList,Output).

%wyciaga liste ludzi na podstawie Examples i OPs.
extractPeople(Examples,Output) :-
  findall(Mem,
              (member(A,Examples),
               A =.. [_|Out],
               member(Mem,Out)),
              ExPeople),
  findall(Mem,
              (op(A),
               A =.. [_|Out],
               member(Mem,Out)),
              OpPeople),
  append(OpPeople,ExPeople,P),
  removeDuplications(P,Output).

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

getAssocVar([Id=V|_],rule_var(Id),V) :- !.
getAssocVar([Id=_|AssocList],rule_var(GivenID),Output) :-
  GivenID \= Id,
  getAssocVar(AssocList,rule_var(GivenID),Output).

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

