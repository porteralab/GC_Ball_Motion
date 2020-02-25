# GC_Ball_Motion
Automatically detect speed of a rotating ball from video


-----------------------------------------------------------------------------------------------------------------------------------
BallMotionAnalysis.m
For calculating speeds from a single video
Input: Video and various constants below
Output: Trial speeds (pix/sec) 3 seconds before and 3 seconds after each trial (in variable 'trialSpeed'). 

Note: Hard coded for 60fps capturing camera


Flowthrough:
1. Add video name (must be mp4)
2. Update stim_start_frame, end_frame
3. Load in .mat file containing trial timestamps into the workspace (used to align frames to trial)
3. Setup to 0, find the correct values for thresh_circle and thresh_line by trial-and-error (use cntrl-c to stop execution to update values, repeat until correct)
4. Setup to 1, run fully


Change the following constants:

VID_NAME = name of video, without '.mp4'
STIM_START_FRAME = frame with start of the first stimulus (can tell by seeing reflection of gratings on ball)
END_FRAME = last frame that you want to capture (aprrox when the sessions ends)
MAXIMUM_SPEED (def 40) = max pix distance you want to set as ceiling, can vary depending on camera quality
THRESH_CIRCLE = [x-coord,y-coord,radius], the parameters for the circle outside of which all identified circles will be discarded
THRESH_LINE = [m,b], the slope and x-intercept for line above which all identified circles will be discarded
% [m,b]
% x = m*y + b

SETUP = either 0 or 1; 0 when trial-and-error testing thresh_circle and thresh_line (outputs a debugging figure), 1 when running fully (no debugging output)

------------------------------------------------------------------------------------------------------------------------------------

SerialBallMotionAnalysis.m, SerialBallMotionAnalysisStart.m

Used to process many ball motion videos, say overnight. Bascially, find individual constants for each video using the file above, and then arrange them into a array. I never really used this very much.

