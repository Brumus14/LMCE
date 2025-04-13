const std = @import("std");

pub fn readFile(path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    // read whole file
    const contents: []u8 = try file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(usize));

    return contents;
}
