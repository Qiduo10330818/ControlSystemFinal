Control objective
	stabilize the lander after impact

Block Diagram
	(...draw diagram)
	inputs: voltage of the left and right AMEID
	output: angle between the lander and the ground
	feedback control

Tuning the P controller
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

Tuning the D controller
Next, I wanted to test if stability could be enhanced by adding a D controller.
Kd should be small so as not to push the poles into the RHP.
Setting Kp = 600, I experimented with different values of Kd.

theta0 = 1.1200  
Kp = 600 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0050 stable
Kp = 600 Kd = 0.0100 unstable
Kp = 600 Kd = 0.0150 stable
Kp = 600 Kd = 0.0200 stable
Kp = 600 Kd = 0.0250 stable
Kp = 600 Kd = 0.0300 stable
Kp = 600 Kd = 0.0350 stable
Kp = 600 Kd = 0.0400 stable
Kp = 600 Kd = 0.0450 stable
Kp = 600 Kd = 0.0500 stable

theta0 = 1.1250  
Kp = 600 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0050 unstable
Kp = 600 Kd = 0.0100 unstable
Kp = 600 Kd = 0.0150 unstable
Kp = 600 Kd = 0.0200 unstable
Kp = 600 Kd = 0.0250 stable
Kp = 600 Kd = 0.0300 stable
Kp = 600 Kd = 0.0350 stable
Kp = 600 Kd = 0.0400 stable
Kp = 600 Kd = 0.0450 stable
Kp = 600 Kd = 0.0500 stable

theta0 = 1.1300  
Kp = 600 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0050 unstable
Kp = 600 Kd = 0.0100 unstable
Kp = 600 Kd = 0.0150 unstable
Kp = 600 Kd = 0.0200 unstable
Kp = 600 Kd = 0.0250 unstable
Kp = 600 Kd = 0.0300 unstable
Kp = 600 Kd = 0.0350 unstable
Kp = 600 Kd = 0.0400 stable
Kp = 600 Kd = 0.0450 stable
Kp = 600 Kd = 0.0500 stable

theta0 = 1.1350  
Kp = 600 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0050 unstable
Kp = 600 Kd = 0.0100 unstable
Kp = 600 Kd = 0.0150 unstable
Kp = 600 Kd = 0.0200 unstable
Kp = 600 Kd = 0.0250 unstable
Kp = 600 Kd = 0.0300 unstable
Kp = 600 Kd = 0.0350 unstable
Kp = 600 Kd = 0.0400 unstable
Kp = 600 Kd = 0.0450 unstable
Kp = 600 Kd = 0.0500 stable

stab = 97   100    98    97    97    99   103   107   109   116

Kp_test = 100:100:10000;
th_0 = 0:0.1:1.57

stab =

  Columns 1 through 23

    10    10    10    10     9    10    11    11    11    12    11    10     9     9     8     8     8     9    10     9     8     9     9

  Columns 24 through 46

     9     9     9     9     9    10     9    10     9     9     9     9     9     9     9     8     8     9     8     9     8     8     8

  Columns 47 through 69

     8     8     8     8     8     8     8     8     8     8     8     8     8     8     8     8     7     8     7     8     8     8     8

  Columns 70 through 92

     7     8     7     7     7     7     7     7     6     7     7     7     7     7     7     7     7     7     7     7     7     7     7

  Columns 93 through 100

     7     7     7     7     7     8     7     7