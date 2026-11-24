# CubeSat power

Can a 3U Earth-observation CubeSat in a 500 km sun-synchronous orbit power its mission?

To run it, set up the examples first: see [Running the examples](../README.md#running-the-examples).

- [`cubesat.sysml`](cubesat.sysml): the model. Each subsystem's power draw in each operating
  mode, the operating modes and what moves the satellite between them, a ground-station pass,
  the satellite's geometry, and two requirements: the battery stays above 70 % charge (EPS-1),
  and at least 8 targets are imaged a day (MIS-1).
- [`cubesat-power.ipynb`](cubesat-power.ipynb): the analysis. It draws the model's standard
  views, simulates the battery minute by minute through a day of orbits, writes the results
  back into the model, and lets the model decide the requirements, with the deployable panels
  and without them. It then finds what limits the number of targets a day.

[![The walkthrough, in VS Code](https://img.youtube.com/vi/QZRdP-I5x-0/maxresdefault.jpg)](https://youtu.be/QZRdP-I5x-0)

A [3-minute walkthrough](https://youtu.be/QZRdP-I5x-0) of the model, the views and the notebook, in VS Code.
