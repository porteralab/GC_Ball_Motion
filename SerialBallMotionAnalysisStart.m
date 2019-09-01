% Please verify that all videos and mat files are able to be loaded
% MAT_NAME,VID_NAME,STIM_START_FRAME,END_FRAME,MAXIMUM_SPEED,TRIALS,THRESH_CIRCLE,THRESH_LINE

mat_names = string({'AudDistract_D16_111318_BM_'
                                    });
                                
vid_names = string({'NTask_CO3_032118_x264'
                                    });                                
stim_starts = [1740
                                    ];
end_frames = [177900
                                    ];
max_speeds = [20
                                    ];     
thresh_circles = [345,290,110
                                    ];
thresh_lines = [-.1,390
                                    ];

errors = size(mat_names,2);                     
for x=1:size(mat_names,2)
   errors(1,x) = SerialBallMotionAnalysis(mat_names(x),vid_names(x),stim_starts(x),end_frames(x),max_speeds(x),thresh_circles(x,:),thresh_lines(x,:));
end