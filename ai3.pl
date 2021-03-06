:-module('ai3',[chooseMove3/4]).
:-use_module([library(apply),io,fill,end,utils]).

%    A  B  C  D  E  F  G  H
% 1 20 -3 11  8  8 11 -3 20
% 2 -3 -7 -4  1  1 -4 -7 -3
% 3 11 -4  2  2  2  2 -4 11
% 4  8  1  2 -3 -3  2  1  8
% 5  8  1  2 -3 -3  2  1  8
% 6 11 -4  2  2  2  2 -4 11
% 7 -3 -7 -4  1  1 -4 -7 -3
% 8 20 -3 11  8  8 11 -3 20


frontierLength(Board,Player,[X,Y],L):-
    %write(X),write(','),writeln(Y),
    checkBorder(Player,X,Y,_,_,Board,L).
    %writeln(L).

getTotalFrontierLength(Player,Board,L):-
    findall([X,Y],getVal(Board,X,Y,0),R),
    %writeln(R),
    maplist(frontierLength(Board,Player),R,RL),
    sumList(RL,L).

checkBorder(Player,X,Y,-1,-1,Board,N):-
    XX is X-1,
    YY is Y-1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,-1,0,Board,N):-
    XX is X-1,
    YY is Y,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,-1,1,Board,N):-
    XX is X-1,
    YY is Y+1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,0,1,Board,N):-
    XX is X,
    YY is Y+1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,1,1,Board,N):-
    XX is X+1,
    YY is Y+1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,1,0,Board,N):-
    XX is X+1,
    YY is Y,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,1,-1,Board,N):-
    XX is X+1,
    YY is Y-1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(Player,X,Y,0,-1,Board,N):-
    XX is X,
    YY is Y-1,
    (   isOnBoard(XX,YY) -> getVal(Board,XX,YY,Player),N is 1,!).
checkBorder(_,_,_,_,_,_,N):-N is 0.

evalPotentialMobility(Player,Board,E):-
    getTotalFrontierLength(Player,Board,L1),
    changePlayer(Player,Oppo),
    getTotalFrontierLength(Oppo,Board,L2),
    (    L1 > L2 -> E is -100*L1/(L1+L2);
    L1 < L2 -> E is 100*L2/(L1+L2);
    L1 = L2 -> E is 0).

mobility(Player,Board,N):-
    count(getLegalMove(Player,_,_,Board),N).

evalMobility(Player,Board,E):-
    mobility(Player,Board,N1),
    changePlayer(Player,Oppo),
    mobility(Oppo,Board,N2),
    (   N2 =:= 0 -> E is 150;
    N1 =:= 0 -> E is -450;
    N1 > N2 -> E is 100*N1/(N1+N2);
    N1 < N2 -> E is -100*N2/(N1+N2);
    N1 = N2 -> E is 0).

isValueBoard(VBoard):-
    VBoard = [[20,-3,11, 8, 8,11,-3,20],
              [-3,-7,-4, 1, 1,-4,-7,-3],
              [11,-4, 2, 2, 2, 2,-4,11],
              [ 8, 1, 2,-3,-3, 2, 1, 8],
              [ 8, 1, 2,-3,-3, 2, 1, 8],
              [11,-4, 2, 2, 2, 2,-4,11],
              [-3,-7,-4, 1, 1,-4,-7,-3],
              [20,-3,11, 8, 8,11,-3,20]].

getPositionValue(X,Y,V):-
    isValueBoard(VBoard),
    getVal(VBoard,X,Y,V).

evalPosition(Player,Board,E):-
    isValueBoard(VBoard),
    dot2(Board,VBoard,R),
    (   Player =:= -1 -> E is -R;
    E is R).

evalCorner(Player,Board,E):-
    getVal(Board,0,0,V1),
    getVal(Board,0,7,V2),
    getVal(Board,7,0,V3),
    getVal(Board,7,7,V4),
    R is 25*(V1+V2+V3+V4),
    (   Player =:= -1 -> E is -R;
    E is R).

