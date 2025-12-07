/**
 * External scanner for Statamic Antlers template language
 * Handles complex delimiter tokens that cannot be expressed with regular expressions
 */

#include "tree_sitter/parser.h"
#include "tree_sitter/alloc.h"
#include <stdbool.h>

enum TokenType {
  TEXT,
  ANTLERS_START,
  ANTLERS_END,
  COMMENT_START,
  COMMENT_END,
  COMMENT_CONTENT,
  PHP_START,
  PHP_END,
  PHP_CONTENT,
  PHP_ECHO_START,
  PHP_ECHO_END,
  PHP_ECHO_CONTENT,
  NOPARSE_START,
  NOPARSE_END,
  NOPARSE_CONTENT,
};

// Scanner state
typedef struct {
  bool in_antlers;
  bool in_comment;
  bool in_php;
  bool in_php_echo;
  bool in_noparse;
} Scanner;

static void advance(TSLexer *lexer) {
  lexer->advance(lexer, false);
}

static void skip_whitespace(TSLexer *lexer) {
  lexer->advance(lexer, true);
}

static bool is_eof(TSLexer *lexer) {
  return lexer->eof(lexer);
}

void *tree_sitter_antlers_external_scanner_create() {
  Scanner *scanner = (Scanner *)ts_malloc(sizeof(Scanner));
  scanner->in_antlers = false;
  scanner->in_comment = false;
  scanner->in_php = false;
  scanner->in_php_echo = false;
  scanner->in_noparse = false;
  return scanner;
}

void tree_sitter_antlers_external_scanner_destroy(void *payload) {
  Scanner *scanner = (Scanner *)payload;
  ts_free(scanner);
}

unsigned tree_sitter_antlers_external_scanner_serialize(void *payload, char *buffer) {
  Scanner *scanner = (Scanner *)payload;
  buffer[0] = scanner->in_antlers;
  buffer[1] = scanner->in_comment;
  buffer[2] = scanner->in_php;
  buffer[3] = scanner->in_php_echo;
  buffer[4] = scanner->in_noparse;
  return 5;
}

void tree_sitter_antlers_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  Scanner *scanner = (Scanner *)payload;
  if (length >= 5) {
    scanner->in_antlers = buffer[0];
    scanner->in_comment = buffer[1];
    scanner->in_php = buffer[2];
    scanner->in_php_echo = buffer[3];
    scanner->in_noparse = buffer[4];
  } else {
    scanner->in_antlers = false;
    scanner->in_comment = false;
    scanner->in_php = false;
    scanner->in_php_echo = false;
    scanner->in_noparse = false;
  }
}

