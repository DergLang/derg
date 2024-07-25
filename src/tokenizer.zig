// Based on the Zig tokenizer
// https://github.com/ziglang/zig/blob/master/lib/std/zig/tokenizer.zig
// why reinvent the wheel when zig already has a good tokenizer

const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize
    };

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub const Tag = enum {
        invalid,
        eof,
        identifier,
        string_literal,
        multiline_string_literal,
        l_bracket,
        r_bracket,
        l_brace,
        r_brace,
        l_paren,
        r_paren,
        equal,
        is_equal,
        bang_equal,
        period,
        tilde,
        bang,
        semicolon,
        comment,
        important_comment,
        number_literal,
        question_mark,
        question_mark_question_mark,
        ampersand,
        comma,
        arrow,
        equal_arrow,
        colon,
        caret,
        caret_equal,
        plus_plus,
        minus_minus,
        slash,
        backslash,
        pipe,
        asterisk,
        asterisk_equal,
        plus,
        plus_equal,
        minus,
        minus_equal,
        percent,
        percent_equal,
        ellipsis,
        slash_equal,
        slash_slash,
        slash_slash_equal,
        angle_bracket_left,
        angle_bracket_right,
        angle_bracket_left_equal,
        angle_bracket_right_equal,
        kwd_if,
        kwd_local,
        kwd_const,
        kwd_import,
        kwd_export,
        kwd_break,
        kwd_continue,
        kwd_else,
        kwd_elseif,
        kwd_for,
        kwd_while,
        kwd_not,
        kwd_fn,
        kwd_and,
        kwd_or,
        kwd_self,
        kwd_type,
        kwd_is,
        kwd_return,
        kwd_luau,
        kwd_error,
        kwd_warn,
        kwd_defer,
        kwd_await,
        kwd_try,
        kwd_catch,
        kwd_class,
        kwd_trait,
        kwd_record,
        kwd_true,
        kwd_false,

        pub fn lexeme(tag: Tag) ?[]const u8 {
            return switch (tag) {
                .invalid,
                .identifier,
                .string_literal,
                .multiline_string_literal,
                .eof,
                .number_literal,
                .comment,
                .important_comment,
                => null,

                .l_bracket => '[',
                .r_bracket => ']',
                .l_brace => '{',
                .r_brace => '}',
                .l_paren => '(',
                .r_paren => ')',
                .equal => '=',
                .equal_arrow => "=>",
                .is_equal => "==",
                .bang_equal => "!=",
                .period => '.',
                .tilde => '~',
                .bang => '!',
                .semicolon => ';',
                .question_mark => '?',
                .question_mark_question_mark => "??",
                .ampersand => '&',
                .arrow => "->",
                .colon => ':',
                .caret => '^',
                .caret_equal => "^=",
                .plus_plus => "++",
                .minus_minus => "--",
                .slash => '/',
                .backslash => '\\',
                .pipe => "|>",
                .asterisk => '*',
                .asterisk_equal => "*=",
                .plus => '+',
                .plus_equal => "+=",
                .minus => '-',
                .minus_equal => "-=",
                .percent => '%',
                .percent_equal => "%=",
                .ellipsis => "...",
                .slash_equal => "/=",
                .slash_slash => "//",
                .slash_slash_equal => "//=",
                .angle_bracket_left => '<',
                .angle_bracket_right => '>',
                .angle_bracket_left_equal => ">=",
                .angle_bracket_right_equal => "<=",

                .kwd_if => "if",
                .kwd_local => "local",
                .kwd_const => "const",
                .kwd_import => "import",
                .kwd_export => "export",
                .kwd_break => "break",
                .kwd_continue => "contiune",
                .kwd_else => "else",
                .kwd_elseif => "elseif",
                .kwd_for => "for",
                .kwd_while => "while",
                .kwd_not => "not",
                .kwd_fn => "fn",
                .kwd_and => "and",
                .kwd_or => "or",
                .kwd_self => "self",
                .kwd_type => "type",
                .kwd_is => "is",
                .kwd_return => "return",
                .kwd_luau => "luau",
                .kwd_error => "error",
                .kwd_warn => "warn",
                .kwd_defer => "defer",
                .kwd_await => "await",
                .kwd_try => "try",
                .kwd_catch => "catch",
                .kwd_class => "class",
                .kwd_trait => "trait",
                .kwd_record => "record",
                .kwd_true => "true",
                .kwd_false => "false"
            };
        }

        pub fn symbol(tag: Tag) []const u8 {
            return tag.lexeme() orelse switch (tag) {
                .invalid => "invalid bytes",
                .identifier => "an identifier",
                .string_literal, .multiline_string_literal => "a string literal",
                .eof => "end of file",
                .number_literal => "a number literal",
                .comment, .important_comment => "a comment",
                else => unreachable
            };
        }
    };
};

