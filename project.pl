% Figure 18.11  A program that induces if-then rules.

% Learning of simple if-then rules
:- [candidate].
:- [satisfy].
:- [qsort].
:-  op(300, xfx, <==).

:- assert(condsLimit(0)).
% learn(Class): collect learning examples into a list, construct and
% output a description for Class, and assert the corresponding rule about Class
learn(Class)  :-
   bagof(example(ClassX, Obj), example(ClassX, Obj), Examples),        % Collect examples
   learn(Examples, Class, Description),                                  % Induce rule   
   nl, write(Class), write('  <== '), nl,                                % Output rule   
   writelist(Description),
   assert(Class  <==  Description).                                      % Assert rule


goLearn(Relation, Conjs) :-
   Relation =.. [Rel | _],
   findall(example(pos(X)), (example(pos(X)), X=..[Rel|_]), ExamplesPos),
   learn(Relation, ExamplesPos, Conjs).


remove(Examples, Conj, RestExamples) :-
   findall(example(UEX),
           (member(example(UEX), Examples), UEX=..[_,EX], not(satisfy(6,EX,Conj))),
           RestExamples).

% learn(Examples, Class, Description):
%    Description covers exactly the examples of class Class in list Examples

learn(_, [], []) :- !.

% Trzyma swoja liste przykladow pozytywnych
% Wola myLearn uzyskujac kolejne Conje
% Usuwa przyklady pokryte przez Conja
learn(Relation, Examples, [Conj | Conjs])  :-
   myLearn(Relation, Conj),
   %write('before: '), write(Examples), nl,
   remove(Examples, Conj, RestExamples),                    % Remove examples that match Conj   
   %write('after: '), write(RestExamples), nl,
   learn(Relation, RestExamples, Conjs).                       % Cover remaining examples 

% learn_conj(Examples, Class, Conj):
%    Conj is a list of attribute values satisfied by some examples of class Class and
%    no other class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLearn(Relation, Conj) :-
  Relation =.. [Rel | _],
  findall(example(X), (example(X), X=..[_,EX], EX=..[Rel|_]), Examples),
  learn_conj(Examples, Relation, Conj).

myLearn(Relation, Conj) :-
  retract(condsLimit(X)),
  X1 is X + 1,
  assert(condsLimit(X1)),
  myLearn(Relation, Conj).

%Check if there is any negative example in examples list connected with Relation
%negativeExample(+Examples, +Relation)
negativeExample(Examples) :-
%  Relation =.. [RelationName | _],
  member(example(neg(_)), Examples).
%  NegExample =.. [RelationName | _].

%Podaj tylko Example dla relacji ktora cie interesuje!!!
%learn_conj(+Examples, +Relation, -Conj).
learn_conj(Examples, Relation, Conj) :-
  functor(Relation, _, LastVar),
  learn_conj(Examples, Relation, LastVar, [], Conj). 


%zamkniecie rekurencji przepisuje zebrana liste na wyjscie.
learn_conj(Examples, Relation, _, Conj, Conj)  :-
   not(negativeExample(Examples)),
%   length(Examples, PosNo),
%   Relation =.. [Rel | _],
%   findall(example(pos(X)), (example(pos(X)), X=..[Rel|_]), AllPos),
%   length(AllPos, PosNo),
%   write('Examples: '), write(Examples), nl,
%   not(member(_, Examples)),
   !.   % There is no negative example
                                                  % TODO is there any covered positive 

learn_conj(Examples, Relation, LastVar, ConjCurrent, Conj)  :-
   condsLimit(CondsLimit),
   length(ConjCurrent, Len), Len =< CondsLimit,
   choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar),    % choose one cond using score   
   filter(Examples, [Cond | ConjCurrent], NewLastVar, Examples1),   % filter Examples using what 
                                                                    % you already created
   %write('Filter: '), write(Examples), nl,
   %write('To: '), write(Examples1), nl,
   learn_conj(Examples1, Relation, NewLastVar, [Cond | ConjCurrent], Conj).   % 

%choose_cond(+Examples, +Relation, +LastVar, +ConjCurrent, -Cond, -NewLastVar)
choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar)  :-
   findall(CondCand/NewLastVar/Score, score(Examples, Relation, LastVar, ConjCurrent, CondCand, Score, NewLastVar), CondCands),
   qsort(CondCands, Sorted), 
   member(Cond/NewLastVar/_, Sorted),
   write('New Cond: '), write(Cond), write(' '), write(NewLastVar), nl.                   % Best score attribute value 

% filter(Examples, Condition, Examples1):
%    Examples1 contains elements of Examples that satisfy Condition
filter(Examples, ConjCand, LastVar, Examples1)  :-
   findall(example(UEX),
           (member(example(UEX), Examples), UEX=..[_,EX], satisfy(LastVar,EX,ConjCand)),
           Examples1).

% remove(Examples, Conj, Examples1):
%    removing from Examples those examples that are covered by Conj gives Examples1

%remove([], _, []).

%remove([example(Class, Obj) | Es], Conj, Es1)  :-
%   satisfy(Obj, Conj), !,                                     % First example matches Conj   
%   remove(Es, Conj, Es1).                                     % Remove it 

%remove([E | Es], Conj, [E | Es1])  :-                         % Retain first example   
%   remove(Es, Conj, Es1).

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
%   write('Candidate: '), write(CondCand), write(' '), write(NewLastVar), write(' '), write(Score), nl.    
%   Best score attribute value 
%   write('With examples: '), write(Examples1), nl.

suitable(Examples, Conj, LastVar)  :-            
    % At least one negative example must not match AttVal
   findall(example(neg(X)), member(example(neg(X)), Examples), NegEx),
   filter(NegEx, Conj, LastVar, NegExAfter),
   length(NegEx, LB), length(NegExAfter, LA),
   LB > LA.

% count_pos(Examples, Class, N):
%    N is the number of positive examples of Class

count_pos([], 0).

count_pos([example(X) | Examples], N)  :-
   count_pos(Examples, N1),
   (functor(X, pos, _), !, N is N1 + 1; N = N1).


writelist([]).

writelist([X | L])  :-
   tab(2), write(X), nl,
   writelist(L).

:- [examples1].
