// tink.odin —— tink data-flow node frame protocol (universal, language-agnostic).
//
// Frame = [len u32 BE][payload][crc u32 BE]; crc = CRC32-IEEE (0xEDB88320).
// Mirrors std/tink.tie (tie standard library) and the other-language tink
// libraries; pure procedures over []byte, IO (stdin/stdout) left to the
// caller. Odin, stdlib-only, no dependencies.

package tink

import "core:bytes"
import "core:mem"

// tink_crc32 returns the CRC32-IEEE checksum of a byte slice (bit-loop).
// Check vector: tink_crc32("123456789") == 0xCBF43926.
tink_crc32 :: proc(data: []byte) -> u32 {
	crc: u32 = 0xFFFFFFFF
	for b in data {
		crc ~= u32(b)
		for _ in 0 ..< 8 {
			if crc & 1 != 0 {
				crc = (crc >> 1) ~ 0xEDB88320
			} else {
				crc = crc >> 1
			}
		}
	}
	return (crc ~ 0xFFFFFFFF) & 0xFFFFFFFF
}

// Frame is the result of parsing a frame: payload (copy) and position after.
Frame :: struct {
	payload: []byte,
	next:    int,
}

// tink_frame_encode encodes a payload into [len u32 BE][payload][crc u32 BE].
tink_frame_encode :: proc(payload: []byte, allocator := context.allocator) -> []byte {
	n := len(payload)
	out := make([]byte, n + 8, allocator)
	out[0] = byte(u32(n) >> 24)
	out[1] = byte(u32(n) >> 16)
	out[2] = byte(u32(n) >> 8)
	out[3] = byte(n)
	copy(out[4:], payload)
	c := tink_crc32(payload)
	out[n + 4] = byte(c >> 24)
	out[n + 5] = byte(c >> 16)
	out[n + 6] = byte(c >> 8)
	out[n + 7] = byte(c)
	return out
}

// tink_frame_next parses one frame at pos (verifies CRC). Returns a Frame or
// nil on out-of-bounds / CRC mismatch.
tink_frame_next :: proc(bytes: []byte, pos: int, allocator := context.allocator) -> Maybe(Frame) {
	if pos < 0 || len(bytes) < pos + 8 {
		return nil
	}
	n := tink_be32(bytes[pos:])
	end := pos + 8 + int(n)
	if len(bytes) < end {
		return nil
	}
	payload := bytes[pos + 4 : pos + 4 + int(n)]
	payload_copy := make([]byte, len(payload), allocator)
	copy(payload_copy, payload)
	want := tink_be32(bytes[end - 4:])
	if tink_crc32(payload) != want {
		return nil
	}
	return Frame{payload_copy, end}
}

// tink_frame_skip skips one frame at pos without copying or verifying.
// Returns the position after the frame, or -1 on out-of-bounds.
tink_frame_skip :: proc(bytes: []byte, pos: int) -> int {
	if pos < 0 || len(bytes) < pos + 8 {
		return -1
	}
	n := tink_be32(bytes[pos:])
	end := pos + 8 + int(n)
	if len(bytes) < end {
		return -1
	}
	return end
}

tink_be32 :: proc(b: []byte) -> u32 {
	return u32(b[0]) << 24 | u32(b[1]) << 16 | u32(b[2]) << 8 | u32(b[3])
}