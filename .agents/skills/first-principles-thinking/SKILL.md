---
name: first-principles-thinking
description: Collaborative first-principles problem solving for software architecture, technical strategy, product design, cost reduction, and blocked decisions. Use when the user wants Elon Musk-style reasoning from fundamentals, assumption teardown, Socratic questioning, root-cause decomposition, or rebuilding a solution from ground truth instead of copying existing patterns.
---

# First Principles Thinking

Run a rigorous partner session. Do not roleplay Elon Musk; apply the method.

## Operating Rules

- Start with one crisp problem statement and success metric. If missing, ask for them.
- Prefer questions over conclusions until the fundamentals are explicit.
- Ask one question at a time when the user's answer is required.
- Separate facts, constraints, assumptions, preferences, inherited patterns, and unknowns.
- Treat "best practice", "industry standard", "we always", and competitor patterns as suspect until justified.
- Optimize for function and causal mechanism, not current form.
- Expose concise rationale, evidence gaps, and why each assumption is accepted or rejected.

## Workflow

1. Frame: restate the problem, desired outcome, hard constraints, and decision owner.
2. Assumption dump: list every belief driving the current solution or architecture.
3. Truth test: mark each item as `known fact`, `law/constraint`, `assumption`, `preference`, or `unknown`; ask for evidence on weak items.
4. Decompose: ask "why?" and "what must be true?" until the core user need, data flow, economics, security requirement, or business invariant cannot be reduced usefully.
5. Rebuild: create 2-4 options from fundamentals, including one that ignores current architecture or market convention.
6. Stress: test each option with inversion, failure modes, cost, latency, complexity, reversibility, and operational burden.
7. Decide: recommend the smallest coherent solution that satisfies the fundamentals; name tradeoffs and what to validate next.

## Question Bank

- What outcome are we actually buying? What current form are we over-attached to?
- Which constraint is real, measured, legal, or physical? Which is only historical?
- If we deleted the current implementation, what would still have to exist?
- What is the irreducible unit: user job, transaction, state transition, data contract, cost driver, or risk?
- What cheaper or simpler primitive could replace an expensive abstraction?
- What would make this solution fail even if the architecture looks elegant?
- What experiment would falsify the leading assumption fastest?

## Output Shape

Use concise sections: `Problem`, `Ground Truths`, `Rejected Assumptions`, `Rebuilt Options`, `Recommendation`, `Validation`. Include a short analogy-vs-first-principles contrast only when it clarifies the decision.
