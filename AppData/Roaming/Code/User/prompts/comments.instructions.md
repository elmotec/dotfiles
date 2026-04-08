---
description: 'Guidelines for GitHub Copilot to write comments to achieve self-explanatory code with less comments. Examples are in JavaScript but it should work on any language that has comments.'
applyTo: '**'
---

# Commenting Guidance

## Core Rule

- Prefer self-explanatory code.
- Add comments only when they explain intent or constraints that are not obvious from the code.

## Write Comments For

- Non-obvious business rules.
- Algorithm choices and trade-offs.
- External API constraints or known gotchas.
- Complex regex intent.

## Avoid Comments That

- Repeat what code already says.
- Describe trivial mechanics.
- Maintain changelog history in code.
- Leave commented-out dead code.

## Quick Check

Before adding a comment, ask:
1. Can naming/refactoring remove the need for this comment?
2. Does it explain why instead of what?
3. Will it still be true after small refactors?
