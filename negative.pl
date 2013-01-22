:- [examples].
generateNegativeExamples :-
  generateNegativeExample(Output),
  write('example(neg('),write(Output),write(')).'),nl,
  fail.

generateNegativeExamples.

generateNegativeExample(Output) :-
  extractAttributes(ExtractedAttrs),
  removeDuplications(ExtractedAttrs,ExtractedSet),
  combineSetOfElements(ExtractedSet,Output).

% wyciagamy osoby (zdzich, janek, jurek etc.)
extractAttributes(Output) :-
  findall(Mem,
            (example(pos(A)),
             A =.. [_|List],
             member(Mem,List)),
            Output).

% usun powtorzenia na InputList
removeDuplications([],[]).
removeDuplications([X|InputList],[X|OutputList]) :-
  removeAll(X,InputList,TempOutput),
  removeDuplications(TempOutput,OutputList).

% zwroc kombinacje wszystkich osob
combineSetOfElements(Input,Output) :-
  extractPredicates(Predicates),
  removeDuplications(Predicates,Preds),!, % optimization
  getArity(Preds,Name/Arity),
  generateCombinationRep(Arity,Input,Combination),
  Output =.. [Name|Combination].

getArity([],[]).
getArity([Name/Arity|_],Name/Arity).
getArity([_|Rest],Output) :-
  getArity(Rest,Output).

% wyciagnij predykaty (dziadek/2, babcia/2, mezyczyna/1 etc.)
extractPredicates(Output) :-
  findall(Name/Arity,(example(pos(A)),
                      functor(A,Name,Arity)),
                      Output).

% usun wszystkie wystapienia Element z InputList
removeAll(_,[],[]).
removeAll(Element,[Element|InputList],OutputList) :-
  removeAll(Element,InputList,OutputList).
removeAll(Element,[X|InputList],[X|OutputList]) :-
  Element \= X,
  removeAll(Element,InputList,OutputList).

generateCombinationRep(0,_,[]).
generateCombinationRep(N,[X|T],[X|Comb]) :-
  N>0,
  N1 is N-1,
  generateCombinationRep(N1,[X|T],Comb).
generateCombinationRep(N,[_|T],Comb) :- 
  N>0,
  generateCombinationRep(N,T,Comb).

