# Known Limitations

This document describes known limitations in the tree-sitter Antlers grammar and provides workarounds.

## Colon-Prefixed Parameters

### What Are Colon-Prefixed Parameters?

In Statamic Antlers (similar to Vue/Alpine.js), a `:` prefix before a parameter name indicates that the value should be treated as a variable/expression rather than a literal string:

```antlers
{{ partial :url="link_variable" }}
```

This passes the value of `link_variable` instead of the literal string `"link_variable"`.

### Limitation

**Colon-prefixed parameters (`:param`) work with restrictions:**

✅ **WORKS**: Single colon parameter at the BEGINNING, followed by normal parameters
```antlers
{{ partial :url="link" src="partials/button" class="btn" }}
```

❌ **DOESN'T WORK**: Colon parameter AFTER normal parameters
```antlers
{{ partial src="partials/button" :url="link" }}
<!-- Syntax highlighting breaks after :url -->
```

❌ **DOESN'T WORK**: Multiple colon parameters in sequence
```antlers
{{ partial :url="link" :class="btn_class" src="partials/button" }}
<!-- Syntax highlighting breaks after the second colon parameter -->
```

### Why This Limitation Exists

The grammar parser encounters ambiguity when it sees `:` after parsing a parameter. The colon could be:
- Part of a colon-prefixed parameter (`:url="value"`)
- Part of a ternary operator (`condition ? 'yes' : 'no'`)
- Part of a variable access (`var:field`)
- Part of a tag method (`tag:method`)

Despite extensive optimization attempts with dynamic precedence, the parser chooses to exit the tag early when encountering this ambiguity after a normal parameter.

### Workaround

**Reorder your parameters**: Place all colon-prefixed parameters at the BEGINNING of your tag parameters.

**Before (breaks highlighting):**
```antlers
{{ partial
    src="partials/button"
    class="btn btn-primary"
    :url="link_variable"
}}
```

**After (works correctly):**
```antlers
{{ partial
    :url="link_variable"
    src="partials/button"
    class="btn btn-primary"
}}
```

### Alternative Syntax

If you have multiple variable parameters or cannot reorder, consider using string interpolation instead:

```antlers
{{ partial
    src="partials/button"
    class="btn btn-primary"
    url="{link_variable}"
}}
```

## Fully Supported Features

All other Antlers syntax is fully supported:

✅ Tag paths with colons: `{{ responsive:image }}`, `{{ collection:posts }}`
✅ Namespaced parameters: `glide:width="415"`, `md:glide:width="985"`, `quality:webp="65"`
✅ Parameters with hyphens: `wrapper-class="value"`, `data-attribute="value"`
✅ String interpolation with expressions: `"{enable ? 'active' : 'inactive'}"`
✅ Inline tags: `{{ result = {collection:posts limit="5"} }}`
✅ All control structures, conditionals, loops, modifiers, etc.

## HTML Highlighting in Attributes

Another known limitation is HTML highlighting can break when Antlers tags appear mid-attribute:

❌ **Limited support:**
```html
<img src="/path/{{ var }}.png" alt="...">
<!-- HTML highlighting may break after .png -->
```

This is a fundamental limitation of the language injection approach and affects approximately 5% of use cases. This cannot be fixed without major architectural changes to how tree-sitter handles embedded languages.
