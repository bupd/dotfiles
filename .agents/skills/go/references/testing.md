# Testing Patterns

## Table of Contents
- Test function design
- Table-driven tests
- Test helpers vs assertion helpers
- t.Error vs t.Fatal
- Test setup scoping
- Modern testing APIs (Go 1.24+)
- Real transports
- Acceptance testing

## Test Function Design

Keep pass/fail logic inside the `Test` function. Don't push failure decisions into helpers.

Three approaches when many test cases need the same validation:

1. **Inline** — repeat the validation in `Test` (best for simple cases)
2. **Table-driven** — unify inputs into a table, loop with inline validation
3. **Return error** — validation function returns `error`, `Test` decides whether to fail

```go
// GOOD: validation returns a value, Test decides
func polygonCmp() cmp.Option {
    return cmp.Options{
        cmp.Transformer("polygon", func(p *s2.Polygon) []*s2.Loop { return p.Loops() }),
        cmp.Transformer("loop", func(l *s2.Loop) []s2.Point { return l.Vertices() }),
        cmpopts.EquateApprox(0.00000001, 0),
        cmpopts.EquateEmpty(),
    }
}

func TestFenceposts(t *testing.T) {
    got := Fencepost(tomsDiner, 1*meter)
    if diff := cmp.Diff(want, got, polygonCmp()); diff != "" {
        t.Errorf("Fencepost(tomsDiner, 1m) returned unexpected diff (-want+got):\n%v", diff)
    }
}
```

## Table-Driven Tests

Use named fields. Include `name` for subtests.

```go
func TestStrJoin(t *testing.T) {
    tests := []struct {
        name      string
        slice     []string
        separator string
        skipEmpty bool
        want      string
    }{
        {
            name:      "with empty element",
            slice:     []string{"a", "b", ""},
            separator: ",",
            want:      "a,b,",
        },
        {
            name:      "skip empty",
            slice:     []string{"a", "b", ""},
            separator: ",",
            skipEmpty: true,
            want:      "a,b",
        },
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := StrJoin(tt.slice, tt.separator, tt.skipEmpty)
            if got != tt.want {
                t.Errorf("StrJoin() = %q, want %q", got, tt.want)
            }
        })
    }
}
```

Since Go 1.22 loop variables are per-iteration: never write `tt := tt` before the
subtest closure, even with `t.Parallel()`.

## Test Helpers

Mark with `t.Helper()`. Use `t.Fatal` for setup failures (not test assertions).

```go
// GOOD: helper that fatals on setup failure
func mustAddGameAssets(t *testing.T, dir string) {
    t.Helper()
    if err := os.WriteFile(path.Join(dir, "pak0.pak"), pak0, 0644); err != nil {
        t.Fatalf("Setup failed: could not write pak0 asset: %v", err)
    }
}

// BAD: helper that returns error (clutters call site)
func addGameAssets(t *testing.T, dir string) error {
    // forces every caller to check err
}
```

Use `t.Cleanup` for teardown:

```go
func setupDatabase(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("postgres", testDSN)
    if err != nil {
        t.Fatalf("Could not open test database: %v", err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

## t.Error vs t.Fatal

- `t.Fatal`: setup failures, preconditions that prevent further testing
- `t.Error`: test assertions — keep going to find more failures
- In table tests without subtests: `t.Error` + `continue`
- In subtests: `t.Fatal` is ok (only ends that subtest)

**Never call `t.Fatal` from a goroutine:**

```go
// GOOD
func TestRevEngine(t *testing.T) {
    engine, err := Start()
    if err != nil {
        t.Fatalf("Engine failed to start: %v", err)
    }

    var wg sync.WaitGroup
    for range num {
        wg.Go(func() { // Go 1.25+; wg.Add(1)/defer wg.Done() on older versions
            if err := engine.Vroom(); err != nil {
                t.Errorf("No vroom left: %v", err) // NOT t.Fatal
            }
        })
    }
    wg.Wait()
}
```

## Test Setup Scoping

Scope setup to tests that need it. Don't penalize unrelated tests.

```go
// GOOD: only tests that need data call this
func TestParseData(t *testing.T) {
    data := mustLoadDataset(t)
    // ...
}