bool tree_sitter_antlers_external_scanner_scan(
  void *payload,
  TSLexer *lexer,
  const bool *valid_symbols
) {
  Scanner *scanner = (Scanner *)payload;

  // Handle comment content - scan until we find #}}
  if (valid_symbols[COMMENT_CONTENT] && scanner->in_comment) {
    bool has_content = false;
    while (!is_eof(lexer)) {
      if (lexer->lookahead == '#') {
        lexer->mark_end(lexer);
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          if (lexer->lookahead == '}') {
            // Found #}} - return content we have
            if (has_content) {
              lexer->result_symbol = COMMENT_CONTENT;
              return true;
            }
            return false;
          }
        }
        // Not #}}, continue scanning
        has_content = true;
        continue;
      }
      advance(lexer);
      has_content = true;
    }
    if (has_content) {
      lexer->mark_end(lexer);
      lexer->result_symbol = COMMENT_CONTENT;
      return true;
    }
    return false;
  }

  // Handle PHP content - scan until we find ?}}
  if (valid_symbols[PHP_CONTENT] && scanner->in_php) {
    bool has_content = false;
    while (!is_eof(lexer)) {
      if (lexer->lookahead == '?') {
        lexer->mark_end(lexer);
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          if (lexer->lookahead == '}') {
            // Found ?}} - return content we have
            if (has_content) {
              lexer->result_symbol = PHP_CONTENT;
              return true;
            }
            return false;
          }
        }
        // Not ?}}, continue scanning
        has_content = true;
        continue;
      }
      advance(lexer);
      has_content = true;
    }
    if (has_content) {
      lexer->mark_end(lexer);
      lexer->result_symbol = PHP_CONTENT;
      return true;
    }
    return false;
  }

  // Handle PHP echo content - scan until we find $}}
  if (valid_symbols[PHP_ECHO_CONTENT] && scanner->in_php_echo) {
    bool has_content = false;
    while (!is_eof(lexer)) {
      if (lexer->lookahead == '$') {
        lexer->mark_end(lexer);
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          if (lexer->lookahead == '}') {
            // Found $}} - return content we have
            if (has_content) {
              lexer->result_symbol = PHP_ECHO_CONTENT;
              return true;
            }
            return false;
          }
        }
        // Not $}}, continue scanning
        has_content = true;
        continue;
      }
      advance(lexer);
      has_content = true;
    }
    if (has_content) {
      lexer->mark_end(lexer);
      lexer->result_symbol = PHP_ECHO_CONTENT;
      return true;
    }
    return false;
  }

  // Handle noparse content
  if (valid_symbols[NOPARSE_CONTENT] && scanner->in_noparse) {
    bool has_content = false;
    while (!is_eof(lexer)) {
      if (lexer->lookahead == '{') {
        lexer->mark_end(lexer);
        advance(lexer);
        if (lexer->lookahead == '{') {
          advance(lexer);
          // Skip whitespace
          while (lexer->lookahead == ' ' || lexer->lookahead == '\t' ||
                 lexer->lookahead == '\n' || lexer->lookahead == '\r') {
            advance(lexer);
          }
          // Check for /noparse
          if (lexer->lookahead == '/') {
            advance(lexer);
            if (lexer->lookahead == 'n') {
              // Potential /noparse - return what we have
              if (has_content) {
                lexer->result_symbol = NOPARSE_CONTENT;
                return true;
              }
              return false;
            }
          }
          // Not {{ /noparse, continue
          has_content = true;
          continue;
        }
        has_content = true;
        continue;
      }
      advance(lexer);
      has_content = true;
    }
    if (has_content) {
      lexer->mark_end(lexer);
      lexer->result_symbol = NOPARSE_CONTENT;
      return true;
    }
    return false;
  }

  // Handle noparse end {{ /noparse }}
  if (valid_symbols[NOPARSE_END] && scanner->in_noparse) {
    if (lexer->lookahead == '{') {
      advance(lexer);
      if (lexer->lookahead == '{') {
        advance(lexer);
        // Skip whitespace
        while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
          advance(lexer);
        }
        if (lexer->lookahead == '/') {
          advance(lexer);
          // Match 'noparse'
          const char *noparse = "noparse";
          for (int i = 0; noparse[i] != '\0'; i++) {
            if (lexer->lookahead != noparse[i]) {
              return false;
            }
            advance(lexer);
          }
          // Skip whitespace
          while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
            advance(lexer);
          }
          if (lexer->lookahead == '}') {
            advance(lexer);
            if (lexer->lookahead == '}') {
              advance(lexer);
              lexer->result_symbol = NOPARSE_END;
              scanner->in_noparse = false;
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  // Skip whitespace when not looking for text or content
  if (!valid_symbols[TEXT] && !valid_symbols[COMMENT_CONTENT] && 
      !valid_symbols[PHP_CONTENT] && !valid_symbols[PHP_ECHO_CONTENT]) {
    while (lexer->lookahead == ' ' || lexer->lookahead == '\t' ||
           lexer->lookahead == '\n' || lexer->lookahead == '\r') {
      skip_whitespace(lexer);
    }
  }

  // Check for Antlers end }}
  if (valid_symbols[ANTLERS_END] && scanner->in_antlers) {
    if (lexer->lookahead == '}') {
      advance(lexer);
      if (lexer->lookahead == '}') {
        advance(lexer);
        lexer->result_symbol = ANTLERS_END;
        scanner->in_antlers = false;
        return true;
      }
    }
  }

  // Check for comment end #}}
  if (valid_symbols[COMMENT_END] && scanner->in_comment) {
    if (lexer->lookahead == '#') {
      advance(lexer);
      if (lexer->lookahead == '}') {
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          lexer->result_symbol = COMMENT_END;
          scanner->in_comment = false;
          return true;
        }
      }
    }
    return false;
  }

  // Check for PHP end ?}}
  if (valid_symbols[PHP_END] && scanner->in_php) {
    if (lexer->lookahead == '?') {
      advance(lexer);
      if (lexer->lookahead == '}') {
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          lexer->result_symbol = PHP_END;
          scanner->in_php = false;
          return true;
        }
      }
    }
    return false;
  }

  // Check for PHP echo end $}}
  if (valid_symbols[PHP_ECHO_END] && scanner->in_php_echo) {
    if (lexer->lookahead == '$') {
      advance(lexer);
      if (lexer->lookahead == '}') {
        advance(lexer);
        if (lexer->lookahead == '}') {
          advance(lexer);
          lexer->result_symbol = PHP_ECHO_END;
          scanner->in_php_echo = false;
          return true;
        }
      }
    }
    return false;
  }

  // Check for opening delimiters {{ {{# {{? {{$
  if (lexer->lookahead == '{') {
    advance(lexer);
    if (lexer->lookahead == '{') {
      advance(lexer);

      // Check for comment start {{#
      if (valid_symbols[COMMENT_START] && lexer->lookahead == '#') {
        advance(lexer);
        lexer->result_symbol = COMMENT_START;
        scanner->in_comment = true;
        return true;
      }

      // Check for PHP start {{?
      if (valid_symbols[PHP_START] && lexer->lookahead == '?') {
        advance(lexer);
        lexer->result_symbol = PHP_START;
        scanner->in_php = true;
        return true;
      }

      // Check for PHP echo start {{$
      if (valid_symbols[PHP_ECHO_START] && lexer->lookahead == '$') {
        advance(lexer);
        lexer->result_symbol = PHP_ECHO_START;
        scanner->in_php_echo = true;
        return true;
      }

      // Check for noparse start {{ noparse }}
      if (valid_symbols[NOPARSE_START]) {
        // Skip whitespace
        while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
          advance(lexer);
        }
        // Check for 'noparse'
        if (lexer->lookahead == 'n') {
          const char *noparse = "noparse";
          int i;
          for (i = 0; noparse[i] != '\0'; i++) {
            if (lexer->lookahead != noparse[i]) {
              break;
            }
            advance(lexer);
          }
          if (noparse[i] == '\0') {
            // Skip whitespace
            while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
              advance(lexer);
            }
            if (lexer->lookahead == '}') {
              advance(lexer);
              if (lexer->lookahead == '}') {
                advance(lexer);
                lexer->result_symbol = NOPARSE_START;
                scanner->in_noparse = true;
                return true;
              }
            }
          }
        }
      }

      // Regular Antlers start {{
      if (valid_symbols[ANTLERS_START]) {
        lexer->result_symbol = ANTLERS_START;
        scanner->in_antlers = true;
        return true;
      }
    }
  }

  // Handle text content (anything outside of Antlers tags)
  if (valid_symbols[TEXT]) {
    bool has_content = false;

    while (!is_eof(lexer)) {
      // Check for @ (escaped Antlers)
      if (lexer->lookahead == '@') {
        if (has_content) {
          lexer->mark_end(lexer);
          lexer->result_symbol = TEXT;
          return true;
        }
        // Skip the @ and continue as text including the Antlers
        advance(lexer);
        if (lexer->lookahead == '{') {
          advance(lexer);
          if (lexer->lookahead == '{') {
            // Skip until }}
            advance(lexer);
            while (!is_eof(lexer)) {
              if (lexer->lookahead == '}') {
                advance(lexer);
                if (lexer->lookahead == '}') {
                  advance(lexer);
                  break;
                }
              } else {
                advance(lexer);
              }
            }
            has_content = true;
            continue;
          }
        }
        has_content = true;
        continue;
      }

      // Check for Antlers start
      if (lexer->lookahead == '{') {
        lexer->mark_end(lexer);
        advance(lexer);
        if (lexer->lookahead == '{') {
          // Found {{ - return text if we have any
          if (has_content) {
            lexer->result_symbol = TEXT;
            return true;
          }
          return false;
        }
        // Single { is just text
        has_content = true;
        continue;
      }

      advance(lexer);
      has_content = true;
    }

    if (has_content) {
      lexer->mark_end(lexer);
      lexer->result_symbol = TEXT;
      return true;
    }
  }

  return false;
}
