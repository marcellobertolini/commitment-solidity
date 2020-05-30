import React from "react";
import { newContextComponents } from "drizzle-react-components";
import { DrizzleContext } from "drizzle-react";


const { AccountData, ContractData, ContractForm } = newContextComponents;

const myRender = data => (
    <>
        Value=<b>{data}</b>
    </>
);
var creditor = false;
var debtor = false;
var show = creditor && debtor;

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
                    <h1>Smart contract info</h1>
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="debtor"
                        render={value => (
                            <h4>Debtor : {value}</h4>
                        )}
                    />
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="creditor"
                        render={value => (
                            <h4>Creditor : {value}</h4>
                        )}
                    />
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="debtorApproved"
                        render={value => (
                            <h4>Debtor approved : {value.toString()}</h4>
                        )} />
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="creditorApproved"
                        render={value => (
                            <h4>Creditor approved: {value.toString()}</h4>

                        )} />
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="getStateToString"
                        render={value => (
                            <h4>Commitment state : {value}</h4>
                        )}
                    />
                    <ContractData
                        drizzle={drizzle}
                        drizzleState={drizzleState}
                        contract="TemperatureCommitment"
                        method="getWarning"
                        render={value => (
                            <h4>Commitment warning : {value.toString()}</h4>
                        )} />
                    

                </div>


            )
        }}
    </DrizzleContext.Consumer>

)

