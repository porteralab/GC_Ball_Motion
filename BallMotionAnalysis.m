%Code to Determine Speed from Ball Motion Videos
%Developed by Gunvant Chaudhari, 2017

%Possible Improvements
% - exclude extreme distance values
% - possible exclude distances by direction of displacement (as direction
%   should be fairly uniform)




%--------------------------------------------------------------------------
% MAT_NAME,VID_NAME,STIM_START_FRAME,END_FRAME,MAXIMUM_SPEED,TRIALS,THRESH_CIRCLE,THRESH_LINE

% CONSTANTS

VID_NAME = 'AudDistract_CO7_042818';

STIM_START_FRAME = 5294;
END_FRAME = 122300;

MAXIMUM_SPEED = 40;

THRESH_CIRCLE = [700,455,220];
THRESH_LINE = [-0.25,815];
% [m,b]
% x = m*y + b

SETUP = 0;



%--------------------------------------------------------------------------
% DOT IDENTIFYING CODE

num_trials = size(META_stimstart,1);

% Load the video file
ball_motion_vid = VideoReader(['Videos\' VID_NAME '.mp4']);

% Note, startf != STIM_START_FRAME when the first trial is negative
START_FRAME = STIM_START_FRAME;
if START_FRAME<=0
    START_FRAME = 1;
end
if SETUP == 1
    END_FRAME = START_FRAME+500;
end

% Find frame number for every stimulus start times
gunvantTimes = META_stimstart(1:num_trials,4)*3600 + META_stimstart(1:num_trials,5)*60 + META_stimstart(1:num_trials,6);
gunvantTimes = gunvantTimes(1:num_trials)-gunvantTimes(1,1);
gunvantFrames = zeros(size(gunvantTimes,1),1);
gunvantFrames(1) = STIM_START_FRAME;
for i = 2:size(gunvantTimes,1)
    diff = gunvantTimes(i,1)-gunvantTimes(i-1,1);
    gunvantFrames(i) = (gunvantFrames(i-1) + (diff*60));
end
gunvantFrames = round(gunvantFrames);

% Initialize raw data matrix to decrease computing time
myCircles = zeros(50,(END_FRAME-START_FRAME)*3);

tic
% Looping through all frames to identify all circles
for frame = START_FRAME:END_FRAME
  
    bw = read(ball_motion_vid,frame);
        
    % The GOD function: change Sensitivity to reduce noise, Edge Threshold
    % to identify more circles
    [centers,radii] = imfindcircles(bw,[14,24],'ObjectPolarity','dark','Sensitivity',0.85,'Method','TwoStage','EdgeThreshold',.045); %the god function
    %changed from [7,12]

     myCircles(1:min(50,size(centers,1)),(frame*3-2):frame*3-1) = centers;
     myCircles(1:min(50,size(radii,1)),frame*3) = radii;
    
    if SETUP == 1
        imshow(bw);
        i = viscircles(centers,radii);
            if exist('line','var') == 1
            clearvars line;
            end
        viscircles(THRESH_CIRCLE(1,1:2),THRESH_CIRCLE(1,3))
        line([THRESH_LINE(1)*720+ THRESH_LINE(2), THRESH_LINE(2)],[720,0], 'Color', 'red')
        drawnow;
%         [myF, Map] = frame2im(getframe(gcf));
%         writeVideo(V,myF);
    end

    if mod(frame,10) == 0
        disp(frame)
    end
end
disp(toc)

if SETUP == 1
    if exist('line','var') == 1
        clearvars line;
    end
    viscircles(THRESH_CIRCLE(1,1:2),THRESH_CIRCLE(1,3))
    line([THRESH_LINE(1)*480+ THRESH_LINE(2), THRESH_LINE(2)],[480,0], 'Color', 'red')
end






%-------------------------------------------------------------------------
% ANALYSIS CODE

%Possible Improvements: Exclude based on angle and dist and radii (med+xsd)

for x = 3:3:size(myCircles,2)
    for y = 1:size(myCircles,1)
        value = [myCircles(y,x-2),myCircles(y,x-1),myCircles(y,x)];
        dist = sqrt((value(1)-THRESH_CIRCLE(1))^2 + (value(2)-THRESH_CIRCLE(2))^2);
        if dist>THRESH_CIRCLE(1,3)
            myCircles(y,x-2:x) = [0,0,0];
        end
        
        linex = THRESH_LINE(1)*value(2)+THRESH_LINE(2);
        if linex > value(1)
             myCircles(y,x-2:x) = [0,0,0];
        end
        
    end
end


%Simplify overlapping circles
for x = 3:3:size(myCircles,2)
    for y = 1:size(myCircles,1)
       value = [myCircles(y,x-2),myCircles(y,x-1),myCircles(y,x)];
       
        for i = 1:size(myCircles,1)
            value2 = [myCircles(i,x-2),myCircles(i,x-1),myCircles(i,x)];
            if (~(isequal(value2,value)) && ~(isequal(value2,[0,0,0])))
                dist = sqrt((value(1)-value2(1))^2 + (value(2)-value2(2))^2);
                radiiSum = value(3) + value2(3);
                if (dist<radiiSum)
                    midpoint = [ (value(1)+value2(1))/2 , (value(2)+value2(2))/2, radiiSum/2];
                    myCircles(y,x-2:x) = [0,0,0];
                    myCircles(i,x-2:x) = midpoint;
                                        
                end
            end
        end
    end
    
    if(mod(x,10000)==0)
        disp(x)
    end
end
disp('done1')


%filter circles based on #
%rationale: the closest circle in next frame is the just that circle moved
dist = zeros(size(myCircles,1),size(myCircles,2)/3);
angles = zeros(size(myCircles,1),size(myCircles,2)/3);
indicies = zeros(size(myCircles,1),size(myCircles,2)/3);
for x = 4:3:size(myCircles,2)
    for y = 1:size(myCircles,1)
        value = [myCircles(y,x),myCircles(y,x+1)];
        if ~isequal(value,[0,0])
            index = -1;
            minDist = 99999.0;
            angle = 0;
            lists = myCircles(1:size(myCircles,1),x-3:x-2);
            for i = 1:size(lists,1)
                listVal = lists(i,1:2);
                if ~(isequal(listVal,[0,0]))
                    thisDist = sqrt((value(1)-listVal(1))^2 + (value(2)-listVal(2))^2);
                    if thisDist<minDist
                        minDist = thisDist;
                        index = i;
                        angle = atan((value(2)-listVal(2))/(value(1)-listVal(1)));
                        if (value(1)<listVal(1))
                            angle = angle + pi;        
                        end
                    end
                end
            end
            dist(y,(x-1)/3) = minDist;
            if(~isnan(angle))
                angles(y,(x-1)/3) = angle;
            else
                angles(y,(x-1)/3) = 0;
            end
            if (index~=-1)
                closest = myCircles(index,x-3:x-2);
                indicies(y,(x-1)/3) = index;
            end            
        end
    end
    if(mod(x,10000)==0)
        disp(x)
    end
end
disp('done2')


%reflect the changes of dist
%remove the term that has the max distance
%repeat for each each circle
distPruned = dist;
for c=4:3:size(myCircles,2)
   
    circ1 = 0; %number of circles in previous frame
    for x = 1:size(myCircles,1)
        value = [myCircles(x,c-3),myCircles(x,c-2)];
        if ~isequal(value,[0,0])
            circ1 = circ1 + 1;
        end
    end
    
    circ2 = 0; %number of circles in next frame 
    for x = 1:size(myCircles,1)
        value = [myCircles(x,c),myCircles(x,c+1)];
        if ~isequal(value,[0,0])
            circ2 = circ2 + 1;
        end
    end
    
    %remove the max n distances, where n is circ2-circ1
    if circ2>circ1
        for each = 1:(circ2-circ1)
            [maxv, maxi] = max(distPruned(1:size(distPruned,1),(c-1)/3));
            distPruned(maxi,(c-1)/3) = 0;
            angles(maxi,(c-1)/3) = 0;
        end
    end
    
    if(mod(c,10000)==0)
        disp(c)
    end
end
disp('done3')


% Take 6 frames (0.1s)
% 1. consolidate 6 frames' data into a list
% 2. take the median of these frames, store into list
medians = zeros(floor(size(distPruned,2)/6),1);
medianAngs = zeros(floor(size(distPruned,2)/6),1);
for x=6:6:size(distPruned,2)
    consolidated = [];
    consolidatedAngs = [];
    for c = x-5:x
        for r = 1:size(distPruned,1)
            val  = distPruned(r,c);
            if val~=0
                consolidated = [consolidated,val];
            end
            ang = angles(r,c);
            if ang~=0
                consolidatedAngs = [consolidatedAngs,ang];
            end
            
        end
    end
    tempMed = median(consolidated);
    if(isnan(tempMed))
        tempMed = MAXIMUM_SPEED;
    end
    
    if(tempMed>MAXIMUM_SPEED)
        tempMed = MAXIMUM_SPEED;
        disp('adjustment necessary')
    end
        
    medians(x/6) = tempMed;
    medianAngs(x/6) = median(consolidatedAngs);
    
    if(mod(x,10000)==0)
        disp(x)
    end
end
disp('done4')

figure
plot(medians);


% ALIGN SPEEDS TO TRIALS
% Note: start at trial 2
% 1. have array of trial ranging from -3s to 2.9s,at 0.1s increments
% 2. find what speed(s) is there for that 0.1s. If more than 1 speed, average.

%NOTE THIS IS HARD CODED FOR 6 FRAME MEDIANS, DONT FORGET THAT
trialSpeed = zeros(60,num_trials);
for eachT = 2:size(gunvantFrames,1)
    thisF = gunvantFrames(eachT);
   
    
    startMed = ((thisF-START_FRAME)/6)-(10*3); %Factoring in for 3seconds before stimulation
    weight = (mod((thisF-START_FRAME),6))/6;
    
    if startMed>0
        for i = 0:59
            trialSpeed(i+1,eachT) = weight*medians(floor(startMed)+i) + (1-weight)*medians(floor(startMed)+i+1); %weighting each speed correctly
        end
    end
end


%Code to sort trial speeds into individual results
trialsSimp = [];
for x = 1:size(trials1,1)
   temp = split(trials1(x));
   trialsSimp = [trialsSimp,temp(3)];
end

trialSpeedHit = zeros(size(trialSpeed,1),1);
trialSpeedCR = zeros(size(trialSpeed,1),1);
trialSpeedMiss = zeros(size(trialSpeed,1),1);
trialSpeedFA = zeros(size(trialSpeed,1),1);

Hit_t = 'Hit';
CR_t = 'CR';
Miss_t = 'Miss!!!';
FA_t = 'FA!!!';

for c = 1:size(trialSpeed,2)
    if(trialsSimp(c)==Hit_t)
        trialSpeedHit = horzcat(trialSpeedHit,trialSpeed(1:size(trialSpeed,1),c));
    end

    if(trialsSimp(c)==CR_t)
        trialSpeedCR = horzcat(trialSpeedCR,trialSpeed(1:size(trialSpeed,1),c));
    end

    if(trialsSimp(c)==Miss_t)
        trialSpeedMiss = horzcat(trialSpeedMiss,trialSpeed(1:size(trialSpeed,1),c));
    end

    if(trialsSimp(c)==FA_t)
        trialSpeedFA = horzcat(trialSpeedFA,trialSpeed(1:size(trialSpeed,1),c));
    end

end

trialSpeedHit = trialSpeedHit(1:60,2:size(trialSpeedHit,2));
trialSpeedCR = trialSpeedCR(1:60,2:size(trialSpeedCR,2));
trialSpeedMiss = trialSpeedMiss(1:60,2:size(trialSpeedMiss,2));
trialSpeedFA = trialSpeedFA(1:60,2:size(trialSpeedFA,2));


f1 = figure;
plot(mean(trialSpeedHit,2))
title('Hit');
f2 = figure;
plot(mean(trialSpeedCR,2)) 
title('CR');
f3 = figure;
plot(mean(trialSpeedMiss,2))
title('Miss');
f4 = figure;
plot(mean(trialSpeedFA,2))    
title('FA');


save(['Data\' VID_NAME '_Data.mat']);




%-------------------------------------------------------------------------
% Stuff that isn't helpful


% %take medians
% medians = zeros(size(myCircles,2)/3);
% for c = 1:size(distPruned,2)
%     prunedList = [];
%     for r = 1:size(distPruned,1)
%         if distPruned(r,c)~=0
%            prunedList = [prunedList,distPruned(r,c)]; 
%         end
%     end
%     disp(prunedList)
%     medians(c) = median(prunedList);
% end
% 
% 
% medianavg = zeros(size(medians)/5);
% for each = 5:5:size(medians)
%    medianavg(each/5) = mean(medians(each-4:each));
% end
% 
% figure
% plot(medians)
% figure
% plot(medianavg)

%idea: take like 10 frames, put all their data together, exclude outliers




% finalValues = zeros(size(myCircles,1),size(myCircles,2)/3);
% finalValuesMean = zeros(1,size(myCircles,2)/3);
% for c = 1:size(distPruned,2)
%     counter = 0;
%     for r = 1:size(distPruned,1)
%         if distPruned(r,c) ~= 0 || normalize(r,c)~=0
%             finalValues(r,c) = distPruned(r,c)/normalize(r,c);
%             counter = counter + 1;
%         end
%     end
%     
%     finalValuesMean(c) = sum(finalValues(1:size(distPruned,1),c))/counter;
%     
% end
% 
% %attempt to calculate speed
% speed = zeros(size(finalValuesMean,2)/5);
% for each = 5:5:size(finalValuesMean,2)
%     speed(each/5) = mean(finalValuesMean(each-4:each));
% end
% 
% %print our results
% figure
% plot(finalValuesMean)
% figure
% plot(speed)



%wont work unless I save the frames again
% %% SHOW MEDIANS ON FRAMES
% figure
% writerObj = VideoWriter('out.avi'); % Name it.
% writerObj.FrameRate = 30; % How many frames per second.
% open(writerObj); 
% for frame = START_FRAME:(END_FRAME-6)
%     
%     bw = read(ball_motion_vid,frame);
%     imshow(bw)
%     
%     index1 = frame-START_FRAME;
%     rows = 1:size(myCircles,1);
%     i = viscircles(myCircles(rows,index1*3+1:index1*3+2),myCircles(rows,index1*3+3));
%     
%     index = floor((frame-START_FRAME)/6)+1;
%    x = [0.5,0.5+medians(index,1)/150*cos(medianAngs(index,1))];
%    y = [0.5,0.5-medians(index,1)/150*sin(medianAngs(index,1))];
% %     x = [0.65,.65+medians(index,1)/150];
% %     y = [0.45,.45+medians(index,1)/150];
%     
%     a = annotation('textarrow',x,y,'color','red');
%     
%     drawnow  
%     
%    myFrame = getframe(gcf);
%    writeVideo(writerObj, myFrame);
% 
%  
% %     if mod(frame,6) == 0
% %         disp(frame)
% %         disp(medianAngs(index))
% %         disp(rad2deg(medianAngs(index)))
% %     end 
%      
% %    pause(.001);
%     
%     delete(a);
% end
% close(writerObj);