; Injection queries for Antlers

; Inject HTML into text nodes
((text) @injection.content
 (#set! injection.language "html"))

; Inject PHP into PHP blocks
((php_content) @injection.content
 (#set! injection.language "php"))
