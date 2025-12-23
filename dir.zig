const std = @import("std");

pub fn main() !void {
    try createDir();
}

fn createDir() !void {
    const mode = 0o755;
    const path = "/tmp/zig-tmp";

    if (std.posix.mkdir(path, mode)) {
        std.debug.print("dir created: {s}\n", .{path});
    } else |err| switch (err) {
        error.PathAlreadyExists => {
            std.debug.print("PathAlreadyExists: {any}\n", .{err});
        },
        error.SystemResources => {
            std.debug.print("SystemResources: {any}\n", .{err});
        },
        error.AccessDenied => {
            std.debug.print("error.AccessDenied: {any}\n", .{err});
        },
        error.Unexpected => {
            std.debug.print("error.Unexpected: {any}\n", .{err});
        },
        error.PermissionDenied => {
            std.debug.print("error.PermissionDenied: {any}\n", .{err});
        },
        error.FileNotFound => {
            std.debug.print("error.FileNotFound: {any}\n", .{err});
        },
        error.NoDevice => {
            std.debug.print("error.NoDevice: {any}\n", .{err});
        },
        error.NameTooLong => {
            std.debug.print("error.NameTooLong: {any}\n", .{err});
        },
        error.InvalidUtf8 => {
            std.debug.print("error.InvalidUtf8: {any}\n", .{err});
        },
        error.InvalidWtf8 => {
            std.debug.print("error.InvalidWtf8: {any}\n", .{err});
        },
        error.BadPathName => {
            std.debug.print("error.BadPathName: {any}\n", .{err});
        },
        error.NetworkNotFound => {
            std.debug.print("error.NetworkNotFound: {any}\n", .{err});
        },
        error.SymLinkLoop => {
            std.debug.print("error.SymLinkLoop: {any}\n", .{err});
        },
        error.NoSpaceLeft => {
            std.debug.print("error.NoSpaceLeft: {any}\n", .{err});
        },
        error.NotDir => {
            std.debug.print("error.NotDir: {any}\n", .{err});
        },
        error.DiskQuota => {
            std.debug.print("error.DiskQuota: {any}\n", .{err});
        },
        else => {
            std.debug.print("handle other errors: {any}\n", .{@TypeOf(err)});
        },
    }
}
