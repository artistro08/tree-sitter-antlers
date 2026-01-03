; Antlers syntax highlighting queries
; Note: More specific patterns should come before general ones

; ============================================================================
; Delimiters
; ============================================================================

; Antlers delimiters {{ }}
(antlers_start) @punctuation.special
(antlers_end) @punctuation.special

; Comment delimiters {{# #}}
(comment_start) @punctuation.special
(comment_end) @punctuation.special

; PHP delimiters {{? ?}} and {{$ $}}
(php_start) @punctuation.special
(php_end) @punctuation.special
(php_echo_start) @punctuation.special
(php_echo_end) @punctuation.special

; Noparse delimiters
(noparse_start) @keyword
(noparse_end) @keyword

; ============================================================================
; Comments
; ============================================================================

(comment) @comment
(comment_content) @comment

; ============================================================================
; Literals
; ============================================================================

; Strings
(string) @string

; String content inside double-quoted strings
(string_content) @string

; Escape sequences in strings
(escape_sequence) @string.escape

; String interpolation braces
(string_interpolation
  "{" @punctuation.special
  "}" @punctuation.special)

; Variables inside string interpolation
(string_interpolation
  (variable) @variable)

(string_interpolation
  (identifier) @variable)

; Numbers
(number) @number

; Booleans
(boolean) @constant.builtin

; Null
(null) @constant.builtin

; ============================================================================
; Keywords
; ============================================================================

; Control flow keywords - match anonymous keyword nodes
"if" @keyword
"elseif" @keyword
"unless" @keyword
"switch" @keyword

; else_clause is a named node representing the entire "else" keyword
(else_clause) @keyword

; Logical operator keywords
[
  "and"
  "or"
  "xor"
  "not"
] @keyword

; Array operation keywords
[
  "merge"
  "orderby"
  "groupby"
  "where"
  "take"
  "skip"
  "pluck"
  "asc"
  "desc"
] @keyword

; ============================================================================
; Variables and Identifiers (General - comes first as base layer)
; ============================================================================

; Variable with nested access: {{ user:name }} or {{ user.name }}
(variable) @variable

; Array access: {{ items[0] }}
(array_access) @variable

; Identifiers in binary expressions (comparisons, arithmetic, etc.)
(binary_expression
  (identifier) @variable)

; Identifiers in unary expressions
(unary_expression
  (identifier) @variable)

; Identifiers in ternary expressions
(ternary_expression
  (identifier) @variable)

; Identifiers at the start of modifier chains: {{ variable | modifier }}
(modifier_chain
  (identifier) @variable)

; Identifiers in conditional conditions: {{ if card_styling }}
(conditional
  condition: (identifier) @variable)

(elseif_clause
  condition: (identifier) @variable)

(unless
  condition: (identifier) @variable)

; Direct identifier expressions in statements (variables)
; This pattern should only match standalone identifiers, not those inside other expressions
; Removed because it was too broad and caught identifiers inside assignments
; Individual expression contexts handle their own identifier highlighting

; ============================================================================
; Functions and Methods
; ============================================================================

; Method calls: {{ variable.method() }} or {{ variable:method() }}
(method_call
  method: (identifier) @function.method)

; Modifiers: {{ variable | modifier }}
(modifier
  (identifier) @function.method)

; Tag methods: {{ collection:blog }}
; Highlight as variable to match variable syntax
(tag_method
  (identifier) @variable)

; Tag names: {{ partial }} {{ content }} {{ collection }}
; Highlight as variable for consistency
(tag_name
  (identifier) @variable)

; Tag paths: {{ glide:site_settings:image }}
; Highlight as variable to match variable syntax like user:name:field
(tag_path
  (identifier) @variable)

; Forward slash in closing tags
(closing_tag
  "/" @punctuation.special)

; Closing tags with variable (colon/dot) access: {{ /push:scripts }}
; The variable node should be highlighted as variable to match opening tags
(closing_tag
  (variable) @variable)

; Closing tags for other constructs: {{ /content }} {{ /partial }}
; This must come before the keyword pattern so keywords can override it
(closing_tag
  (identifier) @variable)

; Closing tags for keywords: {{ /if }} {{ /unless }} {{ /switch }}
; These should be highlighted as keywords to match their opening tags
; This comes last so it overrides the general variable rule above
((closing_tag
  (identifier) @keyword)
 (#match? @keyword "^(if|unless|switch)$"))

; ============================================================================
; Properties and Parameters
; ============================================================================

; Parameter names and values - MUST come before general identifier rules
; Parameter names: {{ tag param="value" }} or {{ tag w=100 }} or {{ tag glide:width=100 }}
(parameter
  name: (parameter_name) @property)

; Parameter string values
(parameter
  value: (string) @string)

; Parameter number values
(parameter
  value: (number) @number)

; Parameter boolean values
(parameter
  value: (boolean) @constant.builtin)

; Parameter identifier values
(parameter
  value: (identifier) @variable)

; Property access: {{ variable.property }} or {{ variable:property }}
(property_access
  property: (identifier) @property)

; ============================================================================
; Assignments
; ============================================================================

; Assignment left side: {{ total = 0 }}
(assignment
  left: [(identifier) (variable)] @variable)

; Assignment right side identifiers: {{ icon_group = fontawesome_icon_solid }}
(assignment
  right: (identifier) @variable)

; Assignment right side variables: {{ icon_group = site:config }}
(assignment
  right: (variable) @variable)

; ============================================================================
; Operators
; ============================================================================

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "~"
  "=="
  "==="
  "!="
  "!=="
  "<"
  ">"
  "<="
  ">="
  "<=>"
  "&&"
  "||"
  "!"
  "??"
  "?="
  "?"
  ":"
  "="
  "+="
  "-="
  "*="
  "/="
  ".="
  "=>"
  "|"
] @operator

; ============================================================================
; Punctuation
; ============================================================================

[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
] @punctuation.delimiter

; ============================================================================
; Special Content
; ============================================================================

; PHP content blocks
(php_content) @embedded
(php_echo_content) @embedded

; Noparse content
(noparse_content) @string.special

; Text content (HTML outside Antlers tags)
(text) @none
