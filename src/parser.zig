const std = @import("std");

pub fn parse(program: []u8) [100][3]?[]const u8 {
    // split the program into lines
    var line_iterator = std.mem.split(u8, program, "\n");

    // each LMC program line can be split into at most 3 segments_count
    // there are 100 available memory locations
    var segments = [1][3]?[]const u8{[1]?[]const u8{null} ** 3} ** 100;
    var segments_count: u8 = 0;

    line_loop: while (line_iterator.next()) |line| {
        var segment_count: u8 = 0;
        var start: usize = undefined;
        var length: usize = 0;

        for (line, 0..) |c, i| {
            // character is a segment character
            if (c != ' ' and !(c == '/' and line[i + 1] == '/')) {
                // start a new segment
                if (length == 0) {
                    start = i;
                }

                length += 1;
            }

            // finish and add the segment
            if ((c == ' ' or (c == '/' and line[i + 1] == '/') or i == line.len - 1) and length > 0) {
                segments[segments_count][segment_count] = line[start..(start + length)];
                segment_count += 1;
                length = 0;
            }

            // start of a comment
            if (c == '/' and line[i + 1] == '/') {
                // line isn't empty
                if (segment_count > 0) {
                    segments_count += 1;
                }

                // skip to the next line
                continue :line_loop;
            }
        }

        // line isn't empty
        if (segment_count > 0) {
            segments_count += 1;
        }
    }

    return segments;
}
