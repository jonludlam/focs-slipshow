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

## Visualisation, prediction and guardrails (downloaded through Cambridge access)

| File | Why |
|---|---|
| `33-bastani-et-al-2025-generative-ai-can-harm-learning.pdf` | Field RCT with about 1,000 high-school maths students. Unrestricted GPT-4: +48% in practice, −17% on the unaided exam. A tutor that only gives hints mostly avoided the harm. **The PDF's header says "See correction for this article"**: check the correction on [the PNAS page](https://doi.org/10.1073/pnas.2422633122) before quoting numbers. |
| `34-crouch-et-al-2004-classroom-demonstrations.pdf` | Students who only watched a demonstration did no better than those who never saw it. Those who predicted first did better. The case for predict-the-step. |
| `35-hundhausen-douglas-stasko-2002-av-meta-study.pdf` | Meta-study of 24 experiments: how students use an algorithm visualisation matters more than what it shows. |
| `36-naps-et-al-2002-engagement-taxonomy.pdf` | The engagement taxonomy (no viewing, viewing, responding, changing, constructing, presenting). |
| `37-sorva-karavirta-malmi-2013-program-visualization-review.pdf` | Review of program visualisation systems for intro programming (64 pages). Mostly passive animation, and little evidence on engagement. |

## Not read, but worth knowing about

- Not a paper, but short and worth reading: Regehr, "Zero
  Degrees-of-Freedom Programming",
  <https://john.regehr.org/writing/zero_dof_programming.html>.
