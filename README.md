# zig-mcl

A MCL simulation implementation in Zig using Raylib.

## What is it?
Monte Carlo localization is a type of particle filter used in robotics to allow
robots to locate their position in their environment using simulated particles.
To read more about MCL, start off with this amazing video [Particle Filters |
Robot Localization](https://www.youtube.com/watch?v=ydC0mE0ZYSA) (also linked in
Credits below). Then you can read the [Wikipedia page on
MCL](https://en.wikipedia.org/wiki/Monte_Carlo_localization) for more
information.

After that, good luck!

This is a simulation of MCL written in Zig and rendered using Raylib. The orange
circle (hidden at first), represents the robot's position based directly off of
the user's inputs. The blue circle represents this position but with an error on
all axes, to simulate a real life robot. All the green dots represent the
simulated particles that the robot would be creating to run MCL and based on
those, the pink dot represents the position of the robot as estimated by MCL. 

To move the robots around, use W/S for forward/backwards movement and A/D or
arrow keys for rotation (the small black dots on the circle represent the
front).

A good run will eventually look like this: ![A screenshot of the simulation
running](/latestRun-v2.png)

### Talin's v1.0.0 Notes
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
I did add some other random obstacles around the field however to help with MCL
working because (and I realize this is an issue I will face with the VEX
implementation), the Push Back field is very symmetrical and MCL often gets
lost.

My code, by the way, is very much not optimized because I was focusing more on
the MCL implementation and getting this working ASAP so some parts of this are
quite ugly and very expensive. But, 2000 particles at 10 FPS (which I think is
reasonable for a VEX v5 brain = ~100ms between frames) is still good enough for
me for now.

### Alex's v2.0.0 Notes
I'm from @TalinTheDev's VEX team (765A), and I've expanded upon his
implementation of MCL. After way too much research on particle filters, I think
I finally understand how it works. There are still a lot of ways to improve
this, but I think I've brought it up to the point where we could conceivably use
this for an actual VEX robot. A big thing I've changed is asteroids-style
movement instead of eight-way movement so that it feels more like how an actual
robot would move. I also think that the biggest improvement comes from the
resampling algorithm that I used, called low-variance resampling, which you can
search up. Finally, in order to handle particle degeneracy, I used the effective
sample size (N eff) to slow down resampling. There are a couple of tuning
constants that will need to be adjusted in order to give the optimal
performance.

Still don't try kidnapping (teleporting it to a random position) the robot,
because you will still be disappointed. And also because I haven't implemented
handling the case where the particles go too far away from the robot.

Some factors could affect MCL that I'm not sure how we would be able to fix if
we use it for VEX, like other robots on the field, irregular obstacles, and
symmetry, but those are problems for another time.

## Running Simulation
To run, install Zig v0.14.0 and then run: `zig build run`.

I will, at some point, upload pre-built releases executables to Github but too
lazy at the moment.

## Credits
### Contributors
- @TalinTheDev
- @alex-oh205

### Quick links
  - [Particle Filters | Robot
    Localization](https://www.youtube.com/watch?v=ydC0mE0ZYSA)
  - [Creating A 2D Ray Caster: Simulating
    Light.](https://medium.com/@apoorvaencoder/creating-a-2d-ray-caster-simulating-light-3ea150ce3435)
  - [Raylib](https://www.raylib.com/)
  - [Zig](https://ziglang.org/)
  - [Raylib Zig Bindings](https://github.com/Not-Nik/raylib-zig)
  - [zprob](https://github.com/pblischak/zprob)
  - [2654E Echo's code](https://github.com/alexDickhans/echo/tree/main)
  - A lot of googling

## License
Just the [Apache-2.0 license](https://www.apache.org/licenses/LICENSE-2.0.txt)

I just ask that if you use our code or are heavily inspired by it, give us a
little bit of credit. Be reasonable, honest, and a good human being.

## Roadmap
v1.0.0 (Talin's Original Implementation)
  - [x] Basic field setup
  - [x] Basic robots w/ movement & collision
  - [x] Translational & rotational movement that is taken into account for MCL
  - [x] Decently okay MCL implementation
  - [ ] Clean code including comments, structure, neatness
    - Alex worked on v2.0.0 before I could get around to this so skipping for now

v2.0.0 (Alex's Updates)
  - [x] New movement system to use asteroids-style movement
  - [x] New resampling algorithm (Low-Variance resampling)
  - [x] Handling of particle degeneration using N_eff
  - [x] Not bad MCL implementation (much better from v1.0.0)

v2.1.0
  - [ ] Clean code including comments, structure, neatness, and a proper config
