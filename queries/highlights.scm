; Antlers syntax highlighting queries

; Comments
(comment) @comment
(comment_content) @comment

; Strings
(string) @string

; Numbers
(number) @number

; Booleans
(boolean) @constant.builtin

; Null
(null) @constant.builtin

; Identifiers and variables
(identifier) @variable
(variable (identifier) @variable)

; Tags
(tag_name (identifier) @function)
(tag_method (identifier) @function.method)

; Parameters
(parameter_name (identifier) @property)

; Modifiers
(modifier (identifier) @function.method)

; Closing tags
(closing_tag (identifier) @function)

; Operators
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

; Keywords
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

; Boolean and null literals
(boolean) @constant.builtin
(null) @constant.builtin

; Punctuation
[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
  "."
] @punctuation.delimiter

; PHP content
(php_content) @embedded
(php_echo_content) @embedded

; Noparse content
(noparse_content) @string.special

; Text content (HTML)
(text) @none
