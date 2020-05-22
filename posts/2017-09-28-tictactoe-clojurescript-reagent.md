---
date: 2017-09-28
layout: layouts/post.njk
description: Creating a simple tic-tac-toe game in Clojurescript from scratch using
  Reagent. Beginner tutorial to Clojurescript.
keywords: functional programming, clojure, clojurescript, reagent, tic-tac-toe
title: Creating a tic-tac-toe game in Clojurescript using Reagent
---

Whoosh, I am tired of JS all day long, let me try out something else. And yeah, I ended up here.
Actually I was kinda playing around with `Haskell` before I reached here. It feels pretty good to have a change from the usual stuff.
To be frank I think everyone should try out functional programming at some point of time.
Well, enough bullshit let us get to building it.

![screenshot](/images/tictactoe.png)

> Fully working code: [tictactoe-clojurescript-reagent](https://github.com/meain/tictactoe-clojurescript-reagent)

To start with `Clojrescript` is a [functional programming language](https://wiki.haskell.org/Functional_programming).
It derives from [`Clojure`](https://clojure.org/).

> Random fact: `Clojure` runs on top of Java.

# Installation and setup

I want to add the setup instructions, but it is different for different systems and I am really lazy right now so go check out the webpage.

Just some pointers, you will need `Java` first. Then install `Clojurescript` and then `leiningen`.

[`Leiningen`](https://leiningen.org/) is kinda like gulp.

Btw in mac it is:
```shell
brew install clojurescript
brew install leiningen
```

# Getting started

## Setting up template

First you blah blah....

Run this command:
```shell
lein new figwheel ttt -- --reagent
```

It is kinda like `npm init` command but with `livereload` and `react` installed.

OK, what that does is create a new project with [`figwheel`](https://github.com/bhauman/lein-figwheel) and using [`reagent`](https://github.com/reagent-project/reagent)

`Figwheel` is like `gulp-livereload` plugin. `Reagent` is the `Clojurescript` wrapper arround Facebook's `React` JS framework.

Now you start the `lien` server ( which has hot reload ) by using the command:
```shell
lein figwheel
```

You will get a file structure like this
```
ttt
├── README.md
├── dev
│   └── user.clj
├── project.clj
├── resources
│   └── public
│       ├── css
│       │   └── style.css
│       └── index.html
└── src
    └── ttt
        └── core.cljs

6 directories, 6 files
```

The main file you will have to work on here is `src/ttt/core.cljs`. It is the file that we will add all the core logic into.

`project.clj` is a configuration file, kinda like `package.json`.

## Well, let us see some basics of `Clojrescript`

In the `core.cljs` file you will have:

```clojure
(ns ttt.core
    (:require [reagent.core :as reagent :refer [atom]]))

(enable-console-print!)

(println "This text is printed from src/ttt/core.cljs. Go ahead and edit it and see reloading in action.")

;; define your app data so that it doesn't get over-written on reload

(defonce app-state (atom {:text "Hello world!"}))


(defn hello-world []
  [:div
   [:h1 (:text @app-state)]
   [:h3 "Edit this and watch it change!"]])

(reagent/render-component [hello-world]
                          (. js/document (getElementById "app")))

(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)
```

Let us see what all of these lines do.

### (ns ....)

The top two lines is kinda your import statements. Mostly importing `Reagent` here.

### console.log()

Well we have `println` instead of `console.log`. But since this is a functional language we use it like:

```clojure
(println "Stuff you wanna print")
```

This will get printed in the JS console in your browser.

### Commenting

You can use `;` to start a comment.
Anything after this, used on start of a line or anywhere in the line is considered as a comment.

Example:
```clojure
; I heard you like comments
```

### `app-state`

In line 10, what you see is a variable ( [`atom`](http://clojuredocs.org/clojure.core/atom) ) declaration. The difference between this variable and others is that it is an immutable variable which means you cannot modify it in place.

### (reagent/render-component)

*Renders component, duh.*
It renders the `hello-world` component on to the div with id `app`.

### (defn hello-world [] )

Well `hello-world` is a function that is return a html string kinda thing or more like return a JSX object ( if that is a thing ).
In `Clojurescript` world it is called [`hiccup`](https://github.com/weavejester/hiccup) like syntax. It has pretty much redid the html in a `Clojure` ish syntax.

Actually from [`Reagent`](http://reagent-project.github.io/).

The defenition here:

```clojure
[:div
   [:h1 (:text @app-state)]
   [:h3 "Edit this and watch it change!"]]
```
gives you something like:

```html
<div>
    <h1>${app-state.text}</h1>
    <h3>Edit this and watch it change!</h3>
</div>
```

#### (:text @app-state)

This is how you get a value from the immutable variable.

> You use `@` when using an atom

Now if you have some value multiple levels deep you can use [`get-in`](http://clojuredocs.org/clojure.core/get-in)

For example:

```clojure
user=> (def m {:username "sally"
               :profile {:name "Sally Clojurian"
                         :address {:city "Austin" :state "TX"}}})
#'user/m

user=> (get-in m [:profile :name])
"Sally Clojurian"
user=> (get-in m [:profile :address :city])
"Austin"
user=> (get-in m [:profile :address :zip-code])
nil
user=> (get-in m [:profile :address :zip-code] "no zip code!")
"no zip code!"
```

> Check out [ClojureScript Cheatsheet](http://cljs.info/cheatsheet/) in case you get stuck.


# Building the game

Cool, now with all that basics out of the way let us get to building the actual game.

> I will be using the code from here ([tictactoe-clojurescript-reagent](https://github.com/meain/tictactoe-clojurescript-reagent))

So as I said the main file you will be checking out will be `src/ttt/core.cljs`.
We will go line by line ( mostly ) from the above cited project's `core.cljs` file.

## Lines 9 - 10

```clojure
(defn make-board "Creates a new board. n denotes the size." [n]
  (vec (repeat n (vec (repeat n 0)))))
```

In here we define a function which will, on call return a [n x n] matrix.
`(repeat n 0)` creates a list of n 0's. We turn that into a vector. Now we get one n dimensional array.
We create multiple copies of this to create an [n x n] matrix.

## Lines 12 - 17

```clojure
(def board-size 3)
(defonce app-state
  (atom {:text ":game"
         :board (make-board board-size)
         ;; none win lose draw
         :win "none"}))
```

In here we are mainly defining variables. In line 12 we define the variable `board-size`.
In lines 13 to 17 we are creating an atom ( an immutable variable ) which contains a text, the current board and win state.

## Lines 19 - 30

```clojure
(defn check-win "Check for win and lose conditions" [user computer]
  (if (or (some #(= board-size %) (for [freq (frequencies (for [el user] (first el)))] (second freq)))
          (some #(= board-size %) (for [freq (frequencies (for [el user] (second el)))] (second freq)))
          (= board-size (get-in (frequencies (for [el user] (= (first el) (second el)))) [true]))
          (= board-size (get-in (frequencies (for [el user] (= (first el) (- (- board-size (second el)) 1)))) [true])))
    (swap! app-state assoc :win "win"))
  (if (or (some #(= board-size %) (for [freq (frequencies (for [el computer] (first el)))] (second freq)))
          (some #(= board-size %) (for [freq (frequencies (for [el computer] (second el)))] (second freq)))
          (= board-size (get-in (frequencies (for [el computer] (= (first el) (second el)))) [true]))
          (= board-size (get-in (frequencies (for [el computer] (= (first el) (- (- board-size (second el)) 1)))) [true])))
    (swap! app-state assoc :win "lose"))
  )
```

Here we define the checks to see if the player or bot has won. Draw conditions are checked in another function.
The variables `user` and `computer` are values that are passed from the function `check-state` defined at line 32.
The contents of these variables are list of [i j] values for which the respective players have marked.

Once we have found out if there is a win or lose condition we use `swap!` and `assoc` to change the value of win inside of `app-state`.

## Lines 32 - 49

```clojure
(defn check-state []
  (let [board (:board @app-state)
        remaining (for [i (range board-size)
                        j (range board-size)
                        :when (= (get-in board [i j]) 0)]
                    [i j])
        user (for [i (range board-size)
                   j (range board-size)
                   :when (= (get-in board [i j]) 1)]
               [i j])
        computer (for [i (range board-size)
                       j (range board-size)
                       :when (= (get-in board [i j]) 2)]
                   [i j])]
    (if (= (count remaining) 0)
      (swap! app-state assoc :win "draw"))
    (check-win user computer)
    ))
```

This function `check-state` along with the above one is used to determine the win, lose, draw or none setting of the `:win` setting.
This variable `:win` is what is then used in order to set the message on the screen.

What we use in our matrix to denote played position is 1 and 2 for user and computer respectively.
In this function we get the positions which are remaining ie not marked, positions played by the user and positions played by the computer into the variables `remaining`, `user` and `computer`.

If no elements are present in the `remaining` variable we set the condition as draw. Win lose conditions are checked in the `check-win` function which is called later on.

## Lines 51 - 63

```clojure
(defn computer-move []
  ;; choose a random unplayed block
  (let [board (:board @app-state)
        remaining (for [i (range board-size)
                        j (range board-size)
                        :when (= (get-in board [i j]) 0)]
                    [i j])
        move (rand-nth remaining)
        path (into [:board] move)]
    (swap! app-state assoc-in path 2)
    )
  (check-state)
  )
```

This function is used to compute a move for the computer to play.
What it does it it picks out the remaining positions in the game-matrix and store it to `remaining` variable.
Then we chose a random value from the `remaining` variable and make the change to the board.

## Lines 65 - 121

```clojure
(defn block [color i j]
  [:div {:style {:background-color color
                 :width "100px"
                 :height "100px"
                 :border "5px solid #fff"}
         :on-click (fn [e]
                     (if (and (= 0 (get-in @app-state [:board i j])) (= (:win @app-state) "none"))
                       ((swap! app-state assoc-in [:board i j] 1)
                        (check-state)
                        (if (= (:win @app-state) "none")
                          (computer-move)
                          ))))}])

(defn blank [i j]
  (block "#f5f5f5" i j))
(defn cross [i j]
  (block "#FF7043" i j))
(defn circle [i j]
  (block "#FFEE58" i j))

(defn render-board []
  [:div {:style {:display "flex" :flex-wrap "wrap"}}
   (doall(for [i (range board-size)
               j (range board-size)]
           (case (get-in @app-state [:board i j])
             0 ^{:key (str i "-" j)} [blank i j]
             1 ^{:key (str i "-" j)} [cross i j]
             2 ^{:key (str i "-" j)} [circle i j]
             )))
   ])

(defn app []
  [:div {:style {:text-align "center"}}
   [:div
    [:h1 {:style {:display "block" :float "left"}} (:text @app-state)]
    [:h1 {:style{:background-color "#f5f5f5"
                 :display "block"
                 :float "right"}} "tic-tac-toe"]]
   [:div.clearfix {:style {:clear "both"}}]
   [:h3 {:style {:width "100%" :text-align "center"}} "Let us play some "
    [:code {:style {:font-family "cursive"}} "tic-tac-toe"] " now"]
   [:center [:div {:style {:font-size "20px"}} (:win @app-state)]]
   [:div.play-area {:style {:width (str (* 110 board-size) "px")
                            :height (str (* 110 board-size) "px")
                            :background-color "#ded"
                            :cursor "pointer"
                            :display "inline-block"}}
    [render-board]
    ]
   [:center
    [:button {:on-click (fn [e]
                          (swap! app-state assoc :board (make-board board-size))
                          (swap! app-state assoc :win "none")
                          )
              :style {:font-size "30px"
                      :font-family "monaco, monospace"
                      :margin-top "20px"}} "New Game"]]])
```

This is the UI definition of the game.
The function `block` gives a hiccup like object of a single block.
The function `blank` `cross` and `circle` are just simple wrappers around `block` to give different color blocks.

> We use colors instead of symbols just because they are easy.

The `render-board` function is used to render the whole board using the `board` value in `app-state` atom.
The definition is mostly the `hiccup` like syntax and I hope that makes sense to you.
Towards the end we also add a button to reset the game which has an `on-click` lister added to it which changes the value of board into a new one and reset the `win` value to none.

And that basically wraps up the whole code. :)
