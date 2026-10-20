# Reading list

These are PDFs of the papers behind `AI-NOTES.md`, `EXERCISES.md`,
`ANIMATIONS.md` and the tick work. The PDFs aren't in git (`.gitignore`);
this list is. Every file was checked to be the paper named.

## Read first (about 2 hours)

| File | Why |
|---|---|
| `01-fisler-krishnamurthi-littman-2026-agentic-ai-era.pdf` | CACM viewpoint, 6 pages: "flaky compilers", intro courses as early software engineering, specification first. The position everything else hangs off. |
| `03-wrenn-krishnamurthi-2019-examplar.pdf` | Examplar: examples first, checked against wheats and chaffs. The basis of the tick chaffs and the examples-first questions. |
| `07-wrenn-krishnamurthi-fisler-2018-who-tests-the-testers.pdf` | What goes wrong with automated grading. That's what the tick audit found: 48 of 176 chaffs passing. |
| `20-prather-et-al-2024-widening-gap.pdf` | GenAI helps students who already have a plan, and makes things worse for those who are struggling. The key "who gets hurt" result. |
| `21-shen-tamkin-2026-ai-assistance-coding-skills.pdf` | Anthropic's RCT: 50% vs 67% on the quiz with and without AI, and the biggest gap on debugging. Delegating hurts; asking for explanations doesn't. |
| `24-zhang-pientka-si-2026-llms-functional-programming-course.pdf` | LLMs on an OCaml course (McGill). Being in OCaml no longer protects a course. |

## Krishnamurthi and colleagues (Brown)

| File | Why |
|---|---|
| `02-prasad-et-al-2026-pick-human-in-the-loop.pdf` | PICK: meaningful but moderate human checking of AI output, using inputs where the candidates disagree. |
| `04-wrenn-krishnamurthi-2020-testing-without-coercion.pdf` | Students write tests early when the environment encourages it ("Begin Implementation"). |
| `05-prasad-et-al-2022-making-hay-from-wheats.pdf` | Examples that fail the wheat show misconceptions, and make better chaffs than experts write. |
| `06-prasad-et-al-2024-conceptual-mutation-testing.pdf` | Clustering wheat failures into a small set of chaffs. |
| `08-lu-krishnamurthi-2024-smol-tutor-misconceptions.pdf` | SMoL Tutor: misconceptions about binding, mutation and aliasing, detected with "misinterpreters". For lecture 11. |
| `09-krishnamurthi-et-al-2022-performance-preconceptions.pdf` | Students' firm, wrong beliefs about performance. For lecture 2 and the growth feedback. |
| `10-clements-krishnamurthi-2022-notional-machine-stacks.pdf` | Standard stack diagrams reinforce misconceptions. Read before drawing recursion. |
| `11-rivera-krishnamurthi-goldstone-2022-plan-composition-hof.pdf` | Students recognise single higher-order functions, but not compositions of them. For lecture 8. |
| `12-rivera-krishnamurthi-2022-structural-vs-pipeline-hof.pdf` | Structural compositions are harder than pipelines (matrix transpose is structural). |
| `13-lu-et-al-2023-switching-functional-languages.pdf` | What goes wrong when students move between languages, e.g. from Python to OCaml. |
| `14-krishnamurthi-thiessen-vahrenhold-2025-porpoise.pdf` | Purpose statements turned into code by an LLM: specification practice. Mixed results. |

## AI and learning to program: the wider evidence

| File | Why |
|---|---|
| `22-prather-et-al-2025-beyond-the-hype.pdf` | ITiCSE working-group review. Results were more often positive with guardrails (73%) than without (55%). Marks are moving to invigilated and oral assessment. |
| `23-craig-denny-kiesler-prather-2026-dagstuhl-genai-programming-education.pdf` | Dagstuhl 25311, the views of 42 experts: "many small autograded programs" is obsolete, assessment in "two lanes", specification neglected. |
| `25-porter-et-al-2025-cs1-llm-outcomes.pdf` | UCSD's first course built around LLMs: exams "largely similar" to before. No harm shown, but no gain either. |
| `26-zamfirescu-pereira-et-al-2025-61a-bot.pdf` | Berkeley 61A-Bot: homework time saved and staff relieved. It didn't measure learning. |
| `27-smith-zilles-2024-code-generation-based-grading-eipe.pdf` | Autograding code-reading ("Explain in Plain English") answers by generating code from them. |
| `28-lehmann-cornelius-sting-ai-meets-the-classroom.pdf` | Pre-registered experiments: AI used as a tutor helps, used to solve the work hurts. Students overestimate what they learned. |
| `29-kazemitabaar-et-al-2023-ai-code-generators-novices.pdf` | The main counterweight: no harm to retention for novices aged 10–17. |

## Tools behind the prototypes

| File | Why |
|---|---|
| `30-furukawa-cong-asai-2018-stepping-ocaml.pdf` | The stepper we tried and compiled for the browser (`demos/stepper/`). |
| `31-goldsmith-aiken-wilkerson-2007-empirical-complexity.pdf` | trend-prof: fitting operation counts against input size. The idea behind `focs-check`'s Count and Growth. |
| `32-hoffmann-das-weng-2017-raml-ocaml.pdf` | RAML: static resource bounds for OCaml. The road not taken, explained in `EXERCISES.md` §4. |

## Not downloaded (paywalled, or the download was blocked)

- Bastani et al., "Generative AI without guardrails can harm learning",
  PNAS 2025, <https://doi.org/10.1073/pnas.2422633122> (PNAS refused the
  download; SSRN version: <https://papers.ssrn.com/abstract=4895486>).
  Unrestricted GPT-4: +48% in practice, −17% on the exam. A tutor that only
  gives hints mostly avoided the harm.
- Crouch, Fagen, Callan, Mazur, "Classroom demonstrations: learning tools or
  entertainment?", Am. J. Phys. 2004, <https://doi.org/10.1119/1.1707018>.
  Predicting before a demonstration helps; only watching doesn't. This
  supports predict-the-step.
- Hundhausen, Douglas, Stasko, meta-study of algorithm visualisation, JVLC
  2002, <https://doi.org/10.1006/jvlc.2002.0237>.
- Naps et al., the engagement taxonomy, ITiCSE WG 2002,
  <https://doi.org/10.1145/960568.782998>.
- Sorva, Karavirta, Malmi, a review of program visualisation systems, TOCE
  2013, <https://doi.org/10.1145/2490822>.
- Not a paper, but short and worth reading: Regehr, "Zero
  Degrees-of-Freedom Programming",
  <https://john.regehr.org/writing/zero_dof_programming.html>.
