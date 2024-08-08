const builtin = @import("builtin");

pub const os_tag = builtin.target.os.tag;
pub const cpu_arch = builtin.target.cpu.arch;
pub const cpu_endianness = builtin.target.cpu.arch.endian();
pub const build_mode = builtin.mode;

pub const Type = @TypeOf(@typeInfo(type));
pub const CallingConvention = @TypeOf(@typeInfo(fn () void).Fn.calling_convention);

pub fn nativeToLittle(comptime T: type, x: T) T {
    return if (cpu_endianness == .little) x else @byteSwap(x);
}

pub fn asciiToUtf16LeStringLiteral(comptime ascii: []const u8) *const [ascii.len:0]u16 {
    return comptime blk: {
        var utf16le: [ascii.len:0]u16 = undefined;
        for (&utf16le, ascii) |*out, in| out.* = nativeToLittle(u16, in);
        const result = utf16le;
        break :blk &result;
    };
}

pub fn zeroInit(comptime T: type, args: anytype) T {
    var result: T = undefined;
    inline for (@typeInfo(T).Struct.fields) |field| {
        @field(result, field.name) = if (@hasField(@TypeOf(args), field.name))
            switch (@typeInfo(field.type)) {
                .Struct => zeroInit(field.type, @field(args, field.name)),
                else => @field(args, field.name),
            }
        else if (field.default_value) |default_value|
            @as(*align(1) const field.type, @ptrCast(default_value)).*
        else
            @as(*align(1) const field.type, @ptrCast(&[_]u8{0} ** @sizeOf(field.type))).*;
    }
    return result;
}

pub fn BoundedArray(comptime T: type, comptime N: comptime_int) type {
    return struct {
        buf: [N]T = undefined,
        len: usize = 0,

        pub fn append(self: *@This(), data: T) !void {
            if (self.len >= self.buf.len) return error.FullCapacity;
            self.buf[self.len] = data;
            self.len += 1;
        }

        pub fn clear(self: *@This()) void {
            self.len = 0;
        }

        pub fn slice(self: *@This()) []T {
            return self.buf[0..self.len];
        }

        pub fn constSlice(self: @This()) []const T {
            return self.buf[0..self.len];
        }
    };
}

pub fn FnsToFnPtrs(comptime T: type) type {
    return comptime blk: {
        var fields: [@typeInfo(T).Struct.decls.len]Type.StructField = undefined;
        for (&fields, @typeInfo(T).Struct.decls) |*field, decl| {
            const decl_type = @TypeOf(@field(T, decl.name));
            field.* = if (@typeInfo(decl_type) == .Fn)
                .{
                    .name = decl.name,
                    .type = *const decl_type,
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf(*const decl_type),
                }
            else
                .{
                    .name = decl.name,
                    .type = decl_type,
                    .default_value = &@field(T, decl.name),
                    .is_comptime = true,
                    .alignment = @alignOf(decl_type),
                };
        }
        break :blk @Type(.{ .Struct = .{
            .layout = .auto,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        } });
    };
}