func TestRegression682831(t *testing.T) {
    // Doesn't need dataset — runs fast
    if got, want := guessOS("zpc79.example.com"), "grhat"; got != want {
        t.Errorf(`guessOS("zpc79.example.com") = %q, want %q`, got, want)
    }
}

// BAD: package-level init loads expensive data for ALL tests
var dataset []byte
func init() {
    dataset = mustLoadDataset()
}
```

### Amortize with sync.Once when setup is expensive, applies to some tests, and needs no teardown:

```go
var dataset struct {
    once sync.Once
    data []byte
    err  error
}

func mustLoadDataset(t *testing.T) []byte {
    t.Helper()
    dataset.once.Do(func() {
        dataset.data, dataset.err = os.ReadFile("testdata/dataset")
    })
    if err := dataset.err; err != nil {
        t.Fatalf("Could not load dataset: %v", err)
    }
    return dataset.data
}
```

### Custom TestMain only when ALL tests need shared setup with teardown:

```go
func TestMain(m *testing.M) {
    code, err := runMain(context.Background(), m)
    if err != nil {
        log.Fatal(err)
    }
    os.Exit(code)
}

func runMain(ctx context.Context, m *testing.M) (int, error) {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()

    d, err := setupDatabase(ctx)
    if err != nil {
        return 0, err
    }
    defer d.Close()
    db = d

    return m.Run(), nil
}
```

## Modern Testing APIs (Go 1.24+)

### Built-in fixtures — prefer over hand-rolled setup

```go
func TestServer(t *testing.T) {
    ctx := t.Context()      // canceled just before test cleanup runs (Go 1.24)
    dir := t.TempDir()      // auto-removed temp dir
    t.Chdir(dir)            // changes cwd, restores after test (Go 1.24)
    t.Setenv("MODE", "test") // restores after test; incompatible with t.Parallel
}
```

Use `t.Context()` instead of `context.Background()` in tests — it ties request
lifetimes to the test and catches goroutines that outlive it.

### Benchmarks: b.Loop, not b.N

```go
// GOOD (Go 1.24+): setup outside the loop is excluded from timing,
// and the compiler can't optimize the benchmarked call away
func BenchmarkParse(b *testing.B) {
    data := loadTestData(b)
    for b.Loop() {
        Parse(data)
    }
}

// OLD: for i := 0; i < b.N; i++ — needed manual b.ResetTimer and
// keepalive tricks to defeat dead-code elimination
```

### testing/synctest for concurrent, time-dependent code (Go 1.25)

Runs the test in a "bubble" with a fake clock: `time.Sleep` advances instantly
when all goroutines are blocked, making timeout/retry tests fast and deterministic.

```go
func TestCacheExpiry(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        c := NewCache(5 * time.Minute)
        c.Set("k", "v")
        time.Sleep(6 * time.Minute) // returns instantly, clock advanced
        if _, ok := c.Get("k"); ok {
            t.Error("entry should have expired")
        }
        synctest.Wait() // block until all bubble goroutines are idle
    })
}
```

### Test artifacts (Go 1.26)

`t.ArtifactDir()` returns a directory for output files that should outlive the
test (logs, dumps); persisted when running with `go test -artifacts`.

## Real Transports

Prefer real HTTP/RPC clients connected to test-double servers over hand-implementing client behavior:

```go
// GOOD: real client, test server
client := NewOperationsClient(testServer.Addr())

// BAD: hand-rolled client that may not match real behavior
client := &fakeOperationsClient{...}
```

## Acceptance Testing

For validating user implementations of your interfaces, return errors instead of taking `*testing.T`:

```go
// GOOD: acceptance test as library function
func ExercisePlayer(b *chess.Board, p chess.Player) error {
    // validate moves, return structured errors
}

// User's test
func TestAcceptance(t *testing.T) {
    player := deepblue.New()
    if err := chesstest.ExerciseGame(t, chesstest.SimpleGame, player); err != nil {
        t.Errorf("Deep Blue failed acceptance: %v", err)
    }
}
```
