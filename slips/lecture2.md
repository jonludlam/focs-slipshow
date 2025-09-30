# Foundations of Computer Science: Lecture 2



<script async
  src="https://jon-test.ludl.am/x-ocaml/x-ocaml.js"
  src-worker="https://jon-test.ludl.am/x-ocaml/x-ocaml.worker+effects.js"
  integrity="sha256-T2lRoUyNlpr5N9QwCL8j4wKtBz/jewDppgxcbh40oqA="
  crossorigin="anonymous"
  x-ocamlformat="disable"
  src-style="xocaml.css"
></script>

## Warmup 1

<x-ocaml>
let rec npower x n =
  if n = 0 then
    1.0
  else
    x *. npower x (n - 1)
</x-ocaml>

- How do we interpret the type of `npower`? {pause}
- What happens if we remove the `rec` keyword? {pause}
- What happens if we use `*` rather than `*.`?

{pause}
## Warmup 2

What does this return?

<x-ocaml>
3 + -0.2;;
</x-ocaml>

{pause up-at-unpause}
# Expression evaluation

{.example}
$E_0 \Rightarrow E_1 \Rightarrow ... \Rightarrow E_n \Rightarrow v$

{pause}
Focus on _expressions_; ignore _side-effects_ for now.

This discipline of separating expression from effects is often known as _functional programming_.

We will return to side effects later in the course to make useful programs!

{pause}

{.hidden}
<x-ocaml>
let even n = n mod 2 = 0
</x-ocaml>

<br style="clear:both">
<hr></hr>

{.lefthalf}
<x-ocaml>
let rec power x n =
  if n = 1 then x
  else if even n then
    power (x *. x) (n / 2)
  else
    x *. power (x *. x) (n / 2)
</x-ocaml>

{pause}

{.righthalf}
- power 2.0 12 $\Rightarrow$ {pause}
- power 4.0 6 $\Rightarrow$ {pause}
- power 16.0 3 $\Rightarrow$ {pause}
- 16.0 *. power 256.0 1 $\Rightarrow$ {pause}
- 16.0 *. 256.0 $\Rightarrow$ {pause}
- 4096.0

<br style="clear:both">
<hr></hr>

