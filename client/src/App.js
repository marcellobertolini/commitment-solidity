import React, { Component } from "react";
import { Drizzle } from 'drizzle';
import { DrizzleContext } from "drizzle-react";

import "./App.css";
import Init from './Init';
import Info from './Info';

import drizzleOptions from "./drizzleOptions";
import MyComponent from "./MyComponent";

const drizzle = new Drizzle(drizzleOptions);

class App extends Component {
  render() {
    return (
      <DrizzleContext.Provider drizzle={drizzle}>
        <div className="App" >
          <Init />
          <hr />
          <MyComponent />
          <hr />
          <Info />
        </div>
      </DrizzleContext.Provider>
    );
  }
}

export default App;