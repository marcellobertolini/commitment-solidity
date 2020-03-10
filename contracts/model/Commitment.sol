pragma solidity ^0.6.0;

abstract contract Commitment {

    enum Strenghts {Hard, Soft}
    Strenghts strenght;

    // Commitment state machine
    enum States { Null, Expired, Terminated, Pending, Conditional, Detached, Satisfied, Violated}
    States public state;
    States private lastState;

    enum Types {Goal, Persistent}
    Types cType;

    // Commitment template
    uint public minA;
    uint public maxA;
    uint public minC;
    uint public maxC;
    bool public condA;
    bool public condC;
    enum RefCs { Creation, Detached}
    RefCs public refC;


    // transition variables
    bool public beforeAWin;
    bool public inAWin;
    bool public afterAWin;
    bool public beforeCWin;
    bool public inCWin;
    bool public afterCWin;

    // time variables
    uint public timeCreation;
    uint public timeDetach;




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


    function updateTransitionVariables() internal virtual{
        uint currentTime = now;
        if(state == States.Conditional){
            condA = evaluateAntecedent();
        }
        else if(state == States.Detached){
            condC = evaluateConseguent();
        }

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

    }

    function getState() public view returns(States){
        return state;
    }
    function getRefC() public view returns(RefCs) {
        return refC;
    }


    function evaluateConseguent() internal virtual returns(bool);
    function evaluateAntecedent() internal virtual returns(bool);


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
            toTerminated();
        }
        if(state == States.Detached){
            lastState = States.Detached;
            if(beforeCWin){
                toViolated();
            }
            else if((cType == Types.Goal && inCWin && condC) || cType == Types.Persistent){
                toSatisfied();
            }
        }
    }


    function onTick() internal {
        updateTransitionVariables();
        // from conditional state
        if(state == States.Conditional){
            lastState = States.Conditional;
            // stay in conditional
            if(beforeAWin || (inAWin && !condA)){
                toConditional();
            }
            // to expired state
            else if(afterAWin){
                toExpired();
            }
            // to detach state
            else if(inAWin && condA){
                timeDetach = now;
                toDetached();
            }

        }

        // from detached state
        else if(state == States.Detached){
            lastState == States.Detached;
            // Stay in detached
            if(beforeCWin || (inCWin && ((cType == Types.Goal && !condC) || cType == Types.Persistent && condC))){
               toDetached();
            }
            // to satisfied state
            else if(cType == Types.Persistent && afterCWin){
                toSatisfied();
            }
            // to violated state
            else if((cType == Types.Persistent && inCWin && !condC) || (cType == Types.Goal && afterCWin)){
                toViolated();
            }
        }

    }

}
