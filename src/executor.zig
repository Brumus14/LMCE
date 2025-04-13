const std = @import("std");

pub fn execute(program: [100]u16) !void {
    // copy the program into memory
    var memory: [100]u16 = undefined;
    @memcpy(memory[0..], program[0..]);

    var accumulator: i16 = 0;
    var program_counter: u8 = 0;
    var opcode: u8 = undefined;
    var operand: u8 = undefined;

    while (true) {
        // fetch the instruction value from memory
        const instruction = memory[program_counter];
        // opcode is the first digit of the value
        opcode = @truncate(instruction / 100);
        // operand is last 2 digits of the value
        operand = @truncate(instruction % 100);

        // execute the instruction
        switch (opcode) {
            // LDA - load from address into accumulator
            5 => {
                accumulator = @intCast(memory[operand]);
            },

            // STA - store accumulator value into memory location
            3 => {
                memory[operand] = @abs(accumulator);
            },

            // ADD - add value from address into accumulator
            1 => {
                accumulator += @intCast(memory[operand]);
            },

            // SUB - subtract value from address into accumulator
            2 => {
                accumulator -= @intCast(memory[operand]);
            },

            // INP / OUT
            9 => {
                switch (operand) {
                    // INP - read user input into accumulator
                    1 => {
                        // print input prompt
                        try std.io.getStdOut().writer().print("> ", .{});

                        var buffer: [3]u8 = undefined;
                        const input = try std.io.getStdIn().reader().readUntilDelimiter(buffer[0..], '\n');

                        accumulator = @intCast(try std.fmt.parseUnsigned(u16, input, 10));
                    },

                    // OUT - output accumulator
                    2 => {
                        try std.io.getStdOut().writer().print("{d}\n", .{accumulator});
                    },

                    else => {},
                }
            },

            // HLT - stop execution
            0 => {
                if (operand == 0) {
                    break;
                }
            },

            // BRZ - branch if accumulator is zero
            7 => {
                if (accumulator == 0) {
                    program_counter = operand;
                    continue;
                }
            },

            // BRP - branch if accumulator is zero or positive
            8 => {
                if (accumulator >= 0) {
                    program_counter = operand;
                    continue;
                }
            },

            // BRA - branch always
            6 => {
                program_counter = operand;
                continue;
            },

            else => {},
        }

        program_counter += 1;
    }
}
