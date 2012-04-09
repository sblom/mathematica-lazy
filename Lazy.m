(*
   Copyright (c) 2012 Scott Blomquist.

   Permission is hereby granted, free of charge, to any person
   obtaining a copy of this software and associated documentation
   files (the "Software"), to deal in the Software without
   restriction, including without limitation the rights to use, copy,
   modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

BeginPackage["Lazy`"];

Lazy::usage = "Lazy can turn most things (InputStream, Function in NaturalNumbers, a List) into a LazyList."
LazyList::usage = "A wrapper type that holds a lazy list."
EmptyQ::usage = "A predicate that determines if a given LazyList is empty."
LazySource::usage = "A lazy list generator that takes a source such as Prime[] or Fibonacci[]."

Begin["`Private`"];

Unprotect[Lazy,LazyList,EmptyQ,LazySource]

SetAttributes[LazyList, {HoldAll}]

EmptyQ[LazyList[]] := True
EmptyQ[LazyList[_,_]] := False

LazyList/:First[LazyList[h_,_]] := h
LazyList/:Rest[LazyList[_,t_]] := t
LazyList/:Most[LazyList[h_,t_]] := If[EmptyQ[t],t,LazyList[h,Most[t]]]
LazyList/:Last[z_LazyList] := First[NestWhile[Rest, z, !EmptyQ[Rest[#]]&]]

LazyList/:Part[z_LazyList,0] := LazyList
LazyList/:Part[z_LazyList,1] := First[z]
LazyList/:Part[z_LazyList,n_Integer] := Part[Rest[z],n-1]

LazyList/:Take[z_LazyList, 0] := LazyList[]
LazyList/:Take[z_LazyList, n_] /; n > 0 :=
  With[{nn = n-1}, LazyList[First[z], Take[Rest[z], nn]]]

LazyList/:TakeWhile[z_LazyList,crit_] := If[!crit[First[z]],LazyList[],LazyList[First[z],TakeWhile[Rest[z],crit]]]

LazyList/:List[z_LazyList] :=
  Module[{tag}
  , Reap[
      NestWhile[(Sow[First[#], tag]; Rest[#])&, z, !EmptyQ[#]&]
    , tag
    ][[2]] /. {l_} :> l
  ]

LazyList/:Map[_, LazyList[]] := LazyList[]
LazyList/:Map[fn_, z_LazyList] := LazyList[fn[First[z]], Map[fn, Rest[z]]]

LazyList/:Select[z_LazyList, pred_] :=
  NestWhile[Rest, z, (!EmptyQ[#] && !pred[First[#]])&] /.
    LazyList[h_, t_] :> LazyList[h, Select[t, pred]]

LazyList/:Fold[fun_,x0_,z0_LazyList] :=
  NestWhile[{fun[#[[1]],First[#[[2]]]],Rest[#[[2]]]}&,{x0,z0},!EmptyQ[#[[2]]]&][[1]]

LazyList/:FoldList[_,_,LazyList[]] := LazyList[]
LazyList/:FoldList[fun_,x0_,z0_LazyList] :=
  fun[x0,First[z0]]/.x1_:>LazyList[x1,FoldList[fun,x1,Rest[z0]]]

LazyList[{}] := LazyList[]
LazyList[lst_List] := LazyList[Evaluate[First[lst]],LazyList[Evaluate[Rest[lst]]]]

LazyList[f_] := LazySource[f,1]
LazySource[f_, n_:1] := With[{nn = n + 1}, LazyList[Evaluate[f[n]], LazySource[f, nn]]]

Lazy[Primes] := LazySource[Prime,1]
Lazy[Integers] := LazySource[#&,1]
Lazy[lst_List] := LazyList[Evaluate[First[lst]],LazyList[Evaluate[Rest[lst]]]]

(*This one doesn't work very well yet.*)
Lazy[instream_InputStream] := LazyList[Evaluate[Read[instream,String]],Lazy[instream]]
LazyList[EndOfFile,_] := LazyList[]

Protect[Lazy,LazyList,EmptyQ,LazySource]

End[]

EndPackage[]
