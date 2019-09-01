%load('D:\Gunvant Ball Motion\B3\K26_031417.mat')

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
    