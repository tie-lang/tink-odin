// tink_test.odin —— unit tests for tink.odin. 运行: odin test .
package tink

import "core:testing"

@(test)
crc32_vector :: proc(t: ^testing.T) {
	data := transmute([]byte)string("123456789")
	testing.expect(t, tink_crc32(data) == 0xCBF43926, "crc32 vector")
}

@(test)
frame_roundtrip :: proc(t: ^testing.T) {
	p := []byte{1, 2, 3}
	frame := tink_frame_encode(p)
	testing.expect(t, len(frame) == len(p) + 8, "frame length")
	got := tink_frame_next(frame, 0)
	testing.expect(t, got != nil, "frame present")
	if got != nil {
		g := got.?
		testing.expect(t, g.next == len(frame), "frame next == length")
		testing.expect(t, bytes_equal(g.payload, p), "frame payload roundtrip")
	}
}

@(test)
empty_frame_roundtrip :: proc(t: ^testing.T) {
	fe := tink_frame_encode({})
	ge := tink_frame_next(fe, 0)
	testing.expect(t, ge != nil && ge.?.next == len(fe) && len(ge.?.payload) == 0, "empty frame roundtrip")
}

@(test)
crc_tamper_rejected :: proc(t: ^testing.T) {
	ft := tink_frame_encode([]byte{1, 2, 3})
	ft[4] += 1 // tamper payload[0]
	testing.expect(t, tink_frame_next(ft, 0) == nil, "crc tamper rejected")
}

@(test)
frame_skip_matches_len :: proc(t: ^testing.T) {
	fs := tink_frame_encode([]byte{1, 2, 3})
	testing.expect(t, tink_frame_skip(fs, 0) == len(fs), "frame_skip matches length")
}

@(test)
out_of_bounds :: proc(t: ^testing.T) {
	f := tink_frame_encode([]byte{1, 2, 3})
	testing.expect(t, tink_frame_next(f, len(f)) == nil, "frame_next out of bounds")
	testing.expect(t, tink_frame_skip(f, len(f)) == -1, "frame_skip out of bounds")
	testing.expect(t, tink_frame_next({}, 0) == nil, "frame_next empty input")
}

bytes_equal :: proc(a, b: []byte) -> bool {
	if len(a) != len(b) do return false
	for i in 0 ..< len(a) {
		if a[i] != b[i] do return false
	}
	return true
}