; Indentation rules for Antlers templates

; Indent inside antlers nodes with content
(antlers_node
  (statement_list) @indent
  (#set! indent.immediate))

; Indent inside conditionals
(conditional) @indent

; Indent inside unless
(unless) @indent

; Indent inside switch
(switch) @indent

; Indent inside arrays
(array
  "[" @start
  "]" @end) @indent

; Indent inside parenthesized expressions
(parenthesized_expression
  "(" @start
  ")" @end) @indent

; Indent inside tags with parameters
(tag
  (parameters) @indent
  (#set! indent.immediate))

; Indent inside method calls
(method_call) @indent

; Dedent closing tags
(closing_tag) @outdent

; Dedent elseif and else
(elseif_clause) @branch
(else_clause) @branch

; Dedent closing delimiters
"]" @end
")" @end
"}}" @end
