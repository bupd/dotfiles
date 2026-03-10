# Testing Patterns

## Table of Contents
- Test function design
- Table-driven tests
- Test helpers vs assertion helpers
- t.Error vs t.Fatal
- Test setup scoping
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
    wg.Add(num)
    for i := 0; i < num; i++ {
        go func() {
            defer wg.Done()
            if err := engine.Vroom(); err != nil {
                t.Errorf("No vroom left: %v", err) // NOT t.Fatal
                return
            }
        }()
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
