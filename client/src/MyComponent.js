import React from "react";
import { newContextComponents } from "drizzle-react-components";
import { DrizzleContext } from "drizzle-react";

const { AccountData, ContractData, ContractForm } = newContextComponents;

const myRender = data => (
    <>
        Value=<b>{data}</b>
    </>
);

export default () => (
    <DrizzleContext.Consumer>
        {drizzleContext => {
            const { drizzle, drizzleState, initialized } = drizzleContext;
            if (!initialized) {
                return "Loading...";
            }

            const { accounts } = drizzleState;
            return (
                <div className="App">
                    <div>
                        <h1>Initialization</h1>
                        <h5>Set actors</h5>

                        <ContractForm
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="setActors"
                        />
                        <h5>Init documents</h5>
                        <ContractForm
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="initDocument"
                        />
                        <h5>Sign commitment</h5>
                        <ContractForm
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="signCommitment"
                        />
                        <hr/>
                        <h1>Execution</h1>
                        <h5>Post Document</h5>
                        <ContractForm
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="postDocument"
                        />
                        <hr/>
                        <h1>Smart contract info</h1>
                        <h5>Commitment state</h5>
                        <ContractData
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="getStateToString" />
                        <h5>Commitment warning</h5>
                            <ContractData
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="getWarning"/>
                            <h4>Debtor</h4>
                            <ContractData
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="debtor"
                            />
                            <h4>Creditor</h4>
                            <ContractData
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="creditor"
                            />
                    </div>
                </div>


            );
        }}
    </DrizzleContext.Consumer>
);