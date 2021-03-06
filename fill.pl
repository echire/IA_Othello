:-module('fill', [fillAndFlip/5]).
:-use_module([library(lists),io]).

% replace a single cell in a list-of-lists
% - the source list-of-lists is L
% - The cell to be replaced is indicated with a row offset (X)
%   and a column offset within the row (Y)
% - The replacement value is Z
% - the transformed list-of-lists (result) is R
replace( L , X , Y , Z , R ) :-
  append(RowPfx,[Row|RowSfx],L),     % decompose the list-of-lists into a prefix, a list and a suffix
  length(RowPfx,X) ,                 % check the prefix length: do we have the desired list?
  append(ColPfx,[_|ColSfx],Row) ,    % decompose that row into a prefix, a column and a suffix
  length(ColPfx,Y) ,                 % check the prefix length: do we have the desired column?
  append(ColPfx,[Z|ColSfx],RowNew) , % if so, replace the column with its new value
  append(RowPfx,[RowNew|RowSfx],R)   % and assemble the transformed list-of-lists
  .

copy(L,R) :- accCp(L,R).
accCp([],[]).
accCp([H|T1],[H|T2]) :- accCp(T1,T2).



fillAndFlip(X,Y,Player,PreBoard,N8NewBoard):-
    io:getLegalMove(Player,X,Y,PreBoard),
    %writeln('pass'),
    replace(PreBoard,X,Y,Player,NewBoard),
    %writeln('after replace X,Y: '),io:displayBoard(NewBoard),
    io:chainDirection(Player,X,Y,-1,-1,N1,NewBoard),flipPiece(X,Y,Player,NewBoard,-1,-1,N1,N1NewBoard),
    %writeln('after -1,-1: '),io:displayBoard(N1NewBoard),
    io:chainDirection(Player,X,Y,-1,0,N2,N1NewBoard),flipPiece(X,Y,Player,N1NewBoard,-1,0,N2,N2NewBoard),
    %writeln('after -1,0: '),io:displayBoard(N2NewBoard),
    io:chainDirection(Player,X,Y,-1,1,N3,N2NewBoard),flipPiece(X,Y,Player,N2NewBoard,-1,1,N3,N3NewBoard),
    %writeln('after -1,1: '),io:displayBoard(N3NewBoard),
    io:chainDirection(Player,X,Y,0,1,N4,N3NewBoard),flipPiece(X,Y,Player,N3NewBoard,0,1,N4,N4NewBoard),
    %writeln('after 0,1: '),io:displayBoard(N4NewBoard),
    io:chainDirection(Player,X,Y,1,1,N5,N4NewBoard),flipPiece(X,Y,Player,N4NewBoard,1,1,N5,N5NewBoard),
    %writeln('after 1,1: '),io:displayBoard(N5NewBoard),
    io:chainDirection(Player,X,Y,1,0,N6,N5NewBoard),flipPiece(X,Y,Player,N5NewBoard,1,0,N6,N6NewBoard),
    %writeln('after 1,0: '),io:displayBoard(N6NewBoard),
    io:chainDirection(Player,X,Y,1,-1,N7,N6NewBoard),flipPiece(X,Y,Player,N6NewBoard,1,-1,N7,N7NewBoard),
    %writeln('after 1,-1: '),io:displayBoard(N7NewBoard),
    io:chainDirection(Player,X,Y,0,-1,N8,N7NewBoard),flipPiece(X,Y,Player,N7NewBoard,0,-1,N8,N8NewBoard).
    %write('N8 = '),writeln(N8),
    %writeln('after 0,-1: '),
    %io:displayBoard(N8NewBoard).

flipPiece(_,_,_,Board,_,_,0,NewBoard):-
    %writeln('Enter N=0'),
    copy(Board,NewBoard),!.
flipPiece(_,_,_,Board,_,_,N,NewBoard):-
    N<0,
    %writeln('Enter N<0'),
    copy(Board,NewBoard),!.
flipPiece(X,Y,Player,Board,U,V,N,NBoard):-
    %writeln('enter flipPiece'),
    XX is X+U,
    YY is Y+V,
    replace(Board,XX,YY,Player,NewBoard),
    %writeln('After replace: '),
    %io:displayBoard(NewBoard),
    NN is N-1,
    %write('NN = '),writeln(NN),
    flipPiece(XX,YY,Player,NewBoard,U,V,NN,NBoard).


