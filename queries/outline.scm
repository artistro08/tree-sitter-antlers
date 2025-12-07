; Code outline for Antlers templates

; Tag definitions with methods
(tag
  (tag_name
    (identifier) @name)
  (tag_method
    (identifier) @context)) @item

; Simple tags
(tag
  (tag_name
    (identifier) @name)) @item

; Conditionals
(conditional
  condition: (_) @context.extra) @item
(#set! kind "if")

; Unless statements
(unless
  condition: (_) @context.extra) @item
(#set! kind "unless")

; Switch statements
(switch
  value: (_) @context.extra) @item
(#set! kind "switch")

; Closing tags for major sections
(closing_tag
  (identifier) @name) @item

; Variable assignments
(assignment
  left: (identifier) @name
  right: (_) @context.extra) @item
