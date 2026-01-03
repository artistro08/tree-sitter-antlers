; Injection queries for Antlers

; Inject HTML into text nodes with combined injection to preserve Antlers syntax
((text) @injection.content
 (#set! injection.language "html")
 (#set! injection.combined))

; Inject PHP into PHP blocks
((php_content) @injection.content
 (#set! injection.language "php"))

; Inject PHP into PHP echo blocks
((php_echo_content) @injection.content
 (#set! injection.language "php"))
