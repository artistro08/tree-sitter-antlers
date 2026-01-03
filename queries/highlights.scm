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
; Functions and Methods
; ============================================================================

; Method calls: {{ variable.method() }} or {{ variable:method() }}
(method_call
  method: (identifier) @function.method)

; Modifiers: {{ variable | modifier }}
(modifier
  (identifier) @function.method)

; Tag methods: {{ collection:blog }}
(tag_method
  (identifier) @function.method)

; Tag names: {{ collection }}
(tag_name
  (identifier) @function)

; Tag paths: {{ glide:site_settings:image }}
(tag_path
  (identifier) @function)

; Forward slash in closing tags
(closing_tag
  "/" @punctuation.special)

; Closing tags for keywords: {{ /if }} {{ /unless }} {{ /switch }}
; These should be highlighted as keywords to match their opening tags
((closing_tag
  (identifier) @keyword)
 (#match? @keyword "^(if|unless|switch)$")
 (#set! "priority" 105))

; Closing tags for other constructs: {{ /collection:blog }}
(closing_tag
  (identifier) @function)

; Closing tags with variable (colon/dot) access: {{ /push:scripts }}
; The variable node and its identifiers should be highlighted as function
((closing_tag
  (variable) @function)
 (#set! "priority" 110))

; ============================================================================
; Properties and Parameters
; ============================================================================

; Parameter names and values - MUST come before general identifier rules
; Parameter names: {{ tag param="value" }} or {{ tag w=100 }}
(parameter
  name: (identifier) @property)

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

; Assignment right side is already highlighted by other rules

; ============================================================================
; Variables
; ============================================================================

; Array access: {{ items[0] }}
(array_access) @variable

; Variable with nested access: {{ user:name }} or {{ user.name }}
(variable) @variable

; Simple identifiers (fallback for other identifiers)
(identifier) @variable

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
