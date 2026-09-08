# tink-odin

tink data-flow node frame protocol — Odin package (stdlib-only, no
dependencies). Universal and language-agnostic: any component that obeys the
frame protocol can join a tink pipeline.

```
帧 = [ len: u32 BE ][ payload: len 字节 ][ crc: u32 BE ]
len = payload 字节数
crc = CRC32-IEEE(payload)（多项式 0xEDB88320）
```

Mirrors `std/tink.tie` (tie standard library) and the other-language tink
libraries; pure procedures over `[]byte`, IO (stdin/stdout) left to the
caller. Names follow the Odin convention (`tink_` prefix, snake_case to avoid
conflicts at package scope).

## API

| procedure | description |
| --- | --- |
| `tink_crc32(data) -> u32` | CRC32-IEEE over a byte slice. Check vector: `tink_crc32("123456789") == 0xCBF43926` |
| `tink_frame_encode(payload) -> []byte` | encode a payload into a full frame `[len][payload][crc]` |
| `tink_frame_next(bytes, pos) -> Maybe(Frame)` | parse one frame at `pos`, verify CRC; `Frame(payload, next)` on success, `nil` on out-of-bounds / mismatch |
| `tink_frame_skip(bytes, pos) -> int` | skip one frame at `pos` without copying or verifying; `-1` on out-of-bounds |

## Usage

```odin
package main
import "tink"

frame := tink.tink_frame_encode([]byte{1, 2, 3})
got := tink.tink_frame_next(frame, 0) // Maybe(tink.Frame)
```

## Test

```bash
odin test .
```

## Cross-language

tink 帧协议各语言实现（API 语义与校验向量一致）：

| language | library |
| --- | --- |
| tie | `std/tink.tie` |
| Rust | `tink-rust`（tink crate） |
| C | `tink-c`（`tink.h` + `tink.c`） |
| Python | `tink-python`（`tink.py`） |
| JavaScript | `tink-js`（`tink.js` + `tink.d.ts`） |
| C++ | `tink-cpp`（`tink.hpp`） |
| Java | `tink-java`（`org.tielang.tink`） |
| C# | `tink-csharp`（namespace `Tink`） |
| Go | `tink-go`（package `tink`） |
| Zig | `tink-zig`（`tink.zig`） |
| Lua | `tink-lua`（`tink.lua`） |
| GDScript | `tink-godot`（`tink.gd`） |
| F# | `tink-fsharp`（`Tink.fs`） |
| PowerShell | `tink-powershell`（`tink.ps1`） |
| Kotlin | `tink-kotlin`（`Tink.kt`） |
| Ruby | `tink-ruby`（`tink.rb`） |
| Julia | `tink-julia`（`tink.jl`） |
| Nim | `tink-nim`（`tink.nim`） |
| Dart | `tink-dart`（`tink.dart`） |
| Crystal | `tink-crystal`（`tink.cr`） |
| PHP | `tink-php`（`tink.php`） |
| V | `tink-v`（`tink.v`） |
| Odin | this package（`tink-odin`） |

## License

本仓库使用 **Tie Public License v2.0 (TPL 2.0)**，完整文本见 [LICENSE](LICENSE)。
This repository is distributed under the **Tie Public License v2.0 (TPL 2.0)** — see [LICENSE](LICENSE) for the full text.