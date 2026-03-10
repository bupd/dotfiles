# API Design Patterns

## Table of Contents
- Option structs
- Variadic functional options
- Global state avoidance
- Documentation conventions
- Concurrency documentation
- String concatenation
- Variable declarations and size hints

## Option Structs

Use when most callers set multiple fields. The struct should be the last parameter.

```go
// BAD: too many parameters
func EnableReplication(ctx context.Context, config *replicator.Config,
    primaryRegions, readonlyRegions []string,
    replicateExisting, overwritePolicies bool,
    replicationInterval time.Duration, copyWorkers int,
    healthWatcher health.Watcher) { ... }

// GOOD: option struct
type ReplicationOptions struct {
    Config              *replicator.Config
    PrimaryRegions      []string
    ReadonlyRegions     []string
    ReplicateExisting   bool
    OverwritePolicies   bool
    ReplicationInterval time.Duration
    CopyWorkers         int
    HealthWatcher       health.Watcher
}

func EnableReplication(ctx context.Context, opts ReplicationOptions) { ... }
```

Call site reads cleanly with field names:

```go
storage.EnableReplication(ctx, storage.ReplicationOptions{
    Config:         config,
    PrimaryRegions: []string{"us-east1", "us-central2"},
})
```

Use when: all callers set 1+ options, many callers set many options, options shared between functions.

## Variadic Functional Options

Use when most callers need zero options and the function should take no space at the call site for defaults.

```go
type replicationOptions struct {
    readonlyCells       []string
    replicateExisting   bool
    replicationInterval time.Duration
    copyWorkers         int
}

type ReplicationOption func(*replicationOptions)

func ReadonlyCells(cells ...string) ReplicationOption {
    return func(opts *replicationOptions) {
        opts.readonlyCells = append(opts.readonlyCells, cells...)
    }
}

func ReplicateExisting(enabled bool) ReplicationOption {
    return func(opts *replicationOptions) {
        opts.replicateExisting = enabled
    }
}

// Provide defaults
var DefaultReplicationOptions = []ReplicationOption{
    OverwritePolicies(true),
    ReplicationInterval(12 * time.Hour),
    CopyWorkers(10),
}

func EnableReplication(ctx context.Context, config *placer.Config,
    primaryCells []string, opts ...ReplicationOption) {
    var options replicationOptions
    for _, opt := range DefaultReplicationOptions {
        opt(&options)
    }
    for _, opt := range opts {
        opt(&options)
    }
}
```

Call sites scale from simple to complex:

```go
// Simple — no options needed
storage.EnableReplication(ctx, config, []string{"po", "is", "ea"})

// Complex — configure as needed
storage.EnableReplication(ctx, config, []string{"po", "is", "ea"},
    storage.ReadonlyCells("ix", "gg"),
    storage.ReplicationInterval(1*time.Hour),
    storage.CopyWorkers(100),
)
```

Key rules:
- Options accept parameters (not presence-based): `FailFast(enable bool)` not `EnableFailFast()`
- Unexported options struct restricts definitions to the package
- Last option wins on conflict
- Process in order

## Global State Avoidance

Never force clients to use package-level global state. Provide instance values instead.

```go
// BAD: global registry
package sidecar

var registry = make(map[string]*Plugin)

func Register(name string, p *Plugin) error { ... }

// GOOD: instance-based
package sidecar

type Registry struct { plugins map[string]*Plugin }

func New() *Registry { return &Registry{plugins: make(map[string]*Plugin)} }

func (r *Registry) Register(name string, p *Plugin) error { ... }
```

Users pass dependencies explicitly:

```go
func main() {
    sidecars := sidecar.New()
    sidecars.Register("Cloud Logger", cloudlogger.New())
    cfg := &myapp.Config{Sidecars: sidecars}
    myapp.Run(context.Background(), cfg)
}
```

Why global state fails:
- Tests become order-dependent and can't run in parallel
- Can't have multiple independent instances in one process
- Can't replace with test doubles hermetically
- Registration timing becomes fragile (`init` vs after flags vs after main)

## Documentation Conventions

### What to document

- Non-obvious parameters and gotchas — skip obvious ones
- Cleanup requirements: what the caller must close/stop

```go
// GOOD: documents cleanup
// NewTicker returns a new Ticker containing a channel that will send the
// current time on the channel after each tick.
//
// Call Stop to release the Ticker's associated resources when done.
func NewTicker(d Duration) *Ticker
```

- Error types returned:

```go
// GOOD: documents error type
// Chdir changes the current working directory to the named directory.
//
// If there is an error, it will be of type *PathError.
func Chdir(dir string) error
```

### What NOT to document

- Context cancellation behavior (it's implied)
- Concurrency safety of read-only operations (assumed safe)
- Parameter types already visible in the signature

```go
// BAD: restates the obvious
// Run executes the worker's run loop.
//
// The method will process work until the context is cancelled and accordingly
// returns an error.
func (Worker) Run(ctx context.Context) error

// GOOD: context cancellation is implied
// Run executes the worker's run loop.
func (Worker) Run(ctx context.Context) error
```

### When to document concurrency

Document when: operations look read-only but mutate internally, synchronization is provided, or interfaces require goroutine-safety from implementors.

```go
// GOOD: lookup mutates LRU cache internally
// Lookup returns the data associated with the key from the cache.
//
// This operation is not safe for concurrent use.
func (*Cache) Lookup(key string) (data []byte, ok bool)
```

### Signal Boosting

Comment unusual conditions to draw attention:

```go
// GOOD: boosts the unusual == nil check
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

## String Concatenation

Choose by context:

| Method | Use When |
|---|---|
| `+` | Few strings, simple cases: `key := "id: " + p` |
| `fmt.Sprintf` | Formatting needed: `fmt.Sprintf("%s [%s:%d]", src, qos, mtu)` |
| `strings.Builder` | Building piecemeal in a loop (amortized linear time) |
| `text/template` | Complex templating |

```go
// GOOD: Sprintf for formatted output
str := fmt.Sprintf("%s [%s:%d]-> %s", src, qos, mtu, dst)

// BAD: + with conversions
str := src.String() + " [" + qos.String() + ":" + strconv.Itoa(mtu) + "]-> " + dst.String()
```

```go
// GOOD: Builder for loops
b := new(strings.Builder)
for i, d := range digitsOfPi {
    fmt.Fprintf(b, "the %d digit of pi is: %d\n", i, d)
}
str := b.String()
```

When writing to `io.Writer`, use `fmt.Fprintf` directly — don't build a string first.

Use backticks for multi-line constants:

```go
// GOOD
usage := `Usage:

custom_tool [args]`

// BAD
usage := "" +
    "Usage:\n" +
    "\n" +
    "custom_tool [args]"
```

## Variable Declarations and Size Hints

### Zero values

```go
var (
    coords Point    // ready for json.Unmarshal
    magic  [4]byte
    primes []int
)
```

### Composite literals

```go
var (
    coords   = Point{X: x, Y: y}
    magic    = [4]byte{'I', 'W', 'A', 'D'}
    captains = map[string]string{"Kirk": "James Tiberius"}
)
```

### Size hints — only with empirical evidence

```go
buf := make([]byte, 131072)              // known filesystem block size
q := make([]Node, 0, 16)                 // empirically 8-10 per run
seen := make(map[string]bool, shardSize) // known shard size
```

Maps must be explicitly initialized before writing. Reading from nil maps is fine.

Default to zero init or composite literals unless profiling shows preallocation helps.
