History
=======

This project arose from my attempt to solve some of the Project Euler
problems using Mathematica. I found it frustrating that I had to guess
how many prime numbers or how many Fibonacci numbers I'd have to scan
in order to satisfy the "primes under 2 million" or "Fibonacci numbers
under 4 million".

I knew how I'd solve the problem in C# or Python (chaining a bunch of
IEnumerables or generators, respectively), and wanted to see how close
I could get to that style in Mathematica, so I posed the question on
the fledgling Mathematica Stack Exchange site.

A [helpful user named WReach wrote up a great rough implementation][1],
citing his experience with the Haskell programming language as his
major source of inspiration.

I cleaned up his implementation, put it in a package, and made it look
a little more native (First, Rest instead of Head, Tail). I've added a
few more functions (TakeWhile, FoldList, Most, Last).

Finally, I added a helper called Lazy that lets you trivially
turn many built-ins (Fibonacci[] and Prime[], in fact) into lazy
sources that you can pump for as many items as you need without going
to too much effort.

I'm providing this code under an MIT-style license in the hopes that
others find it useful. If anyone ends up adding any new features,
especially by providing Stream upvalues for more built-ins, please
send me a pull request.

Happy hacking!

Examples
========
Project Euler #1: Find the sum of all the multiples of 3 or 5 below 1000.

>Total[Lazy[Integers]~TakeWhile~((# < 1000) &)
>  ~Select~((Mod[#, 3] == 0 || Mod[#, 5] == 0) &)]



  [1]: http://mathematica.stackexchange.com/a/885/178
