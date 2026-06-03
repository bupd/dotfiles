# Helm Template Functions Reference

Helm templates use Go templates + Sprig library + Helm-specific functions.

## Go Built-in Functions

### Comparison Operators (implemented as functions)

```yaml
{{ eq .Values.env "prod" }}      # ==
{{ ne .Values.env "dev" }}       # !=
{{ lt .Values.count 10 }}        # <
{{ le .Values.count 10 }}        # <=
{{ gt .Values.count 5 }}         # >
{{ ge .Values.count 5 }}         # >=

# eq accepts multiple args (OR)
{{ if eq .Values.env "prod" "staging" }}
```

### Boolean Logic

```yaml
{{ and .Values.a .Values.b }}    # Returns first empty or last arg
{{ or .Values.a .Values.b }}     # Returns first non-empty or last arg
{{ not .Values.enabled }}        # Boolean negation
```

### Output Functions

```yaml
{{ print "hello" }}              # fmt.Sprint
{{ printf "%s-%d" "app" 1 }}     # fmt.Sprintf
{{ println "line" }}             # fmt.Sprintln
```

### Other Built-ins

```yaml
{{ len .Values.list }}           # Length of string/slice/map
{{ index .Values.list 0 }}       # Index access: list[0]
{{ slice .Values.list 1 3 }}     # Slice: list[1:3]
{{ call .Values.fn arg }}        # Call function value
```

## Sprig String Functions

### Case Conversion

```yaml
{{ upper "hello" }}              # HELLO
{{ lower "HELLO" }}              # hello
{{ title "hello world" }}        # Hello World
{{ untitle "Hello World" }}      # hello world
{{ camelcase "hello_world" }}    # HelloWorld
{{ snakecase "HelloWorld" }}     # hello_world
{{ kebabcase "HelloWorld" }}     # hello-world
```

### Trimming & Padding

```yaml
{{ trim "  hello  " }}           # hello
{{ trimPrefix "pre-" "pre-fix"}} # fix
{{ trimSuffix "-suf" "word-suf"}}# word
{{ trimAll "$" "$5.00$" }}       # 5.00
{{ trunc 5 "hello world" }}      # hello
{{ abbrev 10 "hello world" }}    # hello w...
{{ nospace "h e l l o" }}        # hello
```

### Search & Replace

```yaml
{{ contains "cat" "catch" }}     # true
{{ hasPrefix "pre" "prefix" }}   # true
{{ hasSuffix "fix" "suffix" }}   # true
{{ replace "o" "0" "foo" }}      # f00
{{ regexMatch "^[a-z]+$" "abc"}} # true
{{ regexReplaceAll "a(b+)" "abb" "${1}"}} # bb
```

### Split & Join

```yaml
{{ split "," "a,b,c" }}          # map: _0:a _1:b _2:c
{{ splitList "," "a,b,c" }}      # list: [a b c]
{{ join "," (list "a" "b") }}    # a,b
{{ sortAlpha (list "b" "a") }}   # [a b]
```

### Conversion

```yaml
{{ toString 123 }}               # "123"
{{ toStrings (list 1 2) }}       # ["1" "2"]
{{ atoi "123" }}                 # 123 (string to int)
{{ int64 "123" }}                # 123 (to int64)
{{ float64 "1.5" }}              # 1.5
```

### Quoting

```yaml
{{ quote .Values.name }}         # "value" (with quotes)
{{ squote .Values.name }}        # 'value' (single quotes)
{{ noquote .Values.name }}       # value (no quotes, for template output)
```

## Sprig Data Structure Functions

### Lists

```yaml
{{ list "a" "b" "c" }}           # Create list
{{ first (list 1 2 3) }}         # 1
{{ last (list 1 2 3) }}          # 3
{{ rest (list 1 2 3) }}          # [2 3]
{{ initial (list 1 2 3) }}       # [1 2]
{{ append (list 1 2) 3 }}        # [1 2 3]
{{ prepend (list 2 3) 1 }}       # [1 2 3]
{{ concat (list 1) (list 2) }}   # [1 2]
{{ reverse (list 1 2 3) }}       # [3 2 1]
{{ uniq (list 1 1 2) }}          # [1 2]
{{ without (list 1 2 3) 2 }}     # [1 3]
{{ has 2 (list 1 2 3) }}         # true
{{ compact (list "" "a" "") }}   # ["a"]
```

### Dictionaries

```yaml
{{ dict "key1" "val1" "key2" "val2" }}  # Create dict
{{ get .dict "key" }}                    # Get value
{{ set .dict "key" "val" }}              # Set value (mutates)
{{ unset .dict "key" }}                  # Remove key (mutates)
{{ hasKey .dict "key" }}                 # Check key exists
{{ keys .dict }}                         # List of keys
{{ values .dict }}                       # List of values
{{ pluck "key" .dict1 .dict2 }}          # Get "key" from multiple dicts
{{ merge .dest .src1 .src2 }}            # Merge dicts (mutates dest)
{{ mergeOverwrite .dest .src }}          # Merge, overwriting
{{ pick .dict "key1" "key2" }}           # Dict with only listed keys
{{ omit .dict "key1" "key2" }}           # Dict without listed keys
{{ deepCopy .dict }}                     # Deep copy
```

