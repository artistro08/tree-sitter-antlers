; Local variable tracking for Antlers

; Assignments create local definitions
(assignment
  left: (identifier) @local.definition)

; Variable references
(identifier) @local.reference
(variable) @local.reference
