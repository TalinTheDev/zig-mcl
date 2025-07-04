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
both axes, to simulate a real life robot. All the green dots represent the
simulated particles that the robot would be creating to run MCL and based on
those, the pink dot represents the position of the robot as estimated by MCL. 

To move the robots around, use W/A/S/D or arrow keys for movement (the small black dots on the
circle represent the front).

A good run will eventually look like this: 
![A screenshot of the simulation running](/latestRun.png)

I'm from @TalinTheDev's VEX team (765A), and I've expanded upon his implementation
of MCL. After way too much research on particle filters, I think I finally understand
how it works. There are still a lot of ways to improve this, but I think I've brought
it up to the point where we could conceivably use this for an actual VEX robot. A big
thing I've changed is asteroids-style movement instead of eight-way movement so that
it feels more like how an actual robot would move. I also think that the biggest
improvement comes from the resampling algorithm that I used, called low-variance
resampling, which you can search up. Finally, in order to handle particle degeneracy,
I used the effective sample size (N eff) to slow down resampling. There are a couple
of tuning constants that will need to be adjusted in order to give the optimal
performance.

Still don't try kidnapping (teleporting it to a random position) the robot,
because you will still be disappointed. And also because I haven't implemented
handling the case where the particles go too far away from the robot.

Some factors could affect MCL that I'm not sure how we would be able to
fix if we use it for VEX, like other robots on the field, irregular obstacles,
and symmetry, but those are problems for another time.

## Running Simulation
To run, install Zig v0.14.0 in VSCode and then run: `zig build run`.

## Credits
Other than @TalinTheDev's links, most of my info came from good old Google Search so no way I'm putting all those in here:
- [Particle Filters | Robot
  Localization](https://www.youtube.com/watch?v=ydC0mE0ZYSA)
- [Creating A 2D Ray Caster: Simulating
  Light.](https://medium.com/@apoorvaencoder/creating-a-2d-ray-caster-simulating-light-3ea150ce3435)
- [Raylib](https://www.raylib.com/)
- [Zig](https://ziglang.org/)
- [Raylib Zig Bindings](https://github.com/Not-Nik/raylib-zig)
- [zprob](https://github.com/pblischak/zprob)
- [2654E Echo's code](https://github.com/alexDickhans/echo/tree/main)

## License
Just the [Apache-2.0 license](https://www.apache.org/licenses/LICENSE-2.0.txt)

I just ask that if you use our code or are heavily inspired by it, give us a
little bit of credit.

## Roadmap

v1.0.0 - WIP
- [x] Basic field setup
- [x] Basic robots w/ movement & collision
- [x] Translational & rotational movement that is taken into account for MCL
- [x] Not bad MCL implementation
- [ ] Clean code including comments, structure, neatness (Can you put a half checkmark?)