pub const keywords = std.StaticStringMap(Token.Tag).initComptime(.{
    .{ "if", .kwd_if },
    .{ "local", .kwd_local },
    .{ "const", .kwd_const },
    .{ "import", .kwd_import },
    .{ "export", .kwd_export },
    .{ "break", .kwd_break },
    .{ "continue", .kwd_continue },
    .{ "else", .kwd_else },
    .{ "elseif", .kwd_elseif },
    .{ "for", .kwd_for },
    .{ "while", .kwd_while },
    .{ "not", .kwd_not },
    .{ "fn", .kwd_fn },
    .{ "and", .kwd_and },
    .{ "or", .kwd_or },
    .{ "self", .kwd_self },
    .{ "type", .kwd_type },
    .{ "is", .kwd_is },
    .{ "return", .kwd_return },
    .{ "luau", .kwd_luau },
    .{ "error", .kwd_error },
    .{ "warn", .kwd_warn },
    .{ "defer", .kwd_defer },
    .{ "await", .kwd_await },
    .{ "try", .kwd_try },
    .{ "catch", .kwd_catch },
    .{ "class", .kwd_class },
    .{ "trait", .kwd_trait },
    .{ "record", .kwd_record },
    .{ "true", .kwd_true },
    .{ "false", .kwd_false },
});

