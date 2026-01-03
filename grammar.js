/**
 * @file Tree-sitter grammar for Statamic Antlers template language
 * @author
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const PREC = {
  ASSIGNMENT: 1,
  GATEKEEPER: 2,
  TERNARY: 3,
  NULL_COALESCENCE: 4,
  OR: 5,
  AND: 6,
  EQUALITY: 7,
  COMPARISON: 8,
  ADDITIVE: 9,
  MULTIPLICATIVE: 10,
  UNARY: 11,
  MEMBER: 12,
  CALL: 13,
};

module.exports = grammar({
  name: "antlers",

  extras: ($) => [/\s/],

  externals: ($) => [
    $.text,
    $.antlers_start,
    $.antlers_end,
    $.comment_start,
    $.comment_end,
    $.comment_content,
    $.php_start,
    $.php_end,
    $.php_content,
    $.php_echo_start,
    $.php_echo_end,
    $.php_echo_content,
    $.noparse_start,
    $.noparse_end,
    $.noparse_content,
  ],

  conflicts: ($) => [
    [$.variable, $.tag_path],
    [$.tag_name, $.tag_path],
  ],

  word: ($) => $.identifier,

  rules: {
    // Entry point - a template is a sequence of content
    template: ($) => repeat($._node),

    _node: ($) =>
      choice(
        $.antlers_node,
        $.comment,
        $.php_statement,
        $.php_echo,
        $.noparse,
        $.text,
      ),

    // Antlers interpolation {{ ... }}
    antlers_node: ($) =>
      seq($.antlers_start, optional($._antlers_content), $.antlers_end),

    _antlers_content: ($) =>
      choice(
        $.conditional,
        $.elseif_clause,
        $.else_clause,
        $.unless,
        $.switch,
        $.closing_tag,
        $.statement_list,
      ),

    statement_list: ($) => seq($._statement, repeat(seq(";", $._statement))),

    _statement: ($) => choice($.assignment, $._expression),

    // Closing tag {{ /tagname }} or {{ /tagname:method }}
    // Variable must come first in choice to match longer patterns like push:scripts
    closing_tag: ($) => seq("/", choice($.variable, $.identifier)),

    // Conditionals
    conditional: ($) => seq("if", field("condition", $._expression)),

    elseif_clause: ($) => seq("elseif", field("condition", $._expression)),

    else_clause: ($) => "else",

    unless: ($) => seq("unless", field("condition", $._expression)),

    // Switch statement
    switch: ($) => seq("switch", "(", field("value", $._expression), ")"),

    // Expressions
    _expression: ($) =>
      choice(
        $.identifier,
        $.variable,
        $.number,
        $.string,
        $.boolean,
        $.null,
        $.array,
        $.binary_expression,
        $.unary_expression,
        $.ternary_expression,
        $.null_coalescence,
        $.gatekeeper,
        $.parenthesized_expression,
        $.modifier_chain,
        $.method_call,
        $.property_access,
        $.array_access,
        $.tag,
        $.inline_tag,
      ),

    // Variable access: {{ variable:nested }} or {{ variable.nested }}
    // Use token.immediate for colon to require no whitespace (helps distinguish from ternary)
    variable: ($) =>
      prec.left(
        PREC.MEMBER,
        seq(
          $.identifier,
          repeat1(
            seq(
              choice(token.immediate(":"), "."),
              $.identifier,
            ),
          ),
        ),
      ),

    // Tag: {{ tag:method param="value" }} or {{ tag:path:to:method param="value" }}
    // Use token.immediate for colon to require no whitespace
    tag: ($) =>
      prec.dynamic(
        -10,
        prec.left(
          seq(
            choice(
              prec(2, $.tag_path),
              seq($.tag_name, optional(seq(token.immediate(":"), $.tag_method))),
            ),
            $.parameters,
          ),
        ),
      ),

    tag_name: ($) => $.identifier,

    tag_method: ($) => $.identifier,

    // Tag path for multi-part tags like glide:site_settings:founders_image
    // Use token.immediate for colon to require no whitespace
    tag_path: ($) =>
      prec.left(seq($.identifier, repeat1(seq(token.immediate(":"), $.identifier)))),

    // Inline tag with single curly braces: {tag:method param="value"}
    // Used in assignments like {{ result = {collection:posts limit="5"} }}
    inline_tag: ($) =>
      seq(
        "{",
        choice(
          prec(2, $.tag_path),
          seq($.tag_name, optional(seq(token.immediate(":"), $.tag_method))),
        ),
        optional($.parameters),
        "}",
      ),

    // Parameters for tags (at least one parameter required to distinguish from variable)
    parameters: ($) => prec.left(repeat1($.parameter)),

    parameter: ($) =>
      seq(
        field("name", $.parameter_name),
        "=",
        field("value", choice($.string, $.number, $.boolean, $.identifier)),
      ),

    // Parameter name can include colons for namespaced parameters and hyphens for HTML attributes
    // (e.g., glide:width, md:quality:webp, wrapper-class, data-value)
    parameter_name: ($) =>
      token(seq(/[a-zA-Z_][a-zA-Z0-9_-]*/, repeat(seq(":", /[a-zA-Z_][a-zA-Z0-9_-]*/)))),

    // Modifiers: {{ variable | modifier | modifier:param }}
    modifier_chain: ($) =>
      prec.left(PREC.MEMBER, seq($._expression, repeat1(seq("|", $.modifier)))),

    modifier: ($) =>
      prec.left(seq($.identifier, optional($.modifier_arguments))),

    modifier_arguments: ($) =>
      choice(
        // Colon syntax: modifier:arg1:arg2
        prec.left(repeat1(seq(":", $._modifier_argument))),
        // Parentheses syntax: modifier('arg1', 'arg2')
        seq("(", optional($.argument_list), ")"),
      ),

    _modifier_argument: ($) =>
      choice($.string, $.number, $.boolean, $.identifier),

    // Method call: {{ variable.method() }}
    method_call: ($) =>
      prec(
        PREC.CALL,
        seq(
          field("object", $._expression),
          choice(".", ":"),
          field("method", $.identifier),
          "(",
          optional($.argument_list),
          ")",
        ),
      ),

    // Property access: {{ variable.property }} or {{ variable:property }}
    // Use token.immediate for colon to require no whitespace
    property_access: ($) =>
      prec.left(
        PREC.MEMBER,
        seq(
          field("object", $._expression),
          choice(".", token.immediate(":")),
          field("property", $.identifier),
        ),
      ),

    // Array access: {{ variable[key] }}
    array_access: ($) =>
      prec(
        PREC.MEMBER,
        seq(
          field("array", $._expression),
          "[",
          field("index", $._expression),
          "]",
        ),
      ),

    // Assignment: {{ total = 0 }} or {{ total += 5 }}
    assignment: ($) =>
      prec.right(
        PREC.ASSIGNMENT,
        seq(
          field("left", choice($.identifier, $.variable)),
          field("operator", choice("=", "+=", "-=", "*=", "/=", ".=")),
          field("right", $._expression),
        ),
      ),

    // Binary expressions
    binary_expression: ($) =>
      choice(
        // Arithmetic
        prec.left(PREC.MULTIPLICATIVE, seq($._expression, "*", $._expression)),
        prec.left(PREC.MULTIPLICATIVE, seq($._expression, "/", $._expression)),
        prec.left(PREC.MULTIPLICATIVE, seq($._expression, "%", $._expression)),
        prec.left(PREC.ADDITIVE, seq($._expression, "+", $._expression)),
        prec.left(PREC.ADDITIVE, seq($._expression, "-", $._expression)),
        prec.left(PREC.ADDITIVE, seq($._expression, "~", $._expression)), // String concat

        // Comparison
        prec.left(PREC.COMPARISON, seq($._expression, "<", $._expression)),
        prec.left(PREC.COMPARISON, seq($._expression, ">", $._expression)),
        prec.left(PREC.COMPARISON, seq($._expression, "<=", $._expression)),
        prec.left(PREC.COMPARISON, seq($._expression, ">=", $._expression)),
        prec.left(PREC.COMPARISON, seq($._expression, "<=>", $._expression)), // Spaceship

        // Equality
        prec.left(PREC.EQUALITY, seq($._expression, "==", $._expression)),
        prec.left(PREC.EQUALITY, seq($._expression, "===", $._expression)),
        prec.left(PREC.EQUALITY, seq($._expression, "!=", $._expression)),
        prec.left(PREC.EQUALITY, seq($._expression, "!==", $._expression)),

        // Logical
        prec.left(
          PREC.AND,
          seq($._expression, choice("&&", "and"), $._expression),
        ),
        prec.left(
          PREC.OR,
          seq($._expression, choice("||", "or"), $._expression),
        ),
        prec.left(PREC.OR, seq($._expression, "xor", $._expression)),

        // Array operators
        prec.left(PREC.COMPARISON, seq($._expression, "merge", $._expression)),
        prec.left(PREC.COMPARISON, seq($._expression, $.orderby_clause)),
        prec.left(PREC.COMPARISON, seq($._expression, $.groupby_clause)),
        prec.left(PREC.COMPARISON, seq($._expression, $.where_clause)),
        prec.left(PREC.COMPARISON, seq($._expression, $.take_clause)),
        prec.left(PREC.COMPARISON, seq($._expression, $.skip_clause)),
        prec.left(PREC.COMPARISON, seq($._expression, $.pluck_clause)),
      ),

    // Array manipulation clauses
    orderby_clause: ($) =>
      seq("orderby", "(", $.identifier, optional(choice("asc", "desc")), ")"),

    groupby_clause: ($) =>
      seq("groupby", "(", $.identifier, optional(seq(",", $.string)), ")"),

    where_clause: ($) => seq("where", "(", $._expression, ")"),

    take_clause: ($) => seq("take", "(", $.number, ")"),

    skip_clause: ($) => seq("skip", "(", $.number, ")"),

    pluck_clause: ($) => seq("pluck", "(", $.string, ")"),

    // Unary expressions
    // Use token("not") to make it a keyword that won't be treated as identifier
    unary_expression: ($) =>
      prec.dynamic(
        10,
        prec.right(
          PREC.UNARY,
          seq(choice("!", "-", token("not")), $._expression),
        ),
      ),

    // Ternary expression: {{ condition ? 'yes' : 'no' }}
    // Colon with whitespace is treated as ternary, without whitespace as variable access
    ternary_expression: ($) =>
      prec.right(
        PREC.TERNARY,
        seq(
          field("condition", $._expression),
          "?",
          field("consequence", $._expression),
          ":",
          field("alternative", $._expression),
        ),
      ),

    // Null coalescence: {{ value ?? default }}
    null_coalescence: ($) =>
      prec.right(
        PREC.NULL_COALESCENCE,
        seq($._expression, "??", $._expression),
      ),

    // Gatekeeper: {{ show_bio ?= author:bio }}
    gatekeeper: ($) =>
      prec.right(PREC.GATEKEEPER, seq($._expression, "?=", $._expression)),

    // Parenthesized expression - can contain assignments or expressions
    parenthesized_expression: ($) => seq("(", $._statement, ")"),

    // Array literal
    array: ($) =>
      seq(
        "[",
        optional(
          seq(
            $._array_element,
            repeat(seq(",", $._array_element)),
            optional(","),
          ),
        ),
        "]",
      ),

    _array_element: ($) => choice($._expression, $.array_pair),

    array_pair: ($) =>
      seq(field("key", $._expression), "=>", field("value", $._expression)),

    // Argument list for function calls
    argument_list: ($) => seq($._expression, repeat(seq(",", $._expression))),

    // Comments {{# ... #}}
    comment: ($) =>
      seq($.comment_start, optional($.comment_content), $.comment_end),

    // PHP statements {{? ... ?}}
    php_statement: ($) => seq($.php_start, optional($.php_content), $.php_end),

    // PHP echo {{$ ... $}}
    php_echo: ($) =>
      seq($.php_echo_start, optional($.php_echo_content), $.php_echo_end),

    // Noparse {{ noparse }}...{{ /noparse }}
    noparse: ($) =>
      seq($.noparse_start, optional($.noparse_content), $.noparse_end),

    // Literals
    identifier: ($) => /[a-zA-Z_][a-zA-Z0-9_]*/,

    number: ($) => choice(/\d+/, /\d+\.\d+/),

    // Strings with interpolation support
    // Double-quoted strings support {variable} interpolation
    // Single-quoted strings are literal (no interpolation)
    string: ($) =>
      choice(
        // Single-quoted string (no interpolation)
        seq("'", repeat(choice(/[^'\\]+/, seq("\\", /./))), "'"),
        // Double-quoted string with optional interpolation
        seq(
          '"',
          repeat(
            choice($.string_interpolation, $.escape_sequence, $.string_content),
          ),
          '"',
        ),
      ),

    // String components
    string_content: ($) => /[^"\\{]+/,

    escape_sequence: ($) => token.immediate(seq("\\", /./)),

    // String interpolation supports both {variable} and {{ expression }} syntax
    string_interpolation: ($) =>
      choice(
        // Single brace: {variable}
        seq("{", choice($.variable, $.identifier), "}"),
        // Double brace: {{ expression }}
        seq("{{", $._expression, "}}"),
      ),

    boolean: ($) => choice("true", "false"),

    null: ($) => "null",
  },
});
