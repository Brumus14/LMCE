const std = @import("std");

pub fn generate(segments: *[100][3]?[]const u8) ![100]u16 {
    var instructions = std.StringHashMap(u16).init(std.heap.page_allocator);

    // generate the map of mneumonics to instruction values
    // operands will be added on later as needed
    inline for (.{
        .{ "LDA", 500 },
        .{ "STA", 300 },
        .{ "ADD", 100 },
        .{ "SUB", 200 },
        .{ "INP", 901 },
        .{ "OUT", 902 },
        .{ "HLT", 0 },
        .{ "BRZ", 700 },
        .{ "BRP", 800 },
        .{ "BRA", 600 },
    }) |instruction| {
        try instructions.put(instruction[0], instruction[1]);
    }

    // map for label names to memory locations
    var labels = std.StringHashMap(u8).init(std.heap.page_allocator);

    // find and add labels and remove from segments
    for (segments, 0..) |s, i| {
        if (instructions.get(s[0] orelse continue) == null) {
            try labels.put(s[0].?, @truncate(i));

            // shift segments to remove label
            segments[i][0] = segments[i][1];
            segments[i][1] = segments[i][2];
            segments[i][2] = null;
        }
    }

    // the generated program values
    var program: [100]u16 = [1]u16{0} ** 100;

    // iterate through segment lines
    for (segments, 0..) |line, i| {
        // skip empty lines
        if (line[0] == null) {
            continue;
        }

        if (std.mem.eql(u8, line[0].?, "DAT")) {
            // if a value is provided
            if (line[1] != null) {
                program[i] = try std.fmt.parseUnsigned(u16, line[1].?, 10);
            }
        } else {
            // translate mneumonic into its numerical value
            program[i] = instructions.get(line[0].?).?;

            // check if an operand is required
            if (program[i] > 0 and program[i] % 100 == 0) {
                // parse and add the operand to the instruction value
                // if segment cannot be parsed get its labels value
                program[i] += std.fmt.parseUnsigned(u8, line[1].?, 10) catch labels.get(line[1].?).?;
            }
        }
    }

    return program;
}