pub const Tokenizer = struct {
    buffer: [:0]const u8,
    index: usize,

    pub fn dump(self: *Tokenizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"", .{ @tagName(token.tag), self.buffer[token.loc.start..token.loc.end] });
    }

    pub fn new(buffer: [:0]const u8) Tokenizer {
        const src_start: usize = 0;
        return Tokenizer{
            .buffer = buffer,
            .index = src_start,
        };
    }

    const State = enum {
        start,
        identifier,
        string_literal_double,
        string_literal_single,
        string_backslash,
        equal,
        bang,
        number,
        number_exponent,
        float,
        float_exponent,
        period,
        pipe,
        question,
    };

    pub fn next(self: *Tokenizer) Token {
        var state: State = .start;
        var token = Token{
            .tag = .eof,
            .loc = .{
                .start = self.index,
                .end = undefined
            }
        };
        //var seen_escape_digits: usize = undefined;
        while (true) : (self.index += 1) {
            const char = self.buffer[self.index];
            switch (state) {
                .start => switch (char) {
                    // End of buffer (null char)
                    0 => {
                        if (self.index != self.buffer.len) {
                            token.tag = .invalid;
                            token.loc.end = self.index;
                            self.index += 1;
                            return token;
                        }
                        break;
                    },
                    // New token start for space, tab, return, newline
                    ' ', '\n', '\t', '\r' => {
                        token.loc.start = self.index + 1;
                    },
                    // start of string literal double quote
                    '"' => {
                        state = .string_literal_double;
                        token.tag = .string_literal;
                    },
                    // start of string literal single quote
                    '\'' => {
                        state = .string_literal_single;
                        token.tag = .string_literal;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .identifier;
                        token.tag = .identifier;
                    },
                    '0'...'9' => {
                        state = .number;
                        token.tag = .number_literal;
                    },
                    '=' => state = .equal,
                    '!' => state = .bang,
                    '?' => state = .question,
                    '|' => state = .pipe,
                    '.' => state = .period,
                    '(' => {
                        token.tag = .l_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        token.tag = .r_paren;
                        self.index += 1;
                        break;
                    },
                    '[' => {
                        token.tag = .l_bracket;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        token.tag = .r_bracket;
                        self.index += 1;
                        break;
                    },
                    ';' => {
                        token.tag = .semicolon;
                        self.index += 1;
                        break;
                    },
                    ',' => {
                        token.tag = .comma;
                        self.index += 1;
                        break;
                    },
                    ':' => {
                        token.tag = .colon;
                        self.index += 1;
                        break;
                    },
                    '{' => {
                        token.tag = .l_brace;
                        self.index += 1;
                        break;
                    },
                    '}' => {
                        token.tag = .r_brace;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .invalid;
                        token.loc.end = self.index;
                        self.index += std.unicode.utf8ByteSequenceLength(char) catch 1;
                        return token;
                    }
                },
                .period => switch (char) {
                    '0'...'9' => {
                        state = .float;
                    },
                    else => {
                        token.tag = .period;
                        break;
                    }
                },
                .number => switch (char) {
                    '.' => {
                        state = .float;
                    },
                    '0'...'9', 'a'...'d', 'f', 'A'...'D', 'F', '_', 'x', 'X' => {},
                    'e', 'E', => state = .float_exponent,
                    else => break
                },
                .number_exponent => switch (char) {
                    '-', '+' => {
                        state = .float;
                    },
                    else => {
                        self.index -= 1;
                        state = .number;
                    },
                },
                .float => switch (char) {
                    '0'...'9', 'a'...'d', 'f', 'A'...'D', 'F', '_', => {},
                    'e', 'E', => state = .float_exponent,
                    else => break
                },
                .float_exponent => switch (char) {
                    '+', '-' => state = .float,
                    else => {
                        self.index -= 1;
                        state = .float;
                    },
                },
                .pipe => switch (char) {
                    '>' => {
                        token.tag = .pipe;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .invalid;
                        break;
                    }
                },
                .question => switch (char) {
                    '?' => {
                        token.tag = .question_mark_question_mark;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .question_mark;
                        break;
                    }
                },
                .bang => switch (char) {
                    '=' => {
                        token.tag = .bang_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .bang;
                        break;
                    }
                },
                .equal => switch (char) {
                    '=' => {
                        token.tag = .is_equal;
                        self.index += 1;
                        break;
                    },
                    '>' => {
                        token.tag = .equal_arrow;
                        self.index += 1;
                        break;
                    },
                    else => {
                        token.tag = .equal;
                        break;
                    },
                },
                .identifier => switch (char) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => {},
                    else => {
                        if (Token.getKeyword(self.buffer[token.loc.start..self.index])) |tag| {
                            token.tag = tag;
                        }
                        break;
                    }
                },
                .string_literal_single => switch (char) {
                    // End char, newline
                    0, '\n' => {
                        token.tag = .string_literal;
                        token.loc.end = self.index;
                        if (self.index != self.buffer.len) {
                            self.index += 1;
                        }
                        return token;
                    },
                    // backslash escape
                    '\\' => {
                        state = .string_backslash;
                    },
                    // end of string
                    '\'' => {
                        self.index += 1;
                        break;
                    },
                    else => {
                        if (self.invalidCharacterLength()) |len| {
                            token.tag = .invalid;
                            token.loc.end = self.index;
                            self.index += len;
                            return token;
                        }

                        self.index += (std.unicode.utf8ByteSequenceLength(char) catch unreachable) - 1;
                    }
                },
                .string_literal_double => switch (char) {
                    // End char, newline
                    0, '\n' => {
                        token.tag = .string_literal;
                        token.loc.end = self.index;
                        if (self.index != self.buffer.len) {
                            self.index += 1;
                        }
                        return token;
                    },
                    // backslash escape
                    '\\' => {
                        state = .string_backslash;
                    },
                    // end of string
                    '"' => {
                        self.index += 1;
                        break;
                    },
                    else => {
                        if (self.invalidCharacterLength()) |len| {
                            token.tag = .invalid;
                            token.loc.end = self.index;
                            self.index += len;
                            return token;
                        }

                        self.index += (std.unicode.utf8ByteSequenceLength(char) catch unreachable) - 1;
                    }
                },
                else => {
                    token.tag = .invalid;
                    token.loc.end = self.index;
                    self.index += std.unicode.utf8ByteSequenceLength(char) catch 1;
                    return token;
                }
            }
        }

        if (token.tag == .eof) {
            token.loc.start = self.index;
        }

        token.loc.end = self.index;
        return token;
    }

    fn invalidCharacterLength(self: *Tokenizer) ?u3 {
        const first_char = self.buffer[self.index];
        if (std.ascii.isASCII(first_char)) {
            if (first_char == '\r') {
                if (self.index + 1 < self.buffer.len and self.buffer[self.index + 1] == '\n') {
                    return null;
                } else {
                    return 1;
                }
            } else if (std.ascii.isControl(first_char)) {
                return 1;
            }

            return null;
        } else {
            const length = std.unicode.utf8ByteSequenceLength(first_char) catch return 1;
            if (self.index + length > self.buffer.len) {
                return @as(u3, @intCast(self.buffer.len - self.index));
            }
            const bytes = self.buffer[self.index .. self.index + length];
            switch (length) {
                2 => {
                    const value = std.unicode.utf8Decode2(bytes) catch return length;
                    if (value == 0x85) return length; // U+0085 (NEL)
                },
                3 => {
                    const value = std.unicode.utf8Decode3(bytes) catch return length;
                    if (value == 0x2028) return length; // U+2028 (LS)
                    if (value == 0x2029) return length; // U+2029 (PS)
                },
                4 => {
                    _ = std.unicode.utf8Decode4(bytes) catch return length;
                },
                else => unreachable,
            }
            return null;
        }
    }
};

test "keywords" {
    try testTokenize("fn local const else", &.{.kwd_fn, .kwd_local, .kwd_const, .kwd_else});
}

test "numbers" {
    try testTokenize("4.94065645841246544177e-324", &.{.number_literal});
    try testTokenize("0xABCDEFe+0.124434", &.{.number_literal});
}

fn testTokenize(source: [:0]const u8, expected_token_tags: []const Token.Tag) !void {
    var tokenizer = Tokenizer.new(source);
    for (expected_token_tags) |expected_token_tag| {
        const token = tokenizer.next();
        try std.testing.expectEqual(expected_token_tag, token.tag);
    }
    const last_token = tokenizer.next();
    try std.testing.expectEqual(Token.Tag.eof, last_token.tag);
    try std.testing.expectEqual(source.len, last_token.loc.start);
    try std.testing.expectEqual(source.len, last_token.loc.end);
}