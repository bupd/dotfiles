# Naming & Package Design

## Table of Contents
- Function and method naming
- Package naming and size
- Variable and receiver naming
- Test double naming
- Shadowing pitfalls

## Function and Method Naming

### Avoid Repetition at Call Sites

Omit from names: input/output types, receiver type, pointer-ness.

```go
// BAD: repeats package name
package yamlconfig
func ParseYAMLConfig(input string) (*Config, error)

// GOOD
package yamlconfig
func Parse(input string) (*Config, error)
```

```go
// BAD: repeats receiver
func (c *Config) WriteConfigTo(w io.Writer) (int64, error)

// GOOD
func (c *Config) WriteTo(w io.Writer) (int64, error)
```

```go
// BAD: repeats parameter names/types
func OverrideFirstWithSecond(dest, source *Config) error

// GOOD
func Override(dest, source *Config) error
```

```go
// BAD: repeats return type
func TransformToJSON(input *Config) *jsonconfig.Config

// GOOD
func Transform(input *Config) *jsonconfig.Config
```

Disambiguate only when necessary:

```go
// GOOD: disambiguation needed
func (c *Config) WriteTextTo(w io.Writer) (int64, error)
func (c *Config) WriteBinaryTo(w io.Writer) (int64, error)
```

### Naming Conventions

Functions returning something → noun-like. No `Get` prefix.

```go
// GOOD
func (c *Config) JobName(key string) (string, bool)

// BAD
func (c *Config) GetJobName(key string) (string, bool)
```

Functions doing something → verb-like:

```go
func (c *Config) WriteDetail(w io.Writer) (int64, error)
```

Type-differentiated functions → type at end:

```go
func ParseInt(input string) (int, error)
func ParseInt64(input string) (int64, error)
```

If there's a "primary" version, omit the type:

```go
func (c *Config) Marshal() ([]byte, error)     // primary
func (c *Config) MarshalText() (string, error)  // variant
```

## Package Naming and Size

Package name matters more than import path for readability. Call sites should read well:

```go
// GOOD: clear at call site
db := spannertest.NewDatabaseFromFile(...)
_, err := f.Seek(0, io.SeekStart)
b := elliptic.Marshal(curve, x, y)

// BAD: vague package names
db := test.NewDatabaseFromFile(...)
_, err := f.Seek(0, common.SeekStart)
b := helper.Marshal(curve, x, y)
```

### Package Size Guidelines

- Group types that clients use together in the same package
- If two packages always need importing together, consider merging them
- Keep files focused: a maintainer should know which file contains what
- No "one type, one file" rule — group related code by file
- Dedicate `doc.go` for long package documentation if needed

## Test Double Naming

### Single type → short name

```go
package creditcardtest

// Stub stubs creditcard.Service and provides no behavior of its own.
type Stub struct{}

func (Stub) Charge(*creditcard.Card, money.Money) error { return nil }
```

### Multiple behaviors → name by behavior

```go
type AlwaysCharges struct{}
func (AlwaysCharges) Charge(*creditcard.Card, money.Money) error { return nil }

type AlwaysDeclines struct{}
func (AlwaysDeclines) Charge(*creditcard.Card, money.Money) error {
    return creditcard.ErrDeclined
}
```

### Multiple types → prefix with type name

```go
type StubService struct{}
func (StubService) Charge(*creditcard.Card, money.Money) error { return nil }

type StubStoredValue struct{}
func (StubStoredValue) Credit(*creditcard.Card, money.Money) error { return nil }
```

### Local variables for test doubles → prefix with role

```go
// GOOD: prefix clarifies it's a double
var spyCC creditcardtest.Spy
proc := &Processor{CC: spyCC}

// BAD: ambiguous
var cc creditcardtest.Spy
proc := &Processor{CC: cc}
```

## Shadowing Pitfalls

**Stomping** (reusing with `:=`) is fine when original value is no longer needed:

```go
// GOOD: ctx intentionally stomped
func (s *Server) innerHandler(ctx context.Context, req *pb.MyRequest) *pb.MyResponse {
    ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
    defer cancel()
    // ...
}
```

**Shadowing** in new scope is a common bug source:

```go
// BAD: ctx shadowed inside if — outer ctx unchanged after block
if *shortenDeadlines {
    ctx, cancel := context.WithTimeout(ctx, 3*time.Second) // new ctx!
    defer cancel()
}
// BUG: ctx here is the original, not the shortened one

// GOOD: use = assignment to modify outer variable
if *shortenDeadlines {
    var cancel func()
    ctx, cancel = context.WithTimeout(ctx, 3*time.Second) // modifies outer ctx
    defer cancel()
}
```

Never shadow standard library package names in large scopes:

```go
// BAD
func LongFunction() {
    url := "https://example.com/"
    // net/url is now inaccessible
}
```
