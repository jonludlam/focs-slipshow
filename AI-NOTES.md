# Notes: AI and teaching FoCS

These are background notes, not a plan. They collect what well-regarded
groups are doing about generative AI and coding agents in early programming
courses, with links to the original material. The focus is 2025–26: anything
older is mostly out of date given how fast the tools have moved.

Things specific to FoCS to keep in mind while reading:

- The exam is on paper and done without AI, so students must still be able
  to write and trace OCaml by hand.
- The ticks are autograded nbgrader notebooks with visible tests, and current
  models can almost certainly solve them. (Not yet measured.)
- Supervisions already give us small-group, face-to-face contact, where
  students can be asked to explain their work.

---

## Brown: Fisler, Krishnamurthi, Littman

### "Teaching Novice Computing and Programming in the Agentic AI Era" (CACM Viewpoint, due Nov 2026)

- Page: <https://cs.brown.edu/people/sk/Publications/Papers/Published/fkl-teach-nov-agentic-ai-era/>
- PDF: <https://cs.brown.edu/people/sk/Publications/Papers/Published/fkl-teach-nov-agentic-ai-era/paper.pdf>
- DOI: [10.1145/3838277](https://doi.org/10.1145/3838277)

The main points:

- **Agents are "flaky compilers".** They are compilers, from natural language
  to code, which raises what novices can build. They are flaky because prose
  is ambiguous, the output varies from run to run, and nothing guarantees the
  meaning is preserved.
- Prose given to an agent is really a **specification**, and anything left
  unpinned is a choice the agent makes for you.
- **What distinguishes a computing graduate** becomes being able to *stand
  behind* what they produce: correctness, testability, performance, usability
  and the other "-ilities". They cite Parnas on software shipping with
  disclaimers rather than guarantees.
- **Intro courses should become early software-engineering courses.** That
  means program plans, test plans, test suites, properties, constraints and
  data organisation, in a semi-structured *specification format* that sits
  between the student and the code and can be graded. The emphasis is
  explicitly *not* on prompting.
- **Two versions of the redesign:**
  - *Radical:* students write almost no code, and programming moves later in
    the degree, the way assembly did. They admit this is unproven.
  - *Moderate:* students learn to **read code before writing it**, and
    writing is mixed in. Some problems are sized to what students can write
    by hand. Others are deliberately beyond that, so students work on
    everything except the code.
- They argue that tracing doesn't scale to agent-sized output.
- On attitude: educators must do more than design "defeat devices"
  (AI-proof assignments).
- The evidence is a single Spring 2026 course with 19 students (below). They
  call for research into how to teach specification.

### Agentic Studio (CSCI 1970KF, Spring 2026)

- Course site: <https://cs.brown.edu/courses/csci1970kf/agentic-spr-2026/index.html>
- Assignments: <https://cs.brown.edu/courses/csci1970kf/agentic-spr-2026/assignments.html>
- Schedule and readings: <https://cs.brown.edu/courses/csci1970kf/agentic-spr-2026/schedule.html>
- Brown news write-up: <https://www.brown.edu/news/2026-06-11/agentic-studio-ai-programming>

Notes on the course:

- About 20 students (from about 80 applicants), each with at least one prior
  course. It calls itself "a research project masquerading as a course".
  Students got Claude Code accounts. There were no TAs.
- Projects deliberately push beyond what the agent handles easily:
  - [Tetris with switchable gravity](https://cs.brown.edu/courses/csci1970kf/agentic-spr-2026/assignments/Starter/tetris-dual.html),
    where pieces can rise as well as fall. This is where the agent broke
    down.
  - [Airport weather vs flight delays](https://cs.brown.edu/courses/csci1970kf/agentic-spr-2026/assignments/AirportWeather/version1.html),
    using pandas and pytest.
  - A degree-requirements checker, a music tour planner and a chat client.
- Every project includes:
  - a `TESTING.md` and the tests, framed as "how am I demonstrating to
    someone else that my program is sufficiently robust for them to trust?";
  - AI chat transcripts handed in with the work;
  - a research journal;
  - peer review of code and transcripts in art-school-style "crits";
  - auditing each other's tests.
- Readings included Norman's *Some Observations on Mental Models*,
  Hmelo-Silver on Structure–Behaviour–Function,
  [Simon Willison's predictions for 2026](https://simonwillison.net/2026/Jan/8/llm-predictions-for-2026/),
  and [a post on writing AGENTS.md files](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/).
- Findings, from the news article and the paper:
  - agents produce working code quickly but miss context, and the code is
    often hard to extend;
  - students concluded the human must understand the whole system;
  - having to explain and defend their work showed who understood it.

### CSCI 0111-E: Data-Centric Intro to Computing and Coding Agents (Fall 2026, running now)

- Course site: <https://cs.brown.edu/courses/csci0111e/fall26/>
- Course design rationale: <https://cs.brown.edu/courses/csci0111e/fall26/course-design.html>
- Catalogue entry: <https://cs.brown.edu/courses/info/csci0111-e/>

Notes on the course:

- Taught by Fisler to real novices with no prior programming, using Pyret and
  Python. It's the closest existing example of the CACM paper's moderate
  version.
- **The reasoning:**
  - novices can now build systems that affect other people, so they need to
    learn to use agents responsibly;
  - building things by hand is how students form mental models of what
    programs can and can't do;
  - agents are "seductive", so activities and incentives need to steer when
    students use them.
- **The cycle for each design challenge:** specify structure, behaviour and
  tests → discuss with peers → use AI to create, check or audit. Within that,
  sometimes students build by hand, sometimes a human and the AI build the
  same thing in parallel for comparison, and sometimes the AI offers several
  proposals for students to evaluate.
- **AI is introduced in stages.** The first two months use chat LLMs only,
  which don't check their own work. Agents, which run and revise their own
  code, come in the final month.
- **Assessment:** design and programming assignments, one quiz, two exams,
  **oral reviews**, and journals about working with agents.
- No results yet, since it's mid-term.

### PICK: checking AI output with humans in the loop (ECOOP 2026)

- Paper: <https://cs.brown.edu/people/sk/Publications/Papers/Published/pafk-pick/>
- Blog, "Human Judgment as a Specification" (Jun 2026): <https://blog.brownplt.org/2026/06/09/pick.html>
- Blog, "LLMs ⭢ Regular Expressions, Responsibly!" (Dec 2025): <https://blog.brownplt.org/2025/12/11/pick-regex.html>

Notes:

- When an LLM turns prose into a spec or program, any mistake, ambiguity or
  misconception in the prose passes straight through. A second LLM doesn't
  catch it, because models share training data and misconceptions.
- Human oversight must be **meaningful** (real judgements, not
  rubber-stamping) and **moderate** (only a few questions).
- The method generates several candidates and shows the user concrete inputs
  where they disagree to accept or reject. It ends with one candidate, or
  with none, which means the AI output wasn't safe to use.
- They recommend users **predict before they look**: decide what you expect
  before seeing the output.
- Relevance to FoCS: this is the same idea as Examplar's wheats and chaffs.
  Candidate AI outputs can serve as chaffs.

### Porpoise (SPLASH-E 2025)

- Paper: <https://cs.brown.edu/people/sk/Publications/Papers/Published/ktv-porpoise/>

Students write purpose statements, an LLM generates code from them, and the
code is tested. This turns specification into something students can
practise, and introduces prompting in a controlled way. It was deployed at
two universities, with results described as "somewhat positive but mixed".

---

## Other groups

### Courses

These were checked on 2026-10-16, mostly against live Fall 2026 course pages,
which can change.

**Berkeley CS61A (DeNero and others): the closest match to FoCS**

- [What's new for Fall 2026](https://cs61a.org/fa26/articles/whats-new/):
  - Scheme is replaced by **Gleam** (statically typed, with algebraic data
    types and pattern matching) for the functional programming and
    interpreter unit. The page says this prepares students for Rust and
    OCaml.
  - There is a new **2-week unit on designing applications with AI agents**,
    because developer effort has shifted "from hand-authoring programs to
    architecting, describing, reading, and verifying them".
  - The rest stays hand-written: "writing programs by hand is a proven way to
    build this knowledge".
- [Syllabus](https://cs61a.org/fa26/syllabus/):
  - "Do not use AI tools … to fill in or correct your code."
  - Exams are 160 of 300 points and homework only 10. One midterm is taken in
    a computer-based testing facility, and there are proctored quizzes in
    lab.
  - **Preceptor** is an AI tutor that "asks students questions to ensure they
    understand the code that they have written". A student who fails its
    questions explains their code to staff instead.
  - A **Provenance** VS Code extension records how take-home work was
    written.
- Earlier evidence: [61A-Bot](https://arxiv.org/abs/2406.05600) (SIGCSE TS
  2025): GPT-4 hints given through the autograder to more than 2,000
  students. Fewer forum questions, and 30+ minutes saved per assignment for
  mid-range students. It measured time saved, not learning.

**Princeton**

- **COS326 Functional Programming (Walker, OCaml + Lean), Fall 2026:**
  [course page](https://www.cs.princeton.edu/courses/archive/fall26/cos326/),
  [policy](https://www.cs.princeton.edu/courses/archive/fall26/cos326/info.php).
  - The course page opens with: "In the world of large language models and AI
    coding agents, it is easier than ever to generate code". The course is
    re-centred on **specification, property-based testing and proofs in
    Lean**.
  - LLMs are allowed on assignments if disclosed, though discouraged on some.
    They are banned in tests and debriefs.
  - Two in-class tests are worth 35%, and the final project report plus
    debrief 20%.
  - **The most direct OCaml precedent.**
- **COS126, Fall 2026:**
  [syllabus](https://www.cs.princeton.edu/courses/archive/fall26/cos126/syllabus).
  A total ban on GenAI in graded work. Exams are 60%. Programming marks are
  split into code testing (18%) and code reviews (12%).

**Harvard**

- **CS50 (Malan):**
  [Fall 2026 syllabus](https://cs50.harvard.edu/college/2026/fall/syllabus/).
  - Only CS50's own Duck ([cs50.ai](https://cs50.ai)) may be used, except on
    the final project. Quizzes in lectures are worth 45%.
  - [SIGCSE 2024, "Teaching CS50 with AI"](https://cs.harvard.edu/malan/publications/V1fp0567-liu.pdf)
    ([DOI](https://doi.org/10.1145/3626252.3630938)): the rollout in Summer
    and Fall 2023, using GPT-4 with "pedagogical guardrails" and retrieval over
    lecture captions. **The evidence is surveys and usage logs, with no measure
    of learning.**
    - Fall 2023 surveys of about 500 on-campus students: 47% found the tools
      "very helpful" and 6% "not helpful". At the end of term 78% used them
      "frequently" or "constantly", and 86% "liked" or "loved" them.
    - Accuracy, checked by one staff member: 88% (22/25) of the Duck's
      curricular answers on the Ed forum were correct in Summer 2023. In
      Fall 2023 staff endorsed only 39% (70/180), which the authors think
      understates accuracy.
    - **Students stopped asking humans on the forum:** 0.89 questions per
      student in Fall 2022 against 0.28 in Fall 2023.
  - [SIGCSE 2025, "Improving AI in CS50"](https://cs.harvard.edu/malan/publications/fp0627-liu.pdf)
    ([DOI](https://doi.org/10.1145/3641554.3701945)): about the tutor's
    behaviour, not about students.
    - **The Duck gives away code despite its instructions.** Of 10 million
      messages, 22% contained code blocks, and 48% of conversations did.
      Switching from GPT-4 to GPT-4o raised the message rate from 20% to 25%.
      They call this "instruction dilution": long system prompts get ignored.
    - TFs compared the existing prompt with one that asks leading questions.
      Overall they were split. TFs who had taught before the Duck preferred the
      Socratic version more often.
    - In Fall 2024, 72 TFs judged multi-turn conversations. Versions with
      few-shot examples or fine-tuning on **just 50 curated tutor
      conversations** beat the original about 60% of the time.
    - The conclusion's claim that the tools "significantly enhanced student
      learning" isn't backed by any learning measure in either paper.
  - [Harvard Gazette, Sep 2026](https://news.harvard.edu/gazette/story/2026/09/taming-the-duck-for-starters/):
    Malan calls the Duck a "net positive". It sometimes emitted code anyway,
    a rate limit was added, and office-hour queues have largely disappeared.
- **CS51 (OCaml):**
  [GenAI policy](https://cs51.io/handouts/generative-ai-policy/).
  Conceptual "why" questions to an LLM are fine. Solutions, debugging your own
  problem set, and exam answers are not. "When in doubt … it's undoubtedly
  bad."

**UC San Diego (Porter, Zingaro, Alvarado): CS1 built around LLMs**

- Course design: <https://arxiv.org/abs/2406.15379> (2024).
- Outcomes: <https://arxiv.org/abs/2510.18806> (Oct 2025).
  - Exam results, including gaps between demographic groups, were "largely
    similar" to offerings without LLMs.
  - Large open-ended projects looked especially valuable.
  - Students worried about relying on the tools too much.
- [Porter's publications](https://leoporter.ucsd.edu/publications/) include
  more 2025–26 papers, on guardrails, vibe coding and non-native English
  speakers. Also the book *Learn AI-Assisted Python Programming* (Manning).
- The evidence is "no worse on exams", not a learning gain.

**CMU**

- **15-150 Functional Programming:**
  [policy](https://www.cs.cmu.edu/~15150/policy.html). A total ban on GenAI in
  graded work. Exams are 60%, and you "cannot pass" if you do badly on all of
  them.
- **15-112:** [syllabus](https://www.cs.cmu.edu/~112/syllabus.html). The
  opposite approach:
  - "AI use is allowed and even encouraged" on homework, labs and projects,
    and forbidden on assessments.
  - Weekly proctored, pass/fail **"competencies"** need about 90% and can be
    retaken. All of them must be passed.
  - Quizzes and exams are about 70%. "You cannot pass the course if you
    over-rely on AI."

**MIT**

- **6.101:** [academic integrity](https://py.mit.edu/fall26/info/academic_integrity),
  [grading](https://py.mit.edu/fall26/info/grading).
  - AI is forbidden for the weekly programming assignments.
  - **No assignment earns credit without a checkoff with staff**, and there
    are minimum exam grades.
- [The Tech, Nov 2025](https://www.thetech.com/2025/11/25/course-6-ai)
  (news). It reports that one course gives a third of each problem-set grade
  to checkoff interviews, and another has dropped problem sets to 5% with
  exams at 95%.

**John Regehr (Utah)**

- ["Zero Degrees-of-Freedom Programming"](https://john.regehr.org/writing/zero_dof_programming.html)
  (Mar 2026). The CACM paper cites it.
  - Agents do well only when executable checks (tests, fuzzers, sanitisers,
    analysers) remove "the freedom to do the job badly".
  - Architecture, duplication and security can't be checked that way, and
    need human judgement.
  - Testing is "a creative activity, not a mindless pinning down of
    input->output mappings".

**Nothing substantive found**

- Stanford CS106A has only a 2024
  [report of a ban](https://stanforddaily.com/2024/04/04/instructors-generate-different-approaches-to-ai/).
- Cornell CS3110 (OCaml): the course page was inaccessible and no policy was
  found.
- Nothing found for Northeastern/HtDP, or for Edinburgh, Imperial, Oxford,
  ETH, Delft or Aalto intro courses.
- Background: Lau & Guo, ["From 'Ban It Till We Understand It' to 'Resistance
  is Futile'"](https://pg.ucsd.edu/publications/cs-instructors-adapting-to-chatgpt-copilot-ai-tools_ICER-2023.pdf)
  (ICER 2023, [DOI](https://doi.org/10.1145/3568813.3600138)). Interviews
  with 20 intro programming instructors in 9 countries, in early 2023. It's a
  snapshot from before anyone had a plan, now mostly of historical interest.
  - **All 20 raised cheating unprompted.** 14 of 20 were already changing
    their courses that term: giving exams more weight (7), adding bans (4), or
    showing students where the tools fail (3).
  - Over the longer term they split two ways:
    - *Resist:* teach the fundamentals first (the calculator and hand-tools
      analogies, and "fragile knowledge"). Ideas included bespoke starter code
      to make assignments "AI-proof", paper exams, oral or video explanations
      of code, and grading the process.
    - *Embrace:* prepare students for jobs, cover more design in CS1, and
      **shift towards reading, critiquing and testing code** ("good editors
      rather than just writers"). Also open-ended projects, and students
      working with AI as "clients".
  - Some who banned AI in CS1 wanted it in upper-year courses.
  - Their open questions include moving beyond autograded assignments,
    efficacy studies, and IDEs designed to encourage critique over
    generation.

### Computing-education researchers

**Denny, Prather, Leinonen, Luxton-Reilly, Hellas (Auckland, ACU, Aalto)**

(Brett Becker, a long-time collaborator, died in September 2024.)

- **"The Widening Gap"** (Prather et al., ICER 2024):
  <https://doi.org/10.1145/3632620.3671116>, [arXiv](https://arxiv.org/abs/2405.17739).
  - Qualitative: 21 lab sessions with observation, eye tracking and
    interviews.
  - Students who already had a plan used GenAI to go faster and ignored bad
    suggestions.
  - Students who were struggling had their difficulties made worse, and
    picked up new ones.
  - This is the main source for "weaker students are hurt more".
- **Dagstuhl Seminar 25311, "GenAI in Programming Education"** (Jul–Aug 2025;
  Dagstuhl Reports 15(7), 2026): <https://doi.org/10.4230/DagRep.15.7.253>.
  It records the opinions of 42 experts and is not an empirical study.
  - The model of "many small autograded programs" is "likely rendered
    obsolete".
  - GenAI may remove the "desirable difficulties" that make learning stick,
    and create an "illusion of competence".
  - The student is the author and is responsible for whatever the tool
    produces. AI does the low-level code; the time saved goes to design,
    quality and ethics. (Luxton-Reilly, Porter, Zingaro, Wermelinger.)
  - **Luxton-Reilly's "two-lane" assessment:** *secure* assessments ban AI and
    measure what students can do unaided; *insecure* ones allow AI and are
    graded as the student's work.
  - **Brabrand:** we define programming too narrowly as coding, which makes it
    look easy to outsource. Specification, analysis and evaluation are
    neglected, and almost unstudied.
  - **Keuning:** that AI integration is "inevitable" is a myth.
  - **MacNeil** (ITiCSE 2025, 17 interviews,
    <https://doi.org/10.1145/3724363.3729024>): students ask GenAI instead of
    each other, so **peer learning suffers**. This is relevant to
    supervisions.
  - **Chen et al.** (L@S 2024, <https://doi.org/10.1145/3657604.3662046>):
    signs of plagiarism in homework predicted lower scores on a proctored
    final, even after controlling for an earlier exam.
- **"Beyond the Hype"** (ITiCSE 2024 working-group report, published 2025):
  <https://doi.org/10.1145/3689187.3709614>, [arXiv](https://arxiv.org/abs/2412.14732).
  It combines a systematic review of 71 papers up to May 2024, a survey of 76
  educators and 39 developers, and 17 interviews with tool builders and
  educators. It describes practice rather than measuring learning, and the
  data are from 2024. What matters for CS1:
  - **Most studies are of unsupervised use**, such as homework, and most
    gave students ChatGPT with no instruction on how to use it (49 of 70).
    The authors flag likely publication bias towards positive results.
  - **Guidance or guardrails both help.** With a general tool and no guidance,
    55% (12/22) of studies reported positive results; with a guardrailed
    custom tool and no guidance, 73% (19/26). Hence the main recommendation:
    either teach students how to use general tools, or give them course tools
    with pedagogical guardrails.
  - Studies using AI to help **understand code** were more often positive than
    those using it for hints or writing code.
  - **Educators are moving marks to invigilated work.** 77% think the skills
    needed to write software have changed, but only 36% have changed their
    course to include GenAI, and 22% ban it. The open-ended answers describe
    more proctored quizzes, paper exams, **oral exams** ("now a vital part of
    student assessment"), exam minimums, and marking the process rather than
    the final code.
  - **Skills they expect to matter more:** problem understanding, reading code
    and problem decomposition were ranked top. Testing and debugging rise too.
    Developers added critically evaluating AI output, and meticulousness.
  - Educators who ban GenAI give two reasons: they don't know the tools well
    enough, and students should learn the basics unaided first. The report says
    whether that is pedagogically sound is an open question.
  - From the interviews: more cheating and **students arriving unprepared for
    exams**, but responsible users "accomplish more than traditionally
    possible". Students like being able to ask questions without peers seeing.
  - Equity: paid tools cost about $1,000 over a degree.
- **Prompt Problems:** students write a prompt, which counts as correct when
  the generated code passes the tests. This trains specification rather than
  coding. Evidence is from small deployments and is mostly about student
  perceptions.
  [SIGCSE 2024](https://sigcse2024.sigcse.org/details/sigcse-ts-2024-Papers-1/63/Prompt-Problems-A-New-Programming-Exercise-for-the-Generative-AI-Era),
  [Promptly](https://arxiv.org/abs/2307.16364) (n=54, CS1).
- Earlier position piece: Denny et al., "Computing Education in the Era of
  Generative AI", CACM, Feb 2024: <https://arxiv.org/abs/2306.02608>.

**Grading code reading with an LLM: Smith & Zilles (Illinois, SIGCSE 2024)**

<https://arxiv.org/abs/2311.14903>. Students answer "Explain in Plain English"
questions. The explanation goes to an LLM, and the code it generates is run
against tests. Agreement with human graders was moderate, and it was too
lenient on line-by-line descriptions. It's a usable way to autograde code
comprehension, a skill that FoCS barely assesses.

**Amy J. Ko (UW)**

2026 Wesleyan talk, "A Means to Know End":
<https://faculty.washington.edu/ajko/slides/Wesleyan2026MeansToKnowEnd.pdf>

- She is strongly critical on political-economy and equity grounds.
- On learning she is moderate: delegating to AI means less learning, while
  scaffolded, intentional use can mean more.
- Her lab finds students turn to AI to avoid shame in competitive,
  transactional courses.
- She uses AI to code herself, but "read[s] every line it writes".

**Felienne Hermans (VU Amsterdam)**

All opinion; no empirical work on AI.

- [VU interview](https://vu.nl/nl/verhalen/felienne-hermans-over-menselijk-onderwijs-in-tijden-van-ai):
  ask whether AI is desirable before adopting it. She warns about deskilling,
  and says to teach factual knowledge first so students can catch AI's
  errors.
- [Talk, "AI made me doubt everything about programming"](https://2026.dddeurope.com/program/ai-made-me-doubt-everything-about-programming/)
  (DDD Europe 2026).

**Mark Guzdial (Michigan)**

All opinion.

- ["GenAI as automobile for the mind, and exercise as the antidote"](https://computinged.wordpress.com/2026/02/16/genai-as-automobile-for-the-mind-and-exercise-as-the-antidote-a-metaphor-for-predicting-genais-impact/)
  (Feb 2026): GenAI is "outsourcing", not offloading. He expects skills to
  atrophy unless people deliberately exercise them, and predicts specialised
  learning tools will beat chat interfaces.

### Studies of how AI affects learning

| Study | Setting | Finding |
|---|---|---|
| [Anthropic, Shen & Tamkin](https://www.anthropic.com/research/AI-assistance-coding-skills) ([arXiv](https://arxiv.org/abs/2601.20245)), Jan 2026 | RCT, n=52 mostly junior developers learning an unfamiliar library (Trio) | Quiz score 50% with AI vs 67% by hand (d=0.74). The biggest gap was **debugging**. The speed-up wasn't significant. People who only asked conceptual questions scored ≥65%, people who delegated <40%; that last comparison is correlational. |
| [Bastani et al., PNAS 2025](https://ideas.repec.org/a/nas/journl/v122y2025pe2422633122.html) ([SSRN](https://papers.ssrn.com/abstract=4895486)) | Field RCT, about 1,000 high-school maths students | Unrestricted GPT-4: practice +48%, unaided exam −17%. A **hint-only tutor with guardrails** mostly removed the harm. |
| [Lehmann, Cornelius & Sting](https://arxiv.org/abs/2409.09047) (preprint) | Pre-registered lab experiments plus a field study, coding classes | No net effect overall. Using it as a tutor helped and using it to solve the work hurt. Students thought they had learned more than they had. |
| [Kazemitabaar et al., CHI 2023](https://doi.org/10.1145/3544548.3580919) | n=69, ages 10–17, Codex | No harm to retention after a week, and more benefit for those with more prior knowledge. The main counterweight to the harm results. |
| [Fan et al., BJET 2025](https://doi.org/10.1111/bjet.13544) | n=117, essay writing | Better essays but no gain in knowledge or transfer, and less metacognition ("metacognitive laziness"). |
| [Lee, Sarkar et al., CHI 2025](https://doi.org/10.1145/3706598.3713778) | Survey of 319 knowledge workers | More trust in GenAI went with less critical thinking. Effort shifts to checking output. Self-reported and correlational. |
| [Liffiton, CodeHelp](https://doi.org/10.1145/3631802.3631830) ([usage study](https://arxiv.org/abs/2310.16984)) | A guardrailed assistant that won't give out code, about 50 students | Mostly perceptions; no outcome RCT. |
| [Harms review, Koli 2025](https://arxiv.org/abs/2510.04443) | 224 papers | Calls for more rigorous evidence. |

**Specific to OCaml:** Zhang, Pientka & Si (McGill), *Programming* 2026,
<https://arxiv.org/abs/2603.05646>. Nine LLMs were tested on a functional
programming course in OCaml: homework, fixing students' syntax, type and
logic errors, and concept questions. The top models handled every kind of
task, but solved far fewer homework problems than in intro Python or Java
courses. They were best at syntax and type errors. **OCaml gives only limited
protection.**

### Professional bodies and Cambridge

- **ACM SIGCSE:** no official position on GenAI found.
- **CS2023 curriculum:** has no real GenAI guidance. A
  [SIGCSE TS 2026 special session](https://sigcse2026.sigcse.org/details/sigcse-ts-2026-special-sessions/1/Computer-Science-Curricula-CS2023-Revisited-in-Light-of-Generative-AI-)
  revisited it, with no recommendations published yet.
- **CPHC (UK heads of computing):**
  [Strategy 2030](https://cphc.ac.uk/vision-strategy/) makes AI in
  curriculum and assessment a priority. There is also a
  [ChatGPT in Computing Education white paper](https://advance-he.org/knowledge-hub/chatgpt-in-computing-education/)
  from 2023.
- **BCS and Royal Society:** material for schools only.
- **Cambridge's own guidance (the rules we have to work within):**
  - [GenAI and education](https://blendedlearning.cam.ac.uk/artificial-intelligence-and-education/generative-ai-and-education):
    appropriate use is broadly allowed, departments and colleges set local
    rules, and **examiners must not upload student work to GenAI**.
  - [GenAI and assessment](https://blendedlearning.cam.ac.uk/artificial-intelligence-and-education/generative-ai-and-assessment):
    unacknowledged AI content in summative work is misconduct unless the
    brief says otherwise. Don't use AI detectors; require declarations
    instead.
  - [Undergraduate supervisor guidance on the use of AI](https://www.seniortutors.admin.cam.ac.uk/files/supervisor_ai_guidance.pdf)
    (Senior Tutors' Committee, approved 16 Feb 2024). The link from the
    [GenAI and education](https://blendedlearning.cam.ac.uk/artificial-intelligence-and-education/generative-ai-and-education)
    page now returns 404, so this was read from the
    [Wayback copy of June 2025](http://web.archive.org/web/20250601200740/https://www.seniortutors.admin.cam.ac.uk/files/supervisor_ai_guidance.pdf).
    There is also a Raven-only SharePoint copy (UoC_SupportingSupervisions),
    *not checked, and it may be newer*. The guidance:
    - **"Supervisors should not prohibit the use of AI in work produced for
      supervisions but require students to clearly state when AI has been
      utilised."**
    - Using AI output "indiscriminately or inappropriately" counts as
      misconduct. Allowed uses include explaining new concepts, acting as "a
      collaborative coach to problem solve", and self-testing.
    - It warns that "extensive use can limit a student's ability to learn and
      make them unprepared for formal assessments".
    - Don't rely on AI detectors.
    - Supervisors should engage students on how to use AI well, partly so
      they see its flaws.
    - Schools, departments and colleges may vary it locally.
  - **The department's own [AI policy](https://www.cst.cam.ac.uk/files/ai_policy.pdf)**
    (Faculty Board, 15 Oct 2024), for assessed work, **ticks included**:
    - AI is not allowed in exams unless explicitly permitted.
    - Local tools such as spell-checkers, grammar assistants and debugging aids
      are allowed without declaring them. Beyond that, AI output must not be
      presented as the student's own, "either taken directly or paraphrased",
      unless the syllabus page explicitly allows it. Ticks need a signed
      honesty-code cover sheet.
    - Using AI for background research and understanding is always allowed.
    - Unlike the University's advice, it says **examiners may use AI-detection
      software**, and a suspected case may lead to a viva.
    - So the FoCS syllabus page is where any permitted use on ticks would have
      to be stated. Supervision work isn't assessed, so the supervisor
      guidance above applies to it.

---

## Recurring themes

1. **Marks are moving to supervised assessment.** Exams and quizzes now make
   up 53–70%+ of the grade at CS61A, CS50, CMU, Princeton and MIT, and
   take-home work counts for little. Luxton-Reilly's "two lanes" puts it
   neatly: AI is banned where you need to know what students can do unaided,
   and allowed elsewhere. FoCS already has the unaided lane, in the paper
   exam.
2. **Students must explain their own code.** Examples: MIT's checkoffs,
   COS326's debriefs, CS61A's Preceptor with staff as fallback. Cambridge
   supervisions already provide this, if supervisors are asked to use them
   that way. University guidance already says supervisors shouldn't ban AI in
   supervision work but should require students to declare it.
3. **How students use AI matters more than whether they have access.**
   Delegating hurts learning, especially debugging (Anthropic RCT) and exam
   performance (Bastani). Asking for explanations, or using tutors with
   guardrails, largely doesn't hurt. Course-owned tutors (CS50's Duck,
   CS61A's Preceptor, CodeHelp) follow this logic. "Beyond the Hype" finds
   the same: studies with guidance or guardrails were more often positive.
   But guardrails leak: 22% of the CS50 Duck's messages contained code.
4. **Weaker students are at more risk** ("The Widening Gap", Dagstuhl). The
   evidence is mixed (Kazemitabaar), but the direction is consistent.
5. **Specification, testing, reading and evaluating code matter more**, and
   are under-researched. Brown's CACM paper, Brabrand at Dagstuhl, Prompt
   Problems, COS326's turn to specification and proofs, Regehr's oracles, and
   Princeton COS126's marks for code testing and review all point this way.
6. **Functional and typed courses are leaning into types and verification**:
   COS326 (OCaml + Lean), CS61A moving to Gleam. Being in OCaml no longer
   protects a course: the top LLMs handle a typical OCaml course (McGill,
   2026).
7. **Agent-based coding is being added as a bounded unit late in the
   course** (CS61A's 2 weeks, CS50's final project, Brown 0111-E's last
   month), rather than woven throughout.
8. **Policies fall into three camps:** total bans (CMU 15-150, COS126, MIT
   6.101); permissive coursework with strict assessment (CMU 15-112, COS326);
   and course-owned AI tools only (CS50, CS61A).
9. **Peer learning is at risk**: students ask AI instead of each other
   (MacNeil). That argues for protecting supervisions.
10. **The evidence is thin.** It shows time saved, staff workload relieved,
    and "no worse on exams". No study yet shows better learning from AI in a
    first programming course.

## Gaps in these notes

- Now read first-hand (2026-10-16): "Beyond the Hype", both CS50 papers,
  Lau & Guo 2023, the University's supervisor guidance (Feb 2024, via the
  Wayback Machine) and the department's AI policy (Oct 2024).
- Still open:
  - Whether the supervisor guidance has been updated since Feb 2024. The live
    link is dead, and the SharePoint copy needs Raven.
  - Whether the department's tick rules have changed since Oct 2024.
  - CS50 has published nothing that measures learning (as opposed to
    satisfaction or tutor behaviour). Its later papers haven't been searched
    for.
  - "Beyond the Hype" covers the literature only up to May 2024. A newer
    systematic review would be worth finding.
- Brown 0111-E (Fall 2026) and CS61A's agents unit are running now, so their
  results are worth watching for.
