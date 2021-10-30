# 3D-ball-Sim
Balls bounce around in a 3D environment. Built using processing.
Balls will lose energy over time due to collisions.

## How to run 
To run the program, open the sketch named `SID500477551_Ass1b.pde` in processing within the folder `SID500477551_Ass1b`.
Click the `run` button the programming IDE

- add balls by left clicking on the screen with your mouse

## Paramaters:
- `START_VELOCITY `
  - change this to set increase variation in the initial velcoity of the ball (determines trajectory)
- `gravity`
  - change this to alter the accleration factor due to gravity (larger number is more forceful)
  - Can be set to zero
- `ENERGYLOSS`
  - keep 0 < ENERGYLOSS <= 1
  - this is multiplied to velocities as a reduction factor.
- `THRESH`
  - currently at a good value. 
  - determine when balls stop moving.
  

