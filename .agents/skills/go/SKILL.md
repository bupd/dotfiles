---
name: go-idiomatic
description: >
  Write idiomatic, production-grade Go code following Google's Go Style Guide.
  Use when writing, reviewing, or refactoring any Go (.go) code including
  libraries, CLI tools, servers, and tests. Triggers: any Go code generation,
  "write Go", "Go function", "Go package", "Go test", "refactor Go",
  "review Go code", "fix Go style", "idiomatic Go", or producing .go files.
  Do NOT use for non-Go languages.
---

# Idiomatic Go

Write Go code that is clear, simple, concise, and maintainable — in that priority order.
Based on Google's Go Style Guide.

## Core Workflow

When writing Go code, apply these principles in order:

1. **Clarity first** — purpose and rationale obvious to the reader
2. **Simplicity** — accomplish the goal the simplest way
3. **Concision** — high signal-to-noise ratio
4. **Maintainability** — easy to evolve
5. **Consistency** — match surrounding code and Go conventions

## Quick Reference

### Naming

- Short, clear names; shorter in smaller scopes, descriptive in larger ones
- `MixedCaps` / `mixedCaps`, never `snake_case`
- Don't repeat package name: `yamlconfig.Parse()` not `yamlconfig.ParseYAMLConfig()`
- Don't repeat receiver: `c.WriteTo()` not `c.WriteConfigTo()`
- No `Get` prefix on getters: `c.JobName()` not `c.GetJobName()`
- Functions returning values → noun-like; functions doing things → verb-like
- Avoid `util`, `helper`, `common` package names
- Interfaces: single-method → method name + `er` suffix (`Reader`, `Stringer`)

### Error Handling

- Always handle errors explicitly; never ignore with `_` unless truly intentional
- Use structured errors (`errors.New`, custom types) over string matching
- Wrap with `fmt.Errorf("context: %w", err)` to preserve chain; `%v` at API boundaries
- Place `%w` at the end of format strings
- Add non-redundant context; don't duplicate info the underlying error already provides
- Don't wrap with "failed:" — the error itself conveys failure
- Use `errors.Is` / `errors.As` for checking; never `regexp` on `.Error()`

### Types

- Use `any` instead of `interface{}`; e.g. `map[string]any` not `map[string]interface{}`

### Variable Declarations

- `:=` for non-zero initialization: `i := 42`
- `var` for zero values ready for later use: `var coords Point`
- Composite literals for known initial values: `primes := []int{2, 3, 5}`
- `new(T)` or `&T{}` for pointer zero values
- Specify channel direction: `func sum(values <-chan int) int`

### Function Design

- Keep signatures short; if growing complex, use an option struct or functional options
- `context.Context` is always the first parameter, never in option structs
- Option struct: when most callers set multiple fields
- Variadic options `...Option`: when most callers need zero options

### Testing

- Table-driven tests with named fields for readability
- Use `t.Helper()` in test helpers
- Prefer `cmp.Diff` for comparisons over manual field checks
- `t.Fatal` only in setup/preconditions, `t.Error` for test assertions
- Never call `t.Fatal` from goroutines
- Scope setup to tests that need it; avoid package-level `init()`
- Test packages: append `test` to package name (`creditcardtest`)

### Documentation

- Every exported name gets a doc comment starting with the name
- Don't document the obvious (parameter types, context cancellation)
- Do document non-obvious behavior, concurrency safety of mutating ops, cleanup requirements, and error types returned
- Runnable `Example` functions over code-in-comments

### Imports

- Group: stdlib, then third-party, then internal (blank line between groups)
- Rename proto imports with `pb` / `grpc` suffix: `foopb "path/to/foo_go_proto"`

## Detailed Guidance

For pattern-specific examples and anti-patterns, consult these references:

- **Naming & package design**: See [references/naming.md](references/naming.md)
- **Error handling patterns**: See [references/errors.md](references/errors.md)
- **Testing patterns**: See [references/testing.md](references/testing.md)
- **API design (options, concurrency, globals)**: See [references/api-design.md](references/api-design.md)
