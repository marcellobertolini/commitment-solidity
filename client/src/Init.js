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

                <div>
                    <h1>Initialization</h1>
                    <h4>Set actors</h4>

                    <ContractForm
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="setActors"
                    />
                    <h4>Init documents</h4>
                    <ContractForm
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="initDocument"
                    />
                    <h4>Sign commitment</h4>
                    <ContractForm
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="signCommitment"
                    />

                </div>


            )
        }}
    </DrizzleContext.Consumer>

)

