const std = @import("std");
const reader = @import("reader.zig");
const parser = @import("parser.zig");
const generator = @import("generator.zig");
const executor = @import("executor.zig");

pub fn main() !void {
    // command line argument iterator
    var args = std.process.args();
    // skip the executable argument
    _ = args.next();

    // read the program file
    const contents = try reader.readFile(args.next().?);

    // parse the program
    var segments = parser.parse(contents);
    // generate the program into a series of integer values
    const program = try generator.generate(&segments);
    // execute the generated program
    try executor.execute(program);
}
