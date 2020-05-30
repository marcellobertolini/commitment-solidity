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
                        <h1>Execution</h1>
                        <h4>Post Document</h4>
                        <ContractForm
                            drizzle={drizzle}
                            drizzleState={drizzleState}
                            contract="TemperatureCommitment"
                            method="postDocument"
                        />
                    </div>


            );
        }}
    </DrizzleContext.Consumer>
);