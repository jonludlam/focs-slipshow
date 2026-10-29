# Past FoCS exam questions: scenarios for notebook exercises

I read every Paper 1 FoCS question listed on the
[official index](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/t-FoundationsofComputerScience.html),
1995 to 2026: 3 questions a year up to 2008, then 2 a year. PDFs and the `pdftotext` output are in
`papers/exams/` (gitignored). Links are of the form
`https://www.cl.cam.ac.uk/teaching/exams/pastpapers/yYYYYp1qN.pdf`. OCaml translations for
1995-2017 are at `https://www.cl.cam.ac.uk/teaching/2627/FoundsCS/past-papers/yYYYYp1qN.pdf`.
I checked that these are listed, but I did not read them. Before 2019 the questions are in SML.
The 2025 and 2026 questions are included for their themes only, since their solutions are not
out yet.

Most questions before 2017 are just "write function X". The ones below have a story,
or could be given one.

## 1. Scenarios

| Ref | Scenario | Lect. | Fresh notebook idea |
|---|---|---|---|
| [2026 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2026p1q1.pdf) * | L-system (dragon curve) drives a grid turtle | 3, 6, 8 | (themes only) Other L-systems (Koch, Hilbert, Sierpinski) drawn as SVG. Check against the known coordinate lists. |
| [2026 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2026p1q2.pdf) * | Prefix-code decoding: bits are paths down a tree | 6, 9 | (themes only) Build the Huffman tree as well, then round-trip a text. |
| [2025 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2025p1q2.pdf) * | Arithmetic in Polish notation, reduced one step at a time | 6 | (themes only) Predict the next reduction step, then show it animated. |
| [2025 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2025p1q1.pdf) * | Find the five bugs in a mergesort; test several sorts against each other | 5, 8 | (themes only) Bug hunt: the notebook ships buggy code and a `check_sorted` oracle. |
| [2024 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2024p1q1.pdf) | Examiner's statistics: mean and std dev per question, with 0 meaning "not attempted" | 8 | Real-looking marks table. Pipelines built from map/filter/fold, with an `option` result for empty data. |
| [2024 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2024p1q2.pdf) | Trial-division primality using `fold_range` | 1, 8 | Count the divisions done. Plot the cost against n to see the sqrt(n) bound. |
| [2023 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2023p1q1.pdf) | Sort values by how often they occur (sort, then RLE, then sort again) | 5, 8 | Letter frequencies of a real text; a first step towards Huffman. |
| [2023 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2023p1q2.pdf) | Quadtree of points, with a "is any point in this rectangle?" query | 6, 7 | Plot the points and the splits. Count the nodes visited versus a list scan. |
| [2022 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2022p1q1.pdf) | Wordle-style letter game. `create_game` returns a closure that allows at most 6 tries | 8, 11 | Play the closure in the notebook. Hidden state, done with references. |
| [2022 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2022p1q2.pdf) | Integer sets stored as interval lists (as in a calendar or IP ranges), kept in standard form | 4 | Merge free/busy calendars. Property tests against a naive set. |
| [2021 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2021p1q1.pdf) | The same-fringe problem: do two trees have the same leaves, in order? | 6, 9 | Count the thunks forced, lazy versus flatten-first, on two huge trees that differ at the first leaf. |
| [2021 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2021p1q2.pdf) | One matrix stored as list-of-lists, array-of-arrays, or Braun tree of Braun trees | 7, 11 | Time `get` for each representation and compare with its big-O. |
| [2020 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2020p1q1.pdf) | Park ranger survey: tree species as a variant, plus a cyclic "spotter" simulator | 6, 11 | Contrast the stateful generator with the pure one; leads into seq in L9. |
| [2020 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2020p1q2.pdf) | Mastermind: generate every code, filter by the feedback | 4, 8 | A solver that plays against the student's code. Watch the candidate set shrink. |
| [2019 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2019p1q1.pdf) | Peano, binary (bool list) and Church numerals, plus a full adder | 1, 8 | Check every representation against `int`. Puzzle: what is `two three`? |
| [2019 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2019p1q2.pdf) | Nested lists (JSON-like): flatten, map, and `pack_as` (refill the same shape) | 6, 8 | Format/unformat round trips. |
| [2018 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2018p1q2.pdf) | Coin-row game: take the leftmost or rightmost coin; find optimal play | 2, 10 | Play against an optimal bot. Count calls to see the 2^n blow-up. |
| [2017 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2017p1q1.pdf) | One-person puzzles (Rubik's cube, peg solitaire). DFS can loop forever, so iterative deepening is needed | 10 | Show the DFS stuck in a cycle, then iterative deepening finding the path. |
| [2017 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2017p1q2.pdf) | All numbers 5^i 7^j 9^k, generated in increasing order (Hamming-style) | 9 | Merge infinite streams. Check the first 50 against a brute-force answer. |
| [2016 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2016p1q2.pdf) | Split "abracadabra" into dictionary chunks (word segmentation); also a sieve and dedup | 6, 9 | Exceptions used for backtracking, then a lazy stream of all segmentations. |
| [2015 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2015p1q2.pdf) | Enumerate every cell of an infinite 2-D table (dovetailing) | 9 | Animate the diagonal walk; each cell is reached within a bounded number of steps. |
| [2014 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2014p1q2.pdf) | Run-length encoding; "equal with at most n errors" (spell-check, diff) | 4 | Fuzzy matching of typos against a word list. |
| [2013 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2013p1q1.pdf) | Every tree shape with a given inorder (all possible BSTs) | 6, 7 | Draw them all; the counts are 1, 2, 5, 14 (Catalan numbers). |
| [2013 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2013p1q2.pdf) | A "lazy" permutations function that is secretly eager | 9 | Debugging: a counter shows that everything was computed up front. |
| [2012 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2012p1q1.pdf) | Range slices of a BST (records with key in [x, y]); union | 7 | A database range query. Count the nodes visited versus the whole tree. |
| [2011 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2011p1q1.pdf) | Labyrinth given as a function of (x, y); reachability; shortest path by BFS | 8, 10 | Maze shown on a grid; the BFS frontier grows step by step. |
| [2010 Q1](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2010p1q1.pdf) | `iterates`, and `iterates2` over a 2-D grid of (f^m x, g^n y) | 9 | Collatz or Newton iterations as streams. |
| [2009 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2009p1q2.pdf) | Is BST t1 contained in BST t2, in O(n1+n2)? | 7 | Compare inorder traversals; count the comparisons. |
| [2008 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2008p1q6.pdf) | A puzzle as a record of `next` and `wins` (n goes to n+2 or n+5; target 10) | 8, 10 | One generic solver that works for many puzzles. |
| [2006 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2006p1q6.pdf) | Intersection of two dictionaries (cat=3, dog=2, ...) | 7 | Two pet shops' stock lists. |
| [2005 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2005p1q6.pdf) | Root-to-leaf paths whose sum is prime: first one, all of them, a lazy stream | 6, 9 | One problem done three ways: exception, list, seq. |
| [2004 Q5](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2004p1q5.pdf) | Iterative deepening over an infinite lazy tree | 9, 10 | Visualise the depth bound growing. |
| [2004 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2004p1q6.pdf) | A functional array stored as a function, versus a Braun tree | 7, 8 | Show the chain of closures growing as updates pile up, so reads get slower. |
| [2002 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2002p1q6.pdf) | Binary search on a monotone function (integer sqrt, "guess my number") | 2 | Count the steps; log n by experiment. |
| [2001 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2001p1q6.pdf) | Power series as infinite streams (Taylor series of exp) | 9 | Sum the first k terms to approximate e. Multiplying series gives a convolution. |
| [2000 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2000p1q6.pdf) | Detect a cycle in a mutable linked list | 11 | Tortoise and hare, with a pointer diagram. |
| [1999 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y1999p1q6.pdf) | Family trees: why the naive cyclic datatype fails; subtrees matching a predicate | 6, 8 | Genealogy queries. |
| [1997 Q5](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y1997p1q5.pdf) | Noughts and crosses: build the full game tree, count the games O wins | 6, 8 | Fold over the tree. The total number of games is a known figure to check against. |
| [1996 Q2](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y1996p1q2.pdf) | Boolean expressions: list the variables, evaluate, check for a tautology | 6, 8 | A truth-table tool; test it with De Morgan's laws. |
| [1996 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y1996p1q6.pdf) | Cantor's diagonal argument with lazy decimal digits | 9 | Construct a real that is missing from any list you are given. |
| [1995 Q6](https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y1995p1q6.pdf) | Arithmetic on binary numbers stored as bit lists, least significant bit first | 1, 3 | Bignum add and multiply, checked against `int`. |

\* 2025 and 2026: themes only.

## 2. Recurring themes

- **Games and puzzles:** noughts and crosses, Mastermind, Wordle, coin row, Rubik's cube and peg solitaire, the n+2/n+5 puzzle, mazes. Usually the question is "search a state space".
- **Encodings and representations:** RLE (2014, 2023), prefix codes, numerals (binary, Peano, Church), interval sets, matrices, functional arrays.
- **Infinite mathematics:** Hamming numbers, power series, Cantor's diagonal argument, dovetailing, the integers enumerated lazily, binary strings and palindromes (2003 Q5).
- **Generate everything, then filter:** permutations (1999, 2006, 2013), all trees, subset sums (2001 Q5), Mastermind candidates.
- **Spatial and geometry:** labyrinth, quadtree, turtle and L-system.
- **Text:** word segmentation, fuzzy equality, frequency sort, T9 (already Tick 3**).
- **Real-world data:** park survey, exam statistics, the pet-shop dictionaries.
- **Recurring question types:** "rewrite this without exceptions or references" (2007, 2011), "why isn't this lazy?" (2013), "fix the bugs" (2025). All three work well as notebook cells that students predict, then run.

## 3. Top 8 recommendations (lectures 6-10)

1. **Maze explorer (L10; 2011 Q1, 2017 Q1, 2008 Q6).** The maze is a function `pos -> pos list`. First, naive DFS, shown visibly looping on a cycle. Then iterative deepening, then BFS with the L10 queue for the shortest path. An animated frontier makes it a good fit for predict-the-step. Auto-check: path length equals the known optimum, and the visited count stays under a bound.
2. **Noughts and crosses game tree (L6, L8; 1997 Q5).** Build the full tree, then fold over it to count wins, draws and games. Check the counts against the well-known totals (I have not re-derived them here). Then add minimax and play against it. The story is easy to grasp, it is a real tree, and HOFs make the counting short.
3. **Same fringe (L9, L6; 2021 Q1).** A classic problem where laziness clearly wins. Make two trees with a million leaves that differ at leaf 1. The eager version builds everything; the lazy one stops after a few forces. Instrument the thunks so students can see the difference.
4. **Quadtree map search (L6, L7; 2023 Q2).** Café locations on a map; "is anything in this rectangle?". Plot the splits as an SVG. Count the nodes visited versus a list, so pruning becomes something students can see. This generalises BST search to 2-D, which shows students that the BST idea carries further.
5. **Truth-table and tautology checker (L6, L8; 1996 Q2).** Datatype for formulas, list the variables, enumerate all valuations with map, use `List.for_all`. Check it on De Morgan's laws and a few non-tautologies; it should return a counterexample. Short, useful, and it links to Digital Electronics.
6. **Streams of numbers (L9; 2017 Q2, 2001 Q6).** Hamming numbers by merging ordered infinite streams, then power series: `exp` as a stream, check that its partial sums converge to e, and that exp times exp gives exp(2x). Gives laziness a real mathematical use and is easy to auto-check.
7. **Mastermind solver (L8, L4; 2020 Q2).** `generate n`, `feedback`, and a curried `test`. Repeatedly filter the candidates down to the answer. Students' code plays against a hidden code and gets a score for the number of guesses. Currying, filter, and a satisfying finish.
8. **Dictionaries in practice (L7; 2012 Q1, 2009 Q2, 2006 Q6).** One BST of records, then a range query (`takeSlice`), intersection and "superseded". Each is checked against a list model, and the nodes visited are counted. Gives BSTs a database story instead of insert/lookup drills.

Runner-up: **word segmentation** (2016 Q2c). Exceptions used for backtracking (L6), upgraded to a lazy stream of all parses (L9). It overlaps with the T9 tick, so it fits as a follow-on.

## Not verified

- pdftotext lost the diagrams in 2011 Q1 (labyrinth), 2023 Q2 (quadtree) and 2026 Q2 (trees). My summaries come from the question text.
- I did not look at any official solutions or examiners' reports, and did not read the OCaml translations.
- The lecture numbers are my own mapping onto the 11-lecture plan.
- I did not check the noughts-and-crosses total game count here.
