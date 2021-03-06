:-module('ai4',[chooseMove4/4]).
:-use_module([library(apply),io,fill,end,utils,ai3]).

bwTurn(Board,Color) :-
    countPiece(Board,NBlack,NWhite),
    NPiece is NBlack+NWhite,
    X is (NPiece-4) mod 2,
    (   X =:= 0 -> Color is 1;
    X =:= 1 -> Color is -1).

chooseMove4(AI,X,Y,Board):-
    findall([X,Y],getLegalMove(AI,X,Y,Board),MoveList)
    .

minimax(AI,CurrentPlayer,Board, BestNextBoard, Eval) :-
    (noMoreLegalSquares(Board)->
		checkWinner(Board,Winner),
		(Winner =:= AI -> BestNextBoard is Board, Eval is 99999,!;
		Winner =:= -AI -> BestNextBoard is Board, Eval is -99999;
                Winner =:= 0 -> BestNextBoard is Board, Eval is 0);
    noMoreLegalSquares(Board,CurrentPlayer)->changePlayer(CurrentPlayer,Player);
    Player is CurrentPlayer),
    findall([X,Y],getLegalMove(Player,X,Y,Board),MoveList),
    maplist(ai3:fillAndFlipTemp(Board,Player),MoveList,BoardList),
    best(AI,Player,BoardList, BestNextBoard, Eval,3),!.

best(_,_,_,_,_,_,0).

best(AI,CurrentPlayer,[Board], Board, Val,_) :-
    minimax(AI,CurrentPlayer,Board, _, Val), !.

best(AI,CurrentPlayer,[Board1 | BoardList], BestBoard, BestVal,Depth) :-
    Oppo is -CurrentPlayer,
    minimax(AI,Oppo,Board1, _, Eval1),
    NewDepth is Depth-1,
    best(AI,CurrentPlayer,BoardList, Board2, Eval2,NewDepth),
    betterOf(AI,Board1, Eval1, Board2, Eval2, BestBoard, BestVal).

betterOf(AI,Board0, Eval0, _, Eval1, Board0, Eval0) :-
    bwTurn(Board0,Color),
    Color =:= AI,
    Eval0 > Eval1, !.

betterOf(AI,Board0, Eval0, _, Eval1, Board0, Eval0) :-
    bwTurn(Board0,Color),
    Color =:= -AI,
    Eval0 < Eval1, !.

betterOf(_,_, _, Board1, Eva1, Board1, Eval1).        % Otherwise Pos1 better than Pos0


