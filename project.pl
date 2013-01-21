% Figure 18.11  A program that induces if-then rules.

% Learning of simple if-then rules
:- [candidate].
:-  op(300, xfx, <==).

% learn(Class): collect learning examples into a list, construct and
% output a description for Class, and assert the corresponding rule about Class
learn(Class)  :-
   bagof(example(ClassX, Obj), example(ClassX, Obj), Examples),        % Collect examples
   learn(Examples, Class, Description),                                  % Induce rule   
   nl, write(Class), write('  <== '), nl,                                % Output rule   
   writelist(Description),
   assert(Class  <==  Description).                                      % Assert rule

% learn(Examples, Class, Description):
%    Description covers exactly the examples of class Class in list Examples

learn(Examples, Class, [])  :-
   not(member(example(Class, _ ), Examples)).               % No example to cover 

learn(Examples, Class, [Conj | Conjs])  :-
   learn_conj(Examples, Class, Conj),
   remove(Examples, Conj, RestExamples),                    % Remove examples that match Conj   
   learn(RestExamples, Class, Conjs).                       % Cover remaining examples 

% learn_conj(Examples, Class, Conj):
%    Conj is a list of attribute values satisfied by some examples of class Class and
%    no other class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLearn(Relation, Conj) :-
  Relation =.. [Rel | _],
  findall(example(X), (example(X), X=..[_,EX], EX=..[Rel|_]), Examples),
  learn_conj(Examples, Relation, Conj).

%Check if there is any negative example in examples list connected with Relation
%negativeExample(+Examples, +Relation)
negativeExample(Examples, Relation) :-
  Relation =.. [RelationName | _],
  member(example(neg(NegExample)), Examples),
  NegExample =.. [RelationName | _].

%Podaj tylko Example dla relacji ktora cie interesuje!!!
%learn_conj(+Examples, +Relation, -Conj).
learn_conj(Examples, Relation, Conj) :-
  functor(Relation, Relation, LastVar),
  learn_conj(Examples, Relation, LastVar, [], Conj). 


%zamkniecie rekurencji przepisuje zebrana liste na wyjscie.
learn_conj(Examples, Relation, _, Conj, Conj)  :-
   not(negativeExample(Examples, Relation)), !.   % There is no negative example
                                                  % TODO is there any covered positive 

learn_conj(Examples, Relation, LastVar, ConjCurrent, Conj)  :-
   choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar),    % choose one cond using score   
   filter(Examples, [Cond | ConjCurrent], NewLastVar, Examples1),   % filter Examples using what 
                                                                    % you already created
   learn_conj(Examples1, Relation, NewLastVar, [Cond | ConjCurrent], Conj).   % 

%choose_cond(+Examples, +Relation, +LastVar, +ConjCurrent, -Cond, -NewLastVar)
choose_cond(Examples, Relation, LastVar, ConjCurrent, Cond, NewLastVar)  :-
   findall(CondCand/NewLastVar/Score, score(Examples, Relation, LastVar, ConjCurrent, CondCand, Score, NewLastVar), CondCands),
   best(CondCands, Cond/NewLastVar).                                 % Best score attribute value 

best([AttVal/LV/_], AttVal/LV).

best([AV0/LV0/S0, AV1/LV1/S1 | AVSlist], AttVal)  :-
   S1  >  S0, !,                                             % AV1 better than AV0   
   best([AV1/LV1/S1 | AVSlist], AttVal)
   ;
   best([AV0/LV0/S0 | AVSlist], AttVal).


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
   filter(Examples, [CondCand | ConjCurrent], NewLastVar, Examples1),      % Examples1 satisfy condition Att = Val     
   length(Examples1, N1),                       % Length of list   
   count_pos(Examples1, NPos1),          % Number of positive examples   
   NPos1 > 0,                                    % At least one positive example matches AttVal
   Score is 2 * NPos1 - N1.

%suitable(AttVal, Examples, Class)  :-            
%    % At least one negative example must not match AttVal
%   member(example(ClassX, ObjX), Examples),
%   ClassX \== Class,                                           % Negative example   
%   not(satisfy(ObjX, [AttVal])).                           % that does not match 

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

:- [examples].
