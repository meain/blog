---
layout: post
title: "Connecting `Redux` to `React`, simplified"
description: "Simplest guide to show how to connect redux and react and get started"
comments: true
keywords: "react, redux, frontend, javascript, code"
---

So, you have been working on your `React` project.
Maybe you have heard about `Redux` and how it can make it all better and need some help getting started.

# What is `Redux`?

Hmm, good question. It is like this master thingy which handles the state of all your components rather than handling the state in the components. So what you do is when you need to make a change that affects something else ( ie something you would store in the state or pass up to the parent component ) you pass it over to `Redux` ( loosely speaking ). From there you can user `Redux` to send the data to where it is needed.

<!-- ![redux flow]({{site.url}}{{site.baseurl}}/assets/images/redux.png) -->
<div style="text-align:center"><img src ="{{site.url}}{{site.baseurl}}/assets/images/redux.png" /></div>

# So, how do you connect?

## Create `React` project

Let us get stated by creating a `React` project. I am using [create-react-app](https://github.com/facebookincubator/create-react-app).

```bash
create-react-app redux-example
```

This will bootstrap your react project, but without `Redux`. Your file structure will look something like:

```
.
├── README.md
├── node_modules
├── package.json
├── public
├── src
└── yarn.lock
```

## Install `redux` and `react-redux`

Now we install the `redux` library as well as `react-redux` library to connect react and redux together.

#### `redux`
```bash
# npm
npm install redux

# yarn
yarn add redux
```

#### `react-redux`
```bash
# npm
npm install react-redux

# yarn
yarn add react-redux
```

## Creating necessary files

Create `redux.js` file in `/src` directory.

```js
import { createStore } from 'redux';

// create initial state
const initialState = {}

// create reducer
const reducer = ( state = initialState, action ) => {
    // branch using switch
    switch(action.type){
        case 'FIRST-ACTION':
            state = {
                ...state,
                ...action.payload
            }
            break
    }
    return state
}

// create store
const store = createStore(reducer)
// export
export default store
```

> You can use [combine-reducers](https://redux.js.org/docs/api/combineReducers.html) combine multiple reducers

## Add redux into the react mix

In `/src/index.js`

#### Add import for `react-redux` and `store`
```js
import { Provider } from 'react-redux'

import store from './redux.js'
```

#### Change the render function to 

```jsx
ReactDOM.render(
  <Provider store={store}>
	    <App />
  </Provider>,
  document.getElementById('root'))
```

## Use 'em in the code

In your component file

Import `connect` from `react-redux`

```jsx
import { connect } from 'react-redux'
```

Now at the bottom, do some *magic* to add stuff from redux as props.

```js
const mapStateToProps = state => {
  return {
    user: state.user,
    threads: state.threads
  }
}

const mapDispatchToProps = dispatch => {
  return {
    userChanged: threads => {
      dispatch({
        type: 'USER_UPDATED',
        payload: user 
        })
    },
}

export default connect(mapStateToProps, mapDispatchToProps)(App)
```

# And there you go ;)

I have tried to keep it really simple, more like a cheat sheet rather than an explanation because I think that is more important for most people.
Feel free to ping me if you need any help.
