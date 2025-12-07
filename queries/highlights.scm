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

; Numbers
(number) @number

; Booleans
(boolean) @constant.builtin

; Null
(null) @constant.builtin

; ============================================================================
; Keywords
; ============================================================================

[
  "if"
  "elseif"
  "else"
  "unless"
  "switch"
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

; Closing tags for keywords: {{ /if }} {{ /unless }} {{ /switch }}
; These should be highlighted as keywords to match their opening tags
(closing_tag
  (identifier) @keyword
  (#match? @keyword "^(if|unless|switch)$"))

; Closing tags for other constructs: {{ /collection:blog }}
(closing_tag
  (identifier) @function)

; ============================================================================
; Properties and Parameters
; ============================================================================

; Property access: {{ variable.property }} or {{ variable:property }}
(property_access
  property: (identifier) @property)

; Parameter names: {{ tag param="value" }}
; Note: parameter_name is a terminal token, not a parent node
(parameter_name) @property

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
