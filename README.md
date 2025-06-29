# zig-mcl

A MCL simulation implementation in Zig using Raylib.

To Do:
[ ] Add headings to robots/particles (circles -> rectangles)
[ ] Add obstacles
[ ] Make sensors use ray tracing to nearest wall
[ ] Reorganize the types:
```zig
Robot {
    .rec: rl.Rectangle,
    .center: rl.Vector2,
    .heading: f32,
    .sensors: [4]Sensor,
}

Sensor {
    pub fn distance() f32 {}
}

Wall {
    .start: rl.Vector2,
    .end: rl.Vector2,
    .width: i32,
}
```