{#summing pause center-at-unpause}
# Summing the first `n` integers

{.lefthalf}
<x-ocaml>
let rec nsum n =
    if n = 0 then
        0
    else
        n + nsum (n - 1)
</x-ocaml>

{pause .righthalf}
> $$
> \begin{eqnarray}
> \textrm{nsum 3}&\Rightarrow&3 + (\textrm{nsum 2})\\
> &\Rightarrow&3 + (2 + (\textrm{nsum 1}))\\
> &\Rightarrow&3 + (2 + (1 + (\textrm{nsum 0})))\\
> &\Rightarrow&3 + (2 + (1 + 0))\\
> \end{eqnarray}
> $$

{pause  up=summing}

<div id="tohide">

{.overlay}
<svg class="large-arrow" viewBox="0 0 300 150" style="position: absolute; z-index: 10; pointer-events: none; transform: translateY(10px) translateX(-220px);">
    <defs>
      <marker id="bigArrowhead" markerWidth="5" markerHeight="4"
              refX="0" refY="2" orient="auto">
        <polygon points="0 0, 5 2, 0 4" fill="rgba(255, 0, 0, 0.7)" />
      </marker>
    </defs>
    <line x1="20" y1="110" x2="100" y2="45"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="3"
          marker-end="url(#bigArrowhead)" ></line>
    <line x1="20" y1="110" x2="100" y2="60"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="3"
          marker-end="url(#bigArrowhead)" ></line>
    <line x1="20" y1="110" x2="100" y2="75"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="3"
          marker-end="url(#bigArrowhead)" ></line>
    <line x1="20" y1="110" x2="100" y2="90"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="3"
          marker-end="url(#bigArrowhead)" ></line>
  </svg>

<br style="clear:both">


{.lefthalf}
Intermediate results are stored in the program _stack_
which is usually of limited size
 

{.righthalf}
Nothing can progress until the final expression is calculated!

<br style="clear:both">

{.definition}
> Two types of storage:
> - **heap** is a global area where the memory storing values bound to names are tracked
> - **stack** is a list where function call arguments are pushed and return values popped. 

</div>

{pause exec}
```slip-script
let elt = document.getElementById('tohide')
console.log("XXX: "+elt)
elt.style.display="none"
slip.onUndo(() => elt.style.display="block")
```

<br style="clear:both">

<hr/>

## Iteratively summing




{.lefthalf}
<x-ocaml>
let rec summing n total =
  if n = 0 then
     total
  else 
    summing (n-1) (n+total)
</x-ocaml>

{pause .righthalf}
> $$
> \begin{eqnarray}
> \textrm{summing 3 0}&\Rightarrow&\textrm{summing 2 3}\\
> &\Rightarrow&\textrm{summing 1 5}\\
> &\Rightarrow&\textrm{summing 0 6}\\
> &\Rightarrow&6
> \end{eqnarray}
> $$

<br style="clear:both" />
<hr/>

{pause}
Extra argument `total` acts as the _accumulator_ to keep track explicitly instead of using the stack

Algorithms like this are known as _iterative_ or _tail recursive_

{pause up-at-unpause}
# Recursion vs iteraction

- Why two terms _iterative_ and _tail recursive_?
  + "Iterative" normally refers to a loop: e.g. coded using [while].
  + "Tail-recursion" involves the recursive function call being the last thing that expression does.
- Tail-recursion is efficient only if the compiler detects it.
  + Mainly it saves space, though iterative code can run faster.
- Do not make programs iterative unless you determine the gain is significant.

{pause}
# How can we analyse our programs for efficiency?

{#sillysum pause}
## Silly summing the first n integers

<x-ocaml>
let rec sillySum n=
  if n = 0 then
    0
  else
    n + (sillySum (n-1) + sillySum (n-1)) / 2

</x-ocaml>

<pre></pre>

**Recursively** calls itself twice for every invocation

{.overlay}
<svg class="large-arrow" viewBox="0 0 300 150" style="position: absolute; z-index: 10; pointer-events: none; transform: translateY(-200px) translateX(0px);">
    <defs>
      <marker id="bigArrowhead2" markerWidth="5" markerHeight="4"
              refX="0" refY="2" orient="auto">
        <polygon points="0 0, 5 2, 0 4" fill="rgba(255, 0, 0, 0.7)" />
      </marker>
    </defs>
    <line x1="20" y1="30" x2="45" y2="18"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="1"
          marker-end="url(#bigArrowhead2)" ></line>
    <line x1="20" y1="30" x2="95" y2="14"
          stroke="rgba(255, 0, 0, 0.7)"
          stroke-width="1"
          marker-end="url(#bigArrowhead2)" ></line>
  </svg>

{pause up=sillysum .lefthalf}
Should **assign** the result to a local variable to prevent evaluating it twice

{.righthalf}
<x-ocaml>
let x = 2.0 in
let y = Float.pow x 20.0 in
y *. (x /. y)
</x-ocaml>

<br style="clear:both"></br>

{pause .outline}
Asymptotic complexity refers to how program costs grow with increasing inputs

Usually **space** or **time**, with the latter usually being larger than the former.

**Question:** if we double our processing power, how much does our computation capability increase?

{#timecomplexity}
# Time complexity

{.nicetable}
| complexity | 1 second | 1 minute | 1 hour | **gain** |
|------------|----------|----------|--------|----------|
| $n$        | $1000$   | $60,000$ | $3,600,000$ | $\times 60$ |
| $n\log n$  | $140$    | $4,893$  | $200,000$ | $\times 41$ |
| $n^2$ | $31$ | $244$ | $1,897$ | $\times 8$ |
| $n^3$ | $10$ | $39$ | $153$ | $\times 4$ |
| $2^n$ | $9$ | $15$ | $21$ | $+ 6$ |

{pause up=timecomplexity #comparing}
# Comparing algorithms with O(n)

{.definition}
$f(n) = O(g(n))$
provided that
$\left|f(n)\right| \le c\left|g(n)\right|$

{pause up=comparing}
Intuitively, consider the _most significant term_ and ignore constant or smaller factors

e.g. simplify $3n^2 + 34n + 433 \to n^2$

{pause}
# Facts about O notation

{.nicetable}
|--:|--|--|
|$O(2g(n))$|**is the same as**|$O(g(n))$|
|$O(\log_{10} n)$|**is the same as**|$O(\ln n)$|
|$O(n^2+50n+26)$|**is the same as**|$O(n^2)$|
|$O(n^2)$|**is contained in**|$O(n^3)$|
|$O(2^n)$|**is tcontained in**|$O(3^n)$|
|$O(\log n)$|**is contained in**|$O(\sqrt{n})$|

{pause up-at-unpause}
# Common complexity classes

{.nicetable}
|-|-|
|$O(1)$|_constant_|
|$O(\log n)$|_logarithmic_|
|$O(n)$|_linear_|
|$O(n\log n)$|_quasi-linear_|
|$O(n^2)$|_quadratic_|
|$O(n^3)$|_cubic_|
|$O(a^n)$|_exponential_ (for fixed a)|

{pause}
# Sample costs in O-notation

{.nicetable}
|Function|Time|Space|
|--------|----|-----|
|npower, nsum| $O(n)$| $O(n)$|
|summing| $O(n)$ | $O(1)$|
|$n(n+1)/2$|$O(1)$|$O(1)$|
|power | $O(\log n)$|$O(\log n)$|
|sillySum| $O(2^n)$|$O(n)$|

{pause up-at-unpause}
# Simple recurrence relations

$T(n)$: a cost we want to bound using $O$ notation

Typical _base case_: $T(1)=1$

Some recurrences:

{.lefthalf}
$$
\begin{eqnarray}
T(n+1)&=&T(n)+1\\
T(n+1)&=&T(n)+n\\
T(n)&=&T(n/2)+1\\
T(n)&=&2T(n/2)+n
\end{eqnarray}
$$

{pause}
{.righthalf .srr}
- $O(n)$ {pause}
- $O(n^2)$ {pause}
- $O(\log n)$ {pause}
- $O(n \log n)$

<br style="clear:both"/>

{pause up-at-unpause}
# Mapping this to OCaml

## Example 1
<div style="position: relative;">

{.lefthalf}
<x-ocaml>
let rec nsum n =
  if n = 0 then
    0
  else
    n + nsum (n - 1)
</x-ocaml>

{.callout style="position: absolute; top: 20px; left: 50%; width: 350px;" .arrow-left}
Given (n+1), does a constant amount of work

{pause .callout .arrow-top style="position: absolute; top:200px; left: 0%; width:350px;" .arrow-top}
Then calls itself with $n$

</div>

<br style="clear:both; margin-bottom:300px">

Therefore, recurrence relations are:

{.lefthalf}
$$
\begin{eqnarray}
T(0)&=&1 \\
T(n+1)&=&T(n)+1
\end{eqnarray}
$$

{pause .righthalf style="margin-top:50px"}
$O(n)$

<br style="clear:both"></br>


{pause up-at-unpause}
## Example 2
<div style="position: relative;">

{.lefthalf}
<x-ocaml>
let rec nsumsum n =
  if n = 0 then
    0
  else
    nsum (n-1) + nsumsum (n-1)
</x-ocaml>

{pause .callout .arrow-top style="position: absolute; top:200px; left: 0%; width:350px;" .arrow-top}
Calls `nsum` which takes $O(n)$

{.callout style="position: absolute; top:90px; left: 50%; width: 350px;" .arrow-left}
then calls itself once

</div>

<br style="clear:both; margin-bottom:300px">

{pause}
Therefore, recurrence relations are:

{.lefthalf}
$$
\begin{eqnarray}
T(0)&=&1 \\
T(n+1)&=&T(n)+n
\end{eqnarray}
$$

{pause .righthalf style="margin-top:50px"}
$O(n^2)$


<br style="clear:both"></br>


{pause up-at-unpause}
## Example 3
<div style="position: relative;">

{.lefthalf}
<x-ocaml>
let rec power x n =
    if n = 1 then x
    else if even n then
      power (x *. x) (n / 2)
    else
      x *. power (x *. x) (n / 2)
</x-ocaml>

{.callout style="position: absolute; top: 20px; left: 50%; width: 350px;" .arrow-left}
Calls itself recursively once

{pause .callout .arrow-top style="position: absolute; top:200px; left: 22%; width:350px;" .arrow-top}
Always divides iteration count by two

</div>

<br style="clear:both; margin-bottom:300px">

Therefore, recurrence relations are:

{.lefthalf}
$$
\begin{eqnarray}
T(0)&=&1 \\
T(n)&=&T(n/2)+1
\end{eqnarray}
$$

{pause .righthalf style="margin-top:50px"}
$O(\log n)$





