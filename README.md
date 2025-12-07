# tree-sitter-antlers

A [Tree-sitter](https://tree-sitter.github.io/) grammar for [Statamic Antlers](https://statamic.dev/antlers), the templating language used by the Statamic CMS.

## Features

This parser supports the full Antlers template syntax:

### Variables
- Simple variables: `{{ title }}`
- Nested access with colon notation: `{{ user:profile:name }}`
- Nested access with dot notation: `{{ user.profile.name }}`
- Array access with brackets: `{{ items[0] }}`

### Literals
- Strings: `'single'` or `"double"` quoted
- Numbers: `42`, `3.14`
- Booleans: `true`, `false`
- Null: `null`
- Arrays: `[1, 2, 3]`, `['key' => 'value']`

### Operators
- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `===`, `!=`, `!==`, `<`, `>`, `<=`, `>=`, `<=>`
- Logical: `&&`, `||`, `and`, `or`, `xor`, `!`, `not`
- Null coalescence: `??`
- Gatekeeper: `?=`
- Ternary: `condition ? 'yes' : 'no'`
- String concatenation: `~`

### Modifiers
```antlers
{{ title | upper }}
{{ title | limit:50 }}
{{ date | format('Y-m-d') }}
{{ title | upper | slugify }}
```

### Conditionals
```antlers
{{ if show_title }}
  <h1>{{ title }}</h1>
{{ elseif fallback_title }}
  <h1>{{ fallback_title }}</h1>
{{ else }}
  <h1>Default</h1>
{{ /if }}

{{ unless is_hidden }}
  <p>Visible content</p>
{{ /unless }}
```

### Tags
```antlers
{{ collection:blog limit="5" sort="date:desc" }}
  <article>{{ title }}</article>
{{ /collection:blog }}

{{ partial:header }}
{{ nav:main }}
```

### Assignments
```antlers
{{ total = 0 }}
{{ total += item:price }}
{{ greeting = 'Hello ' + name }}
```

### Array Operations
```antlers
{{ items take(5) }}
{{ items skip(10) }}
{{ items where(active == true) }}
{{ items pluck('name') }}
{{ items orderby(date desc) }}
{{ items groupby(category) }}
{{ items merge other_items }}
```

### Comments
```antlers
{{# This is a comment and won't be rendered #}}
```

### PHP Integration
```antlers
{{? $variable = someFunction(); ?}}
{{$ echo $variable $}}
```

### Noparse Blocks
```antlers
{{ noparse }}
  This {{ content }} won't be parsed
{{ /noparse }}
```

## Installation

```bash
npm install tree-sitter-antlers
```

## Usage

### Node.js

```javascript
const Parser = require('tree-sitter');
const Antlers = require('tree-sitter-antlers');

const parser = new Parser();
parser.setLanguage(Antlers);

const sourceCode = `
<h1>{{ title }}</h1>
{{ if show_content }}
  <p>{{ content | markdown }}</p>
{{ /if }}
`;

const tree = parser.parse(sourceCode);
console.log(tree.rootNode.toString());
```

### Rust

```rust
use tree_sitter::Parser;

fn main() {
    let mut parser = Parser::new();
    parser
        .set_language(&tree_sitter_antlers::LANGUAGE.into())
        .expect("Error loading Antlers grammar");

    let source_code = "{{ title }}";
    let tree = parser.parse(source_code, None).unwrap();

    println!("{}", tree.root_node().to_sexp());
}
```

## Development

### Prerequisites

- Node.js (v18 or later)
- Python 3.6+ (for node-gyp)
- C/C++ compiler (Visual Studio on Windows, GCC/Clang on Unix)

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/tree-sitter-antlers.git
cd tree-sitter-antlers

# Install dependencies
npm install

# Generate the parser
npx tree-sitter generate

# Run tests
npx tree-sitter test

# Parse a file
npx tree-sitter parse example.antlers.html
```

### Project Structure

```
tree-sitter-antlers/
├── grammar.js          # Grammar definition
├── src/
│   ├── parser.c        # Generated parser (do not edit)
│   ├── scanner.c       # External scanner for complex tokens
│   └── tree_sitter/    # Tree-sitter headers
├── bindings/
│   ├── node/           # Node.js bindings
│   ├── rust/           # Rust bindings
│   └── c/              # C bindings
├── queries/
│   ├── highlights.scm  # Syntax highlighting queries
│   ├── injections.scm  # Language injection queries
│   └── locals.scm      # Local variable queries
└── test/
    └── corpus/         # Test cases
```

### Adding Tests

Tests are located in `test/corpus/`. Each test file contains test cases in this format:

```
================================================================================
Test name
================================================================================

{{ input code }}

--------------------------------------------------------------------------------

(expected
  (syntax
    (tree)))
```

## Syntax Highlighting

Query files for syntax highlighting are provided in the `queries/` directory:

- `highlights.scm` - Syntax highlighting
- `injections.scm` - Language injections (HTML in text nodes, PHP in PHP blocks)
- `locals.scm` - Local variable tracking

## Disclaimer

This project was built entirely with AI assistance (Claude). The maintainer does not have direct experience with tree-sitter parser development or the underlying C code. While the parser has been tested and should work correctly, there may be edge cases or issues that haven't been discovered.

## Contributing

Contributions are welcome! If you find bugs, have suggestions, or want to improve the grammar, please feel free to:

- Open an issue to report problems or request features
- Submit a pull request with fixes or enhancements
- Help improve the test coverage
- Enhance the syntax highlighting queries

All contributions, big or small, are appreciated.

## License

MIT
