pragma solidity ^0.6.0;

abstract contract Commitment {

    enum Strenghts {Hard, Soft}
    Strenghts strenght;

    // Commitment state machine
    enum States { Null, Expired, Terminated, Pending, Conditional, Detached, Satisfied, Violated}
    States private state;
    States private lastState;

    enum Types {Goal, Persistent}
    Types cType;

    // Commitment template
    uint private minA;
    uint private maxA;
    uint private minC;
    uint private maxC;
    enum RefCs { Creation, Detached}
    RefCs private refC;


    // transition variables
    bool private beforeAWin;
    bool private inAWin;
    bool private afterAWin;
    bool private beforeCWin;
    bool private inCWin;
    bool private afterCWin;

    bool private condAHolds;
    bool private condCHolds;

    // time variables
    uint private timeCreation;
    uint private timeDetach;


    constructor (Strenghts _strenght, Types _cType, uint _minA, uint _maxA, uint _minC, uint _maxC, RefCs _refC) public {
        state = States.Null;
        strenght = _strenght;
        cType = _cType;
        minA = _minA;


        maxA = _maxA;
        minC = _minC;
        maxC = _maxC;
        refC = _refC;

    }



    function toDetached() private {
        state = States.Detached;
        // TODO emit event
    }
    function toConditional() private {
        state = States.Conditional;
        // TODO emit event
    }
    function toSatisfied() private {
        state = States.Satisfied;
        // TODO emit event
    }

    function toViolated() private {
        state = States.Violated;
        // TODO emit event
    }
    function toExpired() private {
        state = States.Expired;
        // TODO emit event
    }
    function toPending() private {
        state = States.Pending;
        // TODO emit event
    }
    function toTerminated() private {
        state = States.Terminated;
        // TODO emit event
    }


    function updateTransitionVariables() private {
        uint currentTime = now;
        condAHolds = condA();
        condCHolds = condC();


        beforeAWin = currentTime < timeCreation + minA;
        inAWin = currentTime >= timeCreation + minA && currentTime <= timeCreation + maxA;
        afterAWin = currentTime > timeCreation + maxA;

        if(refC == RefCs.Creation){
            beforeCWin = currentTime < timeCreation + minC;
            inCWin = currentTime >= timeCreation + minC && currentTime <= timeCreation + maxC;
            afterCWin = currentTime > timeCreation + maxC;
        }
        else {
            beforeCWin = currentTime < timeDetach + minC;
            inCWin = currentTime >= timeDetach + minC && currentTime <= timeDetach + maxC;
            afterCWin = currentTime > timeDetach + maxC;
        }

        if(maxA == 0){
            inAWin = currentTime >= timeCreation + minA;
            afterAWin = false;
        }
        if(maxC == 0){
            afterCWin = false;
            if(refC == RefCs.Detached){
                inCWin = currentTime >= timeDetach;
            }
            else if(refC == RefCs.Creation){
                inCWin = currentTime >= timeCreation;
            }
        }

    }

    function getState() public view returns(States){
        return state;
    }
    function getRefC() public view returns(RefCs) {
        return refC;
    }


    function condC() internal virtual returns(bool);
    function condA() internal virtual returns(bool);


    function onTargetStart() internal{
        if(state == States.Null){
            lastState = States.Null;
            timeCreation = now;
            toConditional();
        }
        
    }

    function onCancel() internal {
        if(state == States.Conditional){
            lastState = state;
            toTerminated();
        }
        else if(state == States.Detached){
            lastState = state;
            toViolated();
        }
    }

    function onSuspend() internal {
        if(state == States.Detached){
            lastState = state;
            toPending();
        }
    }
    function onReactivate() internal {
        if(state == States.Pending){
            state = lastState;
            lastState = States.Pending;
        }
    }
    function onRelease() internal {
        if(state == States.Conditional || state == States.Detached){
            lastState = state;
            toTerminated();
        }
    }

    function onTargetEnds() internal {
        updateTransitionVariables();

        // from conditional
        if(state == States.Conditional){
            lastState = States.Conditional;

            if((cType == Types.Goal && inCWin && condCHolds) || cType == Types.Persistent){
                toSatisfied();
            }
            else {
                toTerminated();
            }
            
        }
        // from detached
        else if(state == States.Detached){
            lastState = States.Detached;
            if(beforeCWin){
                toViolated();
            }
            else if((cType == Types.Goal && inCWin && condCHolds) || cType == Types.Persistent){
                toSatisfied();
            }
        }
    }


    function onTick() public {
        updateTransitionVariables();
        // from conditional state
        if(state == States.Conditional){
            lastState = States.Conditional;
            // stay in conditional
            if(beforeAWin || (inAWin && !condAHolds)){
                toConditional();
            }
            // to expired state
            if(afterAWin){
                toExpired();
            }
            // to detach state
            if(inAWin && condAHolds){
                timeDetach = now;
                toDetached();
            }
            // to violated state
            if((cType == Types.Persistent && inCWin && !condCHolds) || (cType == Types.Goal && afterCWin)){
                toViolated();
            }
            // to satisfied state
            else if(cType == Types.Persistent && afterCWin){
                toSatisfied();
            }

        }

        // from detached state
        else if(state == States.Detached){
            lastState == States.Detached;
            // Stay in detached
            if(beforeCWin || (inCWin && ((cType == Types.Goal && !condCHolds) || cType == Types.Persistent && condCHolds))){
               toDetached();
            }
            // to satisfied state
            else if(cType == Types.Persistent && afterCWin){
                toSatisfied();
            }
            // to violated state
            else if((cType == Types.Persistent && inCWin && !condCHolds) || (cType == Types.Goal && afterCWin)){
                toViolated();
            }
        }

    }

}
