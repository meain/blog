---
date: 2017-08-27
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
description: What actually is Webassembly?
keywords: webassembly, web, assembly, wasm
title: Ehh, Webassembly?
---

# Well, hey. So, what is Webassembly?

To be blunt and simple it is just `assembly` on the `web`. What you do is write in a low level language such as `C`, `C++` or `rust`(a new language by Mozilla) and convert them into assembly(sort of) language and ship that to browser.

# Why new stuff though?

Well, JS was a language which had performance as an afterthought. It was a language that concentrated on simplicity and speed of programming. We have come a long way and made JS much better with `JIT` and maintaining a high level of WTF's per minute. But even so, it is still cannot match the speeds of lower level languages. The two main reasons for this are the `event loop`(which is actually something I kinda love for the whole idea of it) and dynamic typing(Oh boy is it dynamic).

> Just to keep this clear, `Webassembly` is not a new language

# OK, so what is this, how do I get started?

Well, here is some good news and bad news depending on who you are. If you know `C`, `C++`, or `rust` you are good to go and if not that is what you will have to learn. I love `C`, it is a great language but learn [`rust`](https://www.rust-lang.org/) if you don't wanna accidentally blow up your system.

# Hmm, I will learn those later, what exactly is happening here?

Well, I am happy to break it down to you. Btw check out [Webassembly Playground](https://mbebenita.github.io/WasmExplorer/).

OK, let us see what happens here. Let us write a simple C function.
```c
int foo(int x){
  return x/2;
}
```
*I swear I know to write complex ones*

So, yeah, with that out of the way let us see how the compiled version of this code looks like. It will look something like this.

```nasm
wasm-function[0]:
  sub rsp, 8                            ; 0x000000 48 83 ec 08
  mov eax, edi                          ; 0x000004 8b c7
  shr eax, 0x1f                         ; 0x000006 c1 e8 1f
  add eax, edi                          ; 0x000009 03 c7
  sar eax, 1                            ; 0x00000b d1 f8
  nop                                   ; 0x00000d 66 90
  add rsp, 8                            ; 0x00000f 48 83 c4 08
  ret                                   ; 0x000013 c3
```
I kinda know assembly(had to learn it in college) and I can make kinda make sense of this but for a relief this is not the code that you will be debugging in the browser. What you will be debugging in the browser will be something known as `WAST`(Webassembly Syntax Tree) and that will look something like this.
```
(module
  (table 0 anyfunc)
  (memory $0 1)
  (export "memory" (memory $0))
  (export "_Z3fooi" (func $_Z3fooi))
  (func $_Z3fooi (param $0 i32) (result i32)
    (i32.div_s
      (get_local $0)
      (i32.const 2)
    )
  )
)
```
Well, this is what it look like but this won't be what it actually is. Actually it will be a bit more different as it is actually implemented as a stack machine(something that can work by pushing or popping from the stack or doing an operation). That will look more like this.
```
(module
  (type $type0 (func (param i32) (result i32)))
  (table 0 anyfunc)
  (memory 1)
  (export "memory" memory)
  (export "_Z3fooi" $func0)
  (func $func0 (param $var0 i32) (result i32)
    get_local $var0
    i32.const 2
    i32.div_s
  )
)
```

# Hmm cool, but I can't understand `WAST` either

Oh, wait. It is easy. Let me help you here(with my minimal knowledge).

The part we need to concentrate here is
```
(func $func0 (param $var0 i32) (result i32)
  get_local $var0
  i32.const 2
  i32.div_s
)
```
Most of the other lines are kinda like boilerplate code to initialize memory and stuff(yeah, stuff. I don't really know). Now if we see here, in the first line we can see that it is function called `$func0` which takes in an parameter `var0` of type int32 and outputs result of type int32. Makes sense?

OK, now with that out of the way, let us get to the other lines. As I mentioned earlier, `WAST` is implemented as a stack machine. So view the code with that in mind.
Initially we get the variable `var0` which was passed as argument to the function. Now we create an int32 constant of value 2. Now we divide the initial variable `var0` with the constant value 2. Well that is your **x/2**.

> You probably didn't need the explanation, but yeah just in case.

# Well, I guess I understand. But why though?

Good question. As you know languages such as `C`, `C++` and `rust` are statically typed languages. This means you can leverage the static type information that is available int the code to optimize it. Fox example if we where to set the variable `x` in our initial program we could do a binary right shift instead of a div to divide by 2 and that is a much more efficient way to do it.

Let us see some code:

`new C++ code:`
```c
unsigned int foo(unsigned int x){
  return x/2;
}
```

`WAST output:`
```
(module
  (type $type0 (func (param i32) (result i32)))
  (table 0 anyfunc)
  (memory 1)
  (export "memory" memory)
  (export "_Z3fooj" $func0)
  (func $func0 (param $var0 i32) (result i32)
    get_local $var0
    i32.const 1
    i32.shr_u
  )
)
```
If you look closely in the last line in `WAST` output `i32.div_s` was changed to `i32.shr_u` which is a faster instruction. Well, in here this might not matter so much but when you are creating something bigger(game engines maybe?) it does matter.

# Oh snap, so is JS gonna die?

Nah, not really. The fact is you still need JS to handle the DOM. All you can do from `Webassembly` is to do what you could have done natively by uinsg JS api's for webassembly to call into `WASM` modules and get some result back.

#### Wait, ain't that what flash did?

Well, it is but not really. In the case of flash it was run as a completely seperate module independent from the browser. But in the case of `WASM` you run that in a browser in a sandboxed environment. The issue with flash was that if you wanted to do something crazy on the system that the browser did not let you do, you could just call into flash and do it. But in the case of `WASM` you do not have the issue as it also runs inside the browser sndbox.

# Woosh. Btw is there a better guide avaiable other than this piece of crap?

Oh, definitely. Check out the blog [A cartoon intro to WebAssembly](https://hacks.mozilla.org/2017/02/a-cartoon-intro-to-webassembly/) or the [official page](http://webassembly.org/). For more info on working with `WASM` and benchmarks check out the blog [Screamin’ Speed with WebAssembly](https://hackernoon.com/screamin-speed-with-webassembly-b30fac90cd92)
