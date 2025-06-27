# <proj_name>

To use this template, clone it. Go through `README.md`, `build.zig`, and
`build.zig.zon` and change all occurrences of `<proj_name>` to your project's
name. Also change the name of the folder (e.g. zig-raylib-template ->
<proj_name>).

Run `devpod up . --dotfiles-script-env "MODE=c"` to create the dev container.
Then run `ssh <proj_name>.devpod` to enter into the container.

To allow for the project to be built, run `zig build run` and copy the
fingerprint that the error output suggests. Copy this into `build.zig.zon` with
the following format:
```zig
{
    .fingerprint = <fingerprint>
}
```

Requirements:
- [devpod](http://devpod.sh)
