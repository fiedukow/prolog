% Figure 18.11  A program that induces if-then rules.

% Learning of simple if-then rules
:- [candidate].
:- [satisfy].
:- [qsort].

:- assert(condsLimit(0)).

goLearn(Relation, Conjs) :-
   Relation =.. [Rel | _],
   findall(example(pos(X)), (example(pos(X)), X=..[Rel|_]), ExamplesPos),
   learn(Relation, ExamplesPos, Conjs),
   show_rule(Relation, Conjs).

show_rule(_,[]).
show_rule(Relation, [Conj|Conjs]) :-
  write(Relation), write(' <= '), write(Conj), nl,
  show_rule(Relation, Conjs).

negativeExamples(Relation, Examples) :-
   Relation =.. [Rel | _],
   findall(example(neg(X)), (example(neg(X)), X=..[Rel|_]), Examples).


remove(Examples, Conj, LastVar, RestExamples) :-
   findall(example(UEX),
           (member(example(UEX), Examples), UEX=..[_,EX], not(satisfy(LastVar,EX,Conj))),
           RestExamples).

% learn(Examples, Class, Description):
%    Description covers exactly the examples of class Class in list Examples
learn(_, [], []) :- !.

% Trzyma swoja liste przykladow pozytywnych
% Wola myLearn uzyskujac kolejne Conje
% Usuwa przyklady pokryte przez Conja
learn(Relation, Examples, [Conj | Conjs])  :-
   negativeExamples(Relation, NegExamples),
   append(Examples, NegExamples, AllExamples),
   myLearn(Relation, AllExamples, Conj, LastVar),
   remove(Examples, Conj, LastVar, RestExamples),           % Remove examples that match Conj   
   learn(Relation, RestExamples, Conjs).                    % Cover remaining examples 

% learn_conj(Examples, Class, Conj):
%    Conj is a list of attribute values satisfied by some examples of class Class and
%    no other class

myLearn(Relation, AllExamples, Conj, LastVar) :-
  learn_conj(AllExamples, Relation, Conj, LastVar).

myLearn(Relation, AllExamples, Conj, LastVar) :-
  retract(condsLimit(X)),
  X1 is X + 1,
  assert(condsLimit(X1)),
  myLearn(Relation, AllExamples, Conj, LastVar).

%Check if there is any negative example in examples list connected with Relation
%negativeExample(+Examples, +Relation)
negativeExample(Examples) :-
  member(example(neg(_)), Examples), !.

%Podaj tylko Example dla relacji ktora cie interesuje!!!
%learn_conj(+Examples, +Relation, -Conj).
learn_conj(Examples, Relation, Conj, NewLastVar) :-
  functor(Relation, _, LastVar),
  learn_conj(Examples, Relation, LastVar, [], Conj, NewLastVar). 


%zamkniecie rekurencji przepisuje zebrana liste na wyjscie.
learn_conj(Examples, _, NewLastVar, Conj, Conj, NewLastVar)  :-
   not(negativeExample(Examples)),
   !.   % There is no negative example

learn_conj(Examples, Relation, LastVar, ConjCurrent, Conj, EndLastVar)  :-
   condsLimit(CondsLimit),
   length(ConjCurrent, Len), Len =< CondsLimit,
   choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar),    % choose one cond using score   
   filter(Examples, [Cond | ConjCurrent], NewLastVar, Examples1),   % filter Examples using what 
                                                                    % you already created
   learn_conj(Examples1, Relation, NewLastVar, [Cond | ConjCurrent], Conj, EndLastVar).   % 

%choose_cond(+Examples, +Relation, +LastVar, +ConjCurrent, -Cond, -NewLastVar)
choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar)  :-
   findall(CondCand/NewLastVar/Score, score(Examples, Relation, LastVar, ConjCurrent, CondCand, Score, NewLastVar), CondCands),
   qsort(CondCands, Sorted), 
   member(Cond/NewLastVar/_, Sorted).
%   write('New Cond: '), write(Cond), write(' '), write(NewLastVar), nl.                   % Best score attribute value 

% filter(Examples, Condition, Examples1):
%    Examples1 contains elements of Examples that satisfy Condition
filter(Examples, ConjCand, LastVar, Examples1)  :-
   findall(example(UEX),
           (member(example(UEX), Examples), UEX=..[_,EX], satisfy(LastVar,EX,ConjCand)),
           Examples1).

%score(+Examples, +Relation, +LastVar, +ConjCurrent, -CondCand, -Score, -NewLastVar)
score(Examples, Relation, LastVar, ConjCurrent, CondCand, Score, NewLastVar)  :-
   candidate(LastVar, CondCand, NewLastVar),
   %write('Base examples: '), write(Examples), nl,
   suitable(Examples, [CondCand | ConjCurrent], NewLastVar),
   filter(Examples, [CondCand | ConjCurrent], NewLastVar, Examples1),      % Examples1 satisfy condition Att = Val     
   length(Examples1, N1),                       % Length of list   
   count_pos(Examples1, NPos1),          % Number of positive examples   
   NPos1 > 0,                                    % At least one positive example matches AttVal
   Score is 2 * NPos1 - N1.

suitable(Examples, Conj, LastVar)  :-            
   findall(example(neg(X)), member(example(neg(X)), Examples), NegEx),
   filter(NegEx, Conj, LastVar, NegExAfter),
   length(NegEx, LB), length(NegExAfter, LA),
   LB > LA.

count_pos([], 0).

count_pos([example(X) | Examples], N)  :-
   count_pos(Examples, N1),
   (functor(X, pos, _), !, N is N1 + 1; N = N1).

:- [examples2].
