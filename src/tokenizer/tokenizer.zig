// Based on the Zig tokenizer
// https://github.com/ziglang/zig/blob/master/lib/std/zig/tokenizer.zig
// why reinvent the wheel when zig already has a good tokenizer

const std = @import("std");
const Token = @import("token.zig");

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
        var seen_escape_digits: usize = undefined;
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