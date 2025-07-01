# zig-mcl

A MCL simulation implementation in Zig using Raylib.

## What is it?
Monte Carlo localization is a type of particle filter used in robotics to allow
robots to locate their position in their enviornemtn using simulated particles.
To read more about MCL, start off with this amazing video [Particle Filters |
Robot Localization](https://www.youtube.com/watch?v=ydC0mE0ZYSA) (also linked in
Credits below). Then you can read the [Wikipedia page on
MCL](https://en.wikipedia.org/wiki/Monte_Carlo_localization) for more
information.

After that, good luck!

This is a simulation of MCL written in Zig and rendered using Raylib. The orange
circle (hidden at first), represents the robot's position based directly off of
the user's inputs. The blue circle represents this position but with an error on
both axes, to simulate a real life robot. All the green dots represent the
simulated particles that the robot would be creating to run MCL and based on
those, the pink dot represents the position of the robot as estimated by MCL. 

To move the robots around, use W/A/S/D for translational movement (x/y axis) and
use the left/right arrow keys to turn the robots (the small black dots on the
circle represent the front).

A good run will eventually look like this (not guaranteed because of my cooked
implementation): 
![A screenshot of the simulation running](/latestRun.png)

My simulation/implementation is far from perfect and there are many, many, many
better alternatives to look at if you want to just blindly copy the code. But
this was a fun challenge for me and I learned a lot while making it. Considering
how much I knew about MCL when I started 3 days ago (none), I'm pretty happy
with how decently okay this has turned out. But again, don't expect anything
crazy when you run the simulation. It runs decently well until it breaks.
Sometimes it doesn't start off great and doesn't fix itself for a long time.
That's okay, trust. It'll eventually find its way over to the correct position.
Might not hold it for long but unless something comes in the way, once its on
the right position, it doesn't usually leave it.

Oh also, don't try kidnapping (teleporting it to a random position) the robot.
You will be disappointed.

I started this with the goal to eventually use MCL in my VEXv5 team (765A)'s
bot. Don't know if we will be doing that but the field is setup to somewhat
resemble the field for the 2025-2026 game, Push Back (no parking spots though).

My code, by the way, is very much not optimized because I was focusing more on
the MCL implementation and getting this working ASAP so some parts of this are
quite ugly and very expensive. But, 2000 particles at 10 FPS (which I think is
reasonable for a VEX v5 brain - 100ms between frames) is still good enough for
me for now.

## Running Simulation
To run, install Zig v0.14.0 and then run: `zig build run`.

I will, at some point, upload pre-built releases executables to Github but too
lazy at the moment.

## Developing
For development, a dev container has been setup for use with
[devpod.sh](devpod.sh). Haven't tested it with any other setups other than mine
so it's not guaranteed to work.

To develop inside the pre configured dev container:
```bash
git clone http://github.com/TalinTheDev/zig-mcl.git # Or
git@github.com:TalinTheDev/zig-mcl.git
cd zig-mcl
devpod up . --dotfiles git@github.com:TalinTheDev/dotfiles --dotfiles-script setup --dotfiles-script-env "MODE=c"
ssh zig-mcl.devpod

zig version # Should print 0.14.0
```

## Credits
Quick links (just for now, will try to update later to include everything I used
and give proper credits) to resources, tools, and more:
- [Particle Filters | Robot
  Localization](https://www.youtube.com/watch?v=ydC0mE0ZYSA)
- [Creating A 2D Ray Caster: Simulating
  Light.](https://medium.com/@apoorvaencoder/creating-a-2d-ray-caster-simulating-light-3ea150ce3435)
- [Raylib](https://www.raylib.com/)
- [Zig](https://ziglang.org/)
- [Raylib Zig Bindings](https://github.com/Not-Nik/raylib-zig)
- [zprob](https://github.com/pblischak/zprob)

## License
Just the [Apache-2.0 license](https://www.apache.org/licenses/LICENSE-2.0.txt)

I just ask that if you use my code or are heavily inspired by it, give me a
little bit of credit. Be reasonably, honest, and a good human being. Other than
that, I made it public didn't I?

## Roadmap

v1.0.0 - WIP
- [x] Basic field setup
- [x] Basic robots w/ movement & collision
- [x] Translational & rotational movement that is taken into account for MCL
- [x] Decently okay MCL implementation
- [ ] Clean code including comments, structure, neatness
