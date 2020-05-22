---
date: 2019-02-17
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
description: A simple intro to Rust's macros
keywords: Rust, macro, proc-macro, rustlang
title: Understanding Rust macros
---

Yo, I have been working on Rust for some time now. It is a great language and a refreshment coming from a primarily
Python and Javascript background. I feel like the compiler has got my back even though it yells at me a lot. I feel
like I could refactor something and if the compiler does not complain, nothing will break.

But that said, coming from a background of mostly just dynamic languages I had to learn a lot of new stuff. One of those
is macros. They are a really powerful tool once  you get a hang of it even though it might look a bit intimidating at
first.

# What are `macros`?

Well, in short they are "things" that take code at compile time and generate code.
You might get a better understanding of what they are when you actually see something if you have not grasped the idea
already.

# Why use them?

Macros are a great way to provide simple enough abstractions without much of a performance hit as the transformation to
the necessary code is done during the compilation time.


# Rust macro system

Rust has two types of macros.

- Macros
- Procedural Macros

I will give a rough idea on what each of them is in the following sections,
but here is the [Rust docs](https://doc.rust-lang.org/book/ch19-06-macros.html?highlight=rust,macros#how-to-write-a-custom--derive--macro)
on macros in Rust. They actually do a pretty good job of explaining stuff, I am just putting it out there as a different
way of putting stuff.

## Macros

Well, these are the simpler macro system, as in `proc-macros` are the more complex ones.

In this, the idea is you get a set of tokens. You can match on these tokens that you receive like doing a regex match
and then perform operations based on the result that you receive. You can think of it kinda like taking the output of a
lexer and doing something on it.


### Maybe a simple example?

Here is a simple example. A macro to square a value.

```
macro_rules! square {
    ($val:expr) => { $val*2 }
}
```

If  you see, it is like a Rust match statement.

You are essentially mapping from `$val` to `$val*2`.

Actually a macro definition is like a match statement. You can have multiple paths for it to pick based on what the
input is.

Let us see something which has two paths as an example.

```rust
#[macro_export]
macro_rules! pow {
    ($val:expr) => { $val*2 };
    ($val1:expr, $val2:expr) => { $val1.pow($val2) };
}
```

Here, with the macro `pow` if we only pass in one value, it will give the square. But if we pass two arguments, it will
give you the value which is equal to the first value raised to the power of the second value.

Hmm, what happens if I pass in 3 values...? Well, the code won't compile and you get a friendly error warning.

```
error: no rules expected the token `,`
  --> src/main.rs:18:35
   |
7  | macro_rules! pow {
   | ---------------- when calling this macro
...
18 |     println!("{:#?}", pow!{4,4,5});
   |                               ^ no rules expected this token in macro call

error: aborting due to previous error
```

What if I need to use an dynamic number of args? Well, checkout the next example.

### A bit more involved example

So, if you have used `vec!` before this is how it looks:

```rust
let v: Vec<u32> = vec![1, 2, 3];
```

This creates the variable ( or constant ) `v` as a vec of three elements.
**Btw, a macro can be differentiated from a function with the `!` at the end**.

What you are doing here is passing `1, 2, 3` as an argument to the macro `vec`. Btw, you could have just as easily used

```rust
let v: Vec<u32> = vec!(1, 2, 3);
let v: Vec<u32> = vec!{1, 2, 3};
```

Either of these bracket options work too, it does not matter. It is just that `[]` feels a bit more appropriate when
creating a `vec`.

The actual implementation of `vec!` is [here](https://github.com/rust-lang/rust/blob/8af675a07576940ba24e3d91abd10b029b937946/src/liballoc/macros.rs#L39).
But, for the purpose of explaining stuff let us look a simpler example.

```rust
#[macro_export]
macro_rules! vec {
    ( $( $x:expr ),* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}
```

Hmm, that code is something. OK. Let us break down what exactly is happening in there.

So, what happens is that a _regexish_ match on the argument that gets passed into the `vec` macro is done. This happens
in line 3.

The line essentially checks for expressions that is separated by a comma and assign each of them to a variable `x`.
Now in lines 6-8 we loop of the values that come into `x`.

[Here](https://doc.rust-lang.org/1.7.0/reference.html#macro-by-example) is a list of things that you can use instead of
`expr`. Or just check here.

- `ident`: an identifier. Examples: x; foo.
- `path`: a qualified name. Example: T::SpecialA.
- `expr`: an expression. Examples: 2 + 2; if true { 1 } else { 2 }; f(42).
- `ty`: a type. Examples: i32; Vec<(char, String)>; &T.
- `pat`: a pattern. Examples: Some(t); (17, 'a'); _.
- `stmt`: a single statement. Example: let x = 3.
- `block`: a brace-delimited sequence of statements. Example: { log(error, "hi"); return 12; }.
- `item`: an item. Examples: fn foo() { }; struct Bar;.
- `meta`: a "meta item", as found in attributes. Example: cfg(target_os = "windows").
- `tt`: a single token tree.

So, essentially what this macro does is that it takes all the expressions that are there and loop over them and does

```rust
temp_vec.push($x);
```

You can view it as a mapping between `$( $x:expr ),*` to  `$(temp_vec.push($x);)*` with extra steps before and a return
of the final result with line 9.

Simple enough, right?

The `vec!` macro used here will yield something like this:

```rust
let mut temp_vec = Vec::new();
temp_vec.push(1);
temp_vec.push(2);
temp_vec.push(3);
temp_vec
```

This code is generated during the compile time and will be replaced in the place of `vec!`. Pretty sweet, right?

> Btw, you can actually recursively call macros, as in the expansion of one macro, you could use another macro and it
> will recursively expand them.

# Procedural Macros

I initially thought of not writing about procedural macros but then I thought I would give a rough intro here. I might
end up writing another blog just about procedural macros later.

Well, this is like a big brother to simple macros. You know, the big guns. The big daddy. The big boss. OK, I am gonna
stop there.
Let us look into what it is.

> **The code for the example here is available at [meain/rust-macros-example](https://github.com/meain/rust-macros-example)**

Procedural macros take some Rust code as input and changes it to some other Rust code. You can more or less think of it
as receiving the AST and modifying it to a different one, kinda like what `babel` does in the Javascript world but this
is not to make it compatible with an older version or something.

> One small but important thing about proc macros is that they have to reside in their own crate with a specific crate type

So, a simple macro would have a folder structure something like

```
.
├── hello_macro
│   ├── Cargo.lock
│   ├── Cargo.toml
│   ├── hello_macro_derive
│   │   ├── Cargo.lock
│   │   ├── Cargo.toml
│   │   └── src
│   ├── src
│   │   └── lib.rs
└── mycode
    ├── Cargo.lock
    ├── Cargo.toml
    └── src
        └── main.rs
```

Your code will reside in `mycode` and the macro in `hello_macro` folder.

OK, now lets see what is in each  of the files.

The `Cargo.toml` file under `hello_macro` has nothing fancy. In fact here is what is there in mine

```toml
[package]
name = "hello_macro"
version = "0.1.0"
authors = ["Abin Simon <abinsimon10@gmail.com>"]
edition = "2018"

[dependencies]
```

But inside the `Cargo.toml` file inside `hello_macro_derive` we have some stuff. Let me show you what is in there and I
will go over what they are

```toml
[package]
name = "hello_macro_derive"
version = "0.1.0"
authors = ["Abin Simon <abinsimon10@gmail.com>"]
edition = "2018"

[lib]
proc-macro = true

[dependencies]
syn = { version="0.15", features=["extra-traits"] }
quote = "0.6"
```

One thing you have to do here is under the lib section you have to specify that this is a `proc-macro`.

Now, the deps. There are two basic deps that you will end up needing.

If you see, rust will give you all the stuff that is passed into the macro as a stream of tokens.
The [syn](https://github.com/dtolnay/syn) crate will help you parse that and change it into something which we can
easily work with. Oh btw, I have enable a specific feature of the `syn` crate. This one is for some debugging purposes.
You can check out other optional features [here](https://github.com/dtolnay/syn#optional-features).

The other dependency that you see is [quote](https://github.com/dtolnay/quote). Now this is kinda does the reverse of
what syn does(not exactly). It helps you write actual Rust code and convert that into a `TokenStream` which is something
that rust expects out of a macro. If you see quote in itself is a macro. ¯\\_(ツ)_/¯.

Let me get over the basic files first and I will go into how to actually write one.

The file `hello__macro/src/lib.rs` will look something like this

```rust
pub trait HelloMacro {
    fn helpify();
}
```

and the file `mycode/src/main.rs` ( the one that consumes the macro ) will look something like this.

```rust
use hello_macro::HelloMacro;
use hello_macro_derive::HelloMacro;

#[allow(dead_code)]
#[derive(HelloMacro)]
struct Pancakes {
    doable: bool,
    name: String,
    age: u32
}

fn main() {
    Pancakes::helpify();
}
```

OK, with that out of the way, let us look into how the actual macro is written
The file with the macro definition looks something like this

```rust
extern crate proc_macro;

use crate::proc_macro::TokenStream;
use quote::quote;
use syn::Data::Struct;
use syn::Fields;
use syn::Type::Path;

fn impl_hello_macro(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let data = &ast.data;
    // println!("{:#?}", data);
    let mut defenition = format!("Struct {}", name);

    if let Struct(def) = data {
        if let Fields::Named(fields) = &def.fields {
            for named in &fields.named {
                let ident = &named.ident;
                let ty = &named.ty;
                if let Some(id) = ident {
                    // println!("{}", id);
                    defenition = format!("{}\n  {}:", defenition, id)
                };
                if let Path(path) = ty {
                    // println!("{}", path.path.segments[0].ident);
                    defenition = format!("{} {}", defenition, path.path.segments[0].ident)
                }
            }
        }
    };

    let gen = quote! {
        impl HelloMacro for #name {
            fn helpify() {
                println!(#defenition);
            }
        }
    };
    gen.into()
}

#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
    let ast = syn::parse(input).unwrap();
    impl_hello_macro(&ast)
}
```

Here if you check the arguments, `ast` is the thing that you get after your code goes through the syn package.

The code about comprises of two sections. The parsing of the `ast` and generating a simple string and a part which adds
a func that will display the result onto the `impl` of the struct.

Let us look into the `ast` parsing part. If you check the data variable, for this current one it looks something like
this
```
Struct(
    DataStruct {
        struct_token: Struct,
        fields: Named(
            FieldsNamed {
                brace_token: Brace,
                named: [
                    Field {
                        attrs: [],
                        vis: Inherited,
                        ident: Some(
                            Ident {
                                ident: "doable",
                                span: #0 bytes(130..136)
                            }
                        ),
                        colon_token: Some(
                            Colon
                        ),
                        ty: Path(
                            TypePath {
                                qself: None,
                                path: Path {
                                    leading_colon: None,
                                    segments: [
                                        PathSegment {
                                            ident: Ident {
                                                ident: "bool",
                                                span: #0 bytes(138..142)
                                            },
                                            arguments: None
                                        }
                                    ]
                                }
                            }
                        )
                    },
                    Comma,
                    Field {
                        attrs: [],
                        vis: Inherited,
                        ident: Some(
                            Ident {
                                ident: "name",
                                span: #0 bytes(148..152)
                            }
                        ),
                        colon_token: Some(
                            Colon
                        ),
                        ty: Path(
                            TypePath {
                                qself: None,
                                path: Path {
                                    leading_colon: None,
                                    segments: [
                                        PathSegment {
                                            ident: Ident {
                                                ident: "String",
                                                span: #0 bytes(154..160)
                                            },
                                            arguments: None
                                        }
                                    ]
                                }
                            }
                        )
                    },
                    Comma,
                    Field {
                        attrs: [],
                        vis: Inherited,
                        ident: Some(
                            Ident {
                                ident: "age",
                                span: #0 bytes(166..169)
                            }
                        ),
                        colon_token: Some(
                            Colon
                        ),
                        ty: Path(
                            TypePath {
                                qself: None,
                                path: Path {
                                    leading_colon: None,
                                    segments: [
                                        PathSegment {
                                            ident: Ident {
                                                ident: "u32",
                                                span: #0 bytes(171..174)
                                            },
                                            arguments: None
                                        }
                                    ]
                                }
                            }
                        )
                    }
                ]
            }
        ),
        semi_token: None
    }
)
```

Well, now in the following block, ie

```rust
let mut defenition = format!("Struct {}", name);

if let Struct(def) = data {
    if let Fields::Named(fields) = &def.fields {
        for named in &fields.named {
            let ident = &named.ident;
            let ty = &named.ty;
            if let Some(id) = ident {
                // println!("{}", id);
                defenition = format!("{}\n  {}:", defenition, id)
            };
            if let Path(path) = ty {
                // println!("{}", path.path.segments[0].ident);
                defenition = format!("{} {}", defenition, path.path.segments[0].ident)
            }
        }
    }
};
```

we just create a string in `defenition` variable. Well, it is just some patchy code to go through the data structure and
I don't think I should go through this. Also you can probably make something better.

Now to the second part, we add the func to the struct. We use the `quote` package to do this.

```rust
let gen = quote! {
    impl HelloMacro for #name {
        fn helpify() {
            println!(#defenition);
        }
    }
};
gen.into()
```

> To use any variable we have defined we have to use a `#` in front. That is why `#defenition` is defined like that.

Now this generated code gets returned with `gen.into()`. And viola, you have a `helpify()` in anything `HelloMacro`.

Well, if we run our code now, you get a response which will look something like this:

```
$ cargo run                                                                                                                                                                    rust-macros-example/mycode 137d
    Finished dev [unoptimized + debuginfo] target(s) in 0.04s
     Running `target/debug/mycode`
Struct Pancakes
  doable: bool
  name: String
  age: u32
```

Well, this is more or less what I got, I believe this gave you some kind of a intro to rust macros.