evalDanger(Player,Board,E):-
    getVal(Board,0,1,VP1),
    getVal(Board,0,6,VP2),
    getVal(Board,1,0,VP3),
    getVal(Board,1,7,VP4),
    getVal(Board,6,0,VP5),
    getVal(Board,6,7,VP6),
    getVal(Board,7,1,VP7),
    getVal(Board,7,6,VP8),
    getVal(Board,1,1,VS1),
    getVal(Board,1,6,VS2),
    getVal(Board,6,1,VS3),
    getVal(Board,6,6,VS4),
    R is -12.5*(VP1+VP2+VP3+VP4+VP5+VP6+VP7+VP8+2*VS1+2*VS2+2*VS3+2*VS4),
    (   Player =:= -1 -> E is -R;
    E is R).

evalBWRate(Player,Board,E):-
    countPiece(Board,NBlack,NWhite),
    (   (Player =:= -1,NBlack > NWhite) -> E = 100*NBlack/(NBlack+NWhite);
    (Player =:= -1,NBlack < NWhite) -> E = -100*NWhite/(NBlack+NWhite);
    (Player =:= 1,NWhite > NBlack) -> E = 100*NWhite/(NBlack+NWhite);
    (Player =:= 1,NWhite < NBlack) -> E = -100*NBlack/(NBlack+NWhite);
    (NBlack =:= NWhite) -> E = 0).

%calculer le nombre des pièces stables

countTurn(Board,N):-
    countPiece(Board,NBlack,NWhite),
    N is (NBlack+NWhite-5)/2.

eval(Player,Board,E):-
    countTurn(Board,Turn),
    evalPosition(Player,Board,PositionEval),
    evalCorner(Player,Board,CornerEval),
    evalDanger(Player,Board,DangerEval),
    evalBWRate(Player,Board,RateEval),
    evalMobility(Player,Board,MobilityEval),
    evalPotentialMobility(Player,Board,PotentialMobilityEval),
    (         Turn > 23 -> E is 0.2*RateEval+0.6*DangerEval+8*CornerEval+0.24*MobilityEval+0.01*PositionEval+0.24*PotentialMobilityEval;
    between(21,23,Turn) -> E is 0.15*RateEval+1.2*DangerEval+8*CornerEval+0.24*MobilityEval+0.01*PositionEval+0.24*PotentialMobilityEval;
    between(18,21,Turn) -> E is 0.12*RateEval+1.5*DangerEval+8*CornerEval+0.45*MobilityEval+0.04*PositionEval+0.66*PotentialMobilityEval;
    between(14,18,Turn) -> E is 0.08*RateEval+4.8*DangerEval+9.5*CornerEval+0.59*MobilityEval+0.09*PositionEval+0.89*PotentialMobilityEval;
    between( 8,14,Turn) -> E is 0.06*RateEval+4*DangerEval+9.5*CornerEval+(0.71-Turn/60)+0.12*PositionEval+1.02-Turn/50;
    between( 0, 8,Turn) -> E is 0.04*RateEval+3.9*DangerEval+7.5*CornerEval+(0.82-Turn/60)+0.09*PositionEval+1.27-Turn/50).

fillAndFlipTemp(Board,AI,[X,Y],NewBoard):-
    fillAndFlip(X,Y,AI,Board,NewBoard).

chooseMove3(AI,X,Y,Board):-
    findall([X,Y],getLegalMove(AI,X,Y,Board),MoveList),
    %writeln(MoveList),
    maplist(fillAndFlipTemp(Board,AI),MoveList,BoardList),
    maplist(eval(AI),BoardList,EvalList),
    listMax(EvalList,Max),
    getLegalMove(AI,X,Y,Board),
    fillAndFlip(X,Y,AI,Board,NewBoard),
    eval(AI,NewBoard,Max),
    utils:retransformeX(N,X),
    utils:retransformeY(Al,Y),
    reportMove(AI,N,Al),
    !.

findBestEval(AI,Board,Eval):-
    findall([X,Y],getLegalMove(AI,X,Y,Board),MoveList),
    %writeln(MoveList),
    maplist(fillAndFlipTemp(Board,AI),MoveList,BoardList),
    maplist(eval(AI),BoardList,EvalList),
    listMax(EvalList,Eval).

