# Error Handling Patterns

## Table of Contents
- Structured errors
- Adding context with %v vs %w
- Placement of %w
- Error logging
- Program initialization and panics

## Structured Errors

Give errors structure so callers can programmatically inspect them.

### Sentinel errors for simple cases

```go
var (
    ErrDuplicate = errors.New("duplicate")
    ErrMarsupial = errors.New("marsupials are not supported")
)

func process(animal Animal) error {
    switch {
    case seen[animal]:
        return ErrDuplicate
    case marsupial(animal):
        return ErrMarsupial
    }
    seen[animal] = true
    return nil
}
```

Callers use `errors.Is` (supports wrapped errors):

```go
// GOOD
switch err := process(an); {
case errors.Is(err, ErrDuplicate):
    return fmt.Errorf("feed %q: %v", an, err)
case errors.Is(err, ErrMarsupial):
    alternate = an.BackupAnimal()
    return handlePet(..., alternate, ...)
}

// BAD: string matching
if regexp.MatchString(`duplicate`, err.Error()) { ... }
```

### Custom error types for extra info

```go
type PathError struct {
    Op   string
    Path string
    Err  error
}
```

## Adding Context: %v vs %w

### Use %v at API boundaries — creates a new error, hides internals

```go
// GOOD: RPC boundary — client doesn't need internal error details
func (*FortuneTeller) SuggestFortune(ctx context.Context, req *pb.SuggestionRequest) (*pb.SuggestionResponse, error) {
    if err != nil {
        return nil, fmt.Errorf("couldn't find fortune database: %v", err)
    }
}
```

### Use %w within your application — preserves error chain for inspection

```go
// GOOD: internal helper — caller may need to check underlying error
func (s *Server) internalFunction(ctx context.Context) error {
    if err != nil {
        return fmt.Errorf("couldn't find remote file: %w", err)
    }
}
// Caller can do: errors.Is(err, fs.ErrNotExist)
```

### Add non-redundant context

```go
// GOOD: adds meaning the underlying error doesn't have
if err := os.Open("settings.txt"); err != nil {
    return fmt.Errorf("launch codes unavailable: %v", err)
}
// Output: launch codes unavailable: open settings.txt: no such file or directory

// BAD: duplicates the file path
if err := os.Open("settings.txt"); err != nil {
    return fmt.Errorf("could not open settings.txt: %v", err)
}
// Output: could not open settings.txt: open settings.txt: no such file or directory

// BAD: adds nothing
return fmt.Errorf("failed: %v", err) // just return err
```

## Placement of %w

Always place `%w` at the end so printed output reads newest-to-oldest:

```go
// GOOD: prints in logical order
err1 := fmt.Errorf("err1")
err2 := fmt.Errorf("err2: %w", err1)
err3 := fmt.Errorf("err3: %w", err2)
fmt.Println(err3) // err3: err2: err1

// BAD: prints in reverse order
err2 := fmt.Errorf("%w: err2", err1)
err3 := fmt.Errorf("%w: err3", err2)
fmt.Println(err3) // err1: err2: err3
```

## Error Logging

- Don't log and return — let the caller decide
- Use `log.Error` sparingly (causes flush, expensive); prefer warning level
- ERROR level should be actionable
- Be careful with PII in logs
- Use verbose logging levels: `V(1)` small extra info, `V(2)` traces, `V(3)` large state dumps

```go
// GOOD: guard expensive calls
for _, sql := range queries {
    log.V(1).Infof("Handling %v", sql)
    if log.V(2) {
        log.Infof("Handling %v", sql.Explain())
    }
    sql.Run(...)
}

// BAD: sql.Explain() called even when log is off
log.V(2).Infof("Handling %v", sql.Explain())
```

## Program Initialization

Propagate init errors upward to `main`; use `log.Exit` with actionable messages:

```go
// GOOD: tells user how to fix the problem
func main() {
    cfg, err := loadConfig(*configPath)
    if err != nil {
        log.Exitf("Invalid config at %s: %v. See docs at ...", *configPath, err)
    }
}
```

Don't use `log.Fatal` for init errors — a stack trace pointing at a check is less helpful than a clear message.

## Panics

- Prefer `log.Fatal` over `panic` for invariant violations (panic can deadlock in defers)
- Never recover panics to avoid crashes — corrupted state propagates
- Acceptable to panic on API misuse (like `reflect` does)
- Acceptable as internal implementation detail with matching `recover` at package boundary:

```go
// GOOD: panic/recover contained within package
type syntaxError struct{ msg string }

func parseInt(in string) int {
    n, err := strconv.Atoi(in)
    if err != nil {
        panic(&syntaxError{"not a valid integer"})
    }
    return n
}

func Parse(in string) (_ *Node, err error) {
    defer func() {
        if p := recover(); p != nil {
            sErr, ok := p.(*syntaxError)
            if !ok {
                panic(p) // re-panic: not ours
            }
            err = fmt.Errorf("syntax error: %v", sErr.msg)
        }
    }()
    // ... uses parseInt internally
}
```

Key rule: **panics must never escape across package boundaries**.

Use `panic("unreachable")` after `log.Fatal` calls to satisfy the compiler:

```go
func answer(i int) string {
    switch i {
    case 42:
        return "yup"
    default:
        log.Fatalf("Sorry, %d is not the answer.", i)
        panic("unreachable")
    }
}
```