## Sprig Type Functions

```yaml
{{ kindOf .Values.x }}           # "string", "int", "map", etc.
{{ typeOf .Values.x }}           # Go type
{{ kindIs "string" .Values.x }}  # true if string
{{ typeIs "int" .Values.x }}     # true if int type
{{ deepEqual .a .b }}            # Deep equality check
```

## Sprig Math Functions

```yaml
{{ add 1 2 }}                    # 3
{{ sub 3 1 }}                    # 2
{{ mul 2 3 }}                    # 6
{{ div 6 2 }}                    # 3
{{ mod 5 2 }}                    # 1
{{ max 1 2 3 }}                  # 3
{{ min 1 2 3 }}                  # 1
{{ floor 1.9 }}                  # 1
{{ ceil 1.1 }}                   # 2
{{ round 1.5 0 }}                # 2
{{ add1 5 }}                     # 6 (increment)
```

## Sprig Date Functions

```yaml
{{ now }}                        # Current time
{{ date "2006-01-02" now }}      # Format date (Go layout)
{{ dateModify "-1h" now }}       # Subtract 1 hour
{{ toDate "2006-01-02" "2024-01-15" }}  # Parse date
{{ unixEpoch now }}              # Unix timestamp
```

## Sprig Encoding Functions

```yaml
{{ b64enc "hello" }}             # Base64 encode
{{ b64dec "aGVsbG8=" }}          # Base64 decode
{{ sha256sum "data" }}           # SHA256 hash
{{ sha1sum "data" }}             # SHA1 hash
{{ derivePassword 1 "long" "pass" "user" "example.com" }}
```

## Helm-Specific Functions

### include vs template

```yaml
# include returns string (can be piped)
{{ include "mychart.labels" . | nindent 4 }}

# template outputs directly (cannot be piped)
{{ template "mychart.name" . }}
```

Always use `include` for Helm - it supports pipelines.

### required

```yaml
# Fail if value not provided
{{ required "image.tag is required" .Values.image.tag }}
```

### tpl

```yaml
# Render string as template
# values.yaml: greeting: "Hello {{ .Release.Name }}"
{{ tpl .Values.greeting . }}
```

### toYaml / toJson / toToml

```yaml
# Convert to YAML (most common)
{{- toYaml .Values.resources | nindent 12 }}

# Convert to JSON
{{ toJson .Values.config }}

# Convert to TOML
{{ toToml .Values.config }}

# From YAML/JSON string
{{ fromYaml .Values.yamlString }}
{{ fromJson .Values.jsonString }}
```

### lookup

```yaml
# Query cluster for existing resources
{{ $secret := lookup "v1" "Secret" "namespace" "name" }}
{{- if $secret }}
# Secret exists
{{- end }}

# List all secrets in namespace
{{ $secrets := lookup "v1" "Secret" "namespace" "" }}

# List all secrets in all namespaces  
{{ $secrets := lookup "v1" "Secret" "" "" }}
```

Note: `lookup` returns empty during `helm template` (no cluster connection).

### Indentation

```yaml
{{ nindent 4 "text" }}           # Newline + indent
{{ indent 4 "text" }}            # Indent only (no newline)
```

## Flow Control

### if/else

```yaml
{{- if .Values.enabled }}
key: value
{{- else if .Values.fallback }}
key: fallback
{{- else }}
key: default
{{- end }}
```

False values: `false`, `0`, `nil`, empty string, empty collection.

### with (scope change)

```yaml
{{- with .Values.config }}
# . is now .Values.config
setting: {{ .setting }}
# Use $ for root scope
release: {{ $.Release.Name }}
{{- end }}
```

### range

```yaml
# List iteration
{{- range .Values.hosts }}
- {{ . | quote }}
{{- end }}

# With index
{{- range $index, $host := .Values.hosts }}
- {{ $index }}: {{ $host }}
{{- end }}

# Map iteration
{{- range $key, $val := .Values.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}

# Inline list
{{- range tuple "a" "b" "c" }}
- {{ . }}
{{- end }}
```

### define/template/block

```yaml
# Define reusable template
{{- define "mychart.labels" -}}
app: {{ .name }}
{{- end -}}

# Use with include (preferred)
{{ include "mychart.labels" (dict "name" "myapp") }}

# Block: define + execute
{{- block "mychart.extra" . }}
# Default content (can be overridden)
{{- end }}
```

## Variables

```yaml
# Declare
{{- $name := .Values.name -}}

# Reassign
{{- $name = "newvalue" -}}

# $ always refers to root scope
{{- range .Values.items }}
release: {{ $.Release.Name }}
{{- end }}
```

## Whitespace Control

```yaml
{{- trim left whitespace }}      # Chomp left
{{ trim right whitespace -}}     # Chomp right
{{- both sides -}}               # Chomp both

# Common pattern
{{- if .Values.enabled }}
key: value
{{- end }}
```

## Pipeline Pattern

```yaml
# Chain functions left to right
{{ .Values.name | default "app" | quote }}

# Equivalent to
{{ quote (default "app" .Values.name) }}
```
