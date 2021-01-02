I started with a P controller.
Under the initial conditions where qi =[0 11 0.8 0.8 1.05], ui =[0 0 0 0 0], 

Kp = 100 Kd = 0.0000 unstable
Kp = 200 Kd = 0.0000 unstable
Kp = 300 Kd = 0.0000 unstable
Kp = 400 Kd = 0.0000 stable
Kp = 500 Kd = 0.0000 stable
Kp = 600 Kd = 0.0000 stable
Kp = 700 Kd = 0.0000 stable
Kp = 800 Kd = 0.0000 stable
Kp = 900 Kd = 0.0000 stable
Kp = 1000 Kd = 0.0000 stable
Kp = 1100 Kd = 0.0000 stable
Kp = 1200 Kd = 0.0000 stable
Kp = 1300 Kd = 0.0000 stable
Kp = 1400 Kd = 0.0000 unstable
Kp = 1500 Kd = 0.0000 unstable

With the lander tilted at a more drastic angle, for instance, qi =[0 11 0.8 0.8 1.1], ui =[0 0 0 0 0], Kp needs to be larger to reach stability.

Kp = 100 Kd = 0.0000 unstable
Kp = 200 Kd = 0.0000 unstable
Kp = 300 Kd = 0.0000 unstable
Kp = 400 Kd = 0.0000 unstable
Kp = 500 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0000 stable
Kp = 700 Kd = 0.0000 stable
Kp = 800 Kd = 0.0000 stable
Kp = 900 Kd = 0.0000 stable
Kp = 1000 Kd = 0.0000 stable
Kp = 1100 Kd = 0.0000 stable
Kp = 1200 Kd = 0.0000 unstable
Kp = 1300 Kd = 0.0000 stable
Kp = 1400 Kd = 0.0000 stable
Kp = 1500 Kd = 0.0000 unstable

If the initial conditions are slightly different, for example, qi =[0 11 0.8 0.8 1.05], ui =[0 0 0 0 0.01], 

Kp = 100 Kd = 0.0000 unstable
Kp = 200 Kd = 0.0000 unstable
Kp = 300 Kd = 0.0000 unstable
Kp = 400 Kd = 0.0000 unstable
Kp = 500 Kd = 0.0000 stable
Kp = 600 Kd = 0.0000 stable
Kp = 700 Kd = 0.0000 stable
Kp = 800 Kd = 0.0000 stable
Kp = 900 Kd = 0.0000 stable
Kp = 1000 Kd = 0.0000 stable
Kp = 1000 Kd = 0.0000 stable
Kp = 1100 Kd = 0.0000 unstable
Kp = 1200 Kd = 0.0000 stable
Kp = 1300 Kd = 0.0000 stable
Kp = 1400 Kd = 0.0000 unstable
Kp = 1500 Kd = 0.0000 unstable

Thus, an appropriate value of Kp should lie between 500 and 1000.

Next, I wanted to test if stability could be enhanced by adding a D controller.