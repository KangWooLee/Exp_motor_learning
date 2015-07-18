% Forgetting Project 2014
% Youngmin Oh
% Updated: 9/7/2014
% Pilot test
% schedule: 1=Feedback, 2=Error-clamped

% To DO:
% Add arc

function expPilot(schedule,subjID)
load(schedule)
cgloadlib
cgopen(5,0,0,1) % 1280x1024

%% text feedback
cgloadbmp(2,'tooslow.bmp',348,75)
cgloadbmp(3,'toofast.bmp',305,74)
cgloadbmp(10,'break.bmp',1105,101)
cgloadbmp(16,'ready.bmp',691,102)
cgloadbmp(17,'seconds.bmp',642,102)


%% experiment parameters
rcursor = 4; % radius of the cursor (pixels)
rstart = 10; % radius of the start circle (pixels)
rarc = 340; % radius of the arc (pixels)
rtargetin = 4; % radius of the inner circle target (pixels)
actwidth = 3; % actual target width for success (degs)
rtargetout = rarc*actwidth*pi/180; % radius of the outer circle target (pixels)
tharc = 1; % thickness of the arc (pixels)
halfarc = 60; % half-angle of the arc (degs)
tup = 300; % movement time upper bound (ms)
tlow = 100; % movement time lower bound (ms)
calxy = [1.28 1]; % scales of x and y
scx = 0; % center of starting point x (pixels)
scy = -256; % center of starting point y (pixels)
if strcmp(schedule,'taskMainC') || strcmp(schedule,'taskMainCprime')
    Q = sqrt(1.8^2 + clampvar_thetaControl^2) / clampvar_thetaControl;
elseif strcmp(schedule,'taskMainCS')
    Q = sqrt(1.8^2 + clampvar_thetaControl^2) / clampvar_thetaControl;
elseif strcmp(schedule,'taskMainN') || strcmp(schedule,'taskMainNprime')
    Q = sqrt(1.8^2 + clampvar_thetaNoise^2) / clampvar_thetaNoise;
elseif strcmp(schedule,'taskMainInt')
    Q = sqrt(1.8^2 + clampvar_thetaInt^2) / clampvar_thetaInt;
else
    Q = 1;
end

%% sound definition
matsound = sinwav(760,0.05,20000);
matsound2 = sinwav(760,0.1,48000);
matsound3 = sinwav(760,0.05,34000);
cgsound('open');
cgsound('matrixSND',9,matsound,12000);
cgsound('matrixSND',10,matsound2,12000);
cgsound('matrixSND',8,matsound3,12000);

%% waiting for start
cgfont('Arial',65)
kd(2) = 0;
while ~kd(2) % key 1: start
    cgpencol(1,1,1)
    cgdrawsprite(16,0,-100)
    [kd,kp] = cgkeymap;
    cgflip(0,0,0);
end

%% variable definition and initial values
phase = 0; % phase controls each stage within a single trial
time0 = time;
trial = 1;
vx = 0;
vy = 0;
timepass = 0;
soundplayed = 0;
soundalarmed = 0;
initstart = 1;


hand_theta = zeros(1,length(taskschedule)); % hand angle (degs)
cursor_theta = zeros(1,length(taskschedule)); % cursor angle (degs)
angle_clamped = zeros(1,length(taskschedule)); % clamped feedback location
reaction_time = zeros(1,length(taskschedule)); % from onset of target to move out of start circle
movement_time = zeros(1,length(taskschedule)); % from move out of start circle to cross arc
kinematic_data = []; % kinematic data during shooting
data.kinematic_data = [];
cgpenwid(1)
cgfont('Arial',16)

%% main loop
while trial <= length(taskschedule)  % one loop corresponds to one mouse reading
    [kd,kp] = cgkeymap;
    if kd(88) % F12 = exit button
        cgsound('shut')
        cgshut
    end
   %% input and output
   % draw the start circle
   cgpencol(1,1,1)
   cgellipse(scx,scy,2*rstart,2*rstart)
   
   cgtext(sprintf('%d',trial),-600,-500)
   
   % record last point
   lastvx = vx;
   lastvy = vy;
   lastime = timepass;
   
   % get a new input
   [x,y] = cgmouse; % read mouse input
   hx = calxy(1)*x - scx; % calibrated hand position
   hy = calxy(2)*y - scy;
   timepass = time; % time at mouse input

   % visuomotor rotation
   rangle = rotationangle(trial) + reachnoise(trial);
   vxy = [cos(rangle*pi/180) -sin(rangle*pi/180); sin(rangle*pi/180) cos(rangle*pi/180)]*[hx;hy]; % rotation around the center
   vx = vxy(1);
   vy = vxy(2);
   svx = -(vx + scx); % screen coordinate (mirror image)
   svy = vy + scy;
   r = sqrt(vx^2+vy^2);
   
   %% stages at each trial
   switch phase 
       
       %-----------------------------------------------------------------------------------------
       % phase 0: waiting for start signal (target appearance)
       case 0

           if taskschedule(trial)==6 % control break (2 min)
               cgdrawsprite(10,0,-100)
               
               if timepass-time0 >= 2*60000-5000 && timepass-time0 < 2*60000
                   cgdrawsprite(17,-100,-200);
                   if soundalarmed==0
                       cgsound('play',9)
                       soundalarmed = 1;
                   end
               elseif timepass-time0 > 2*60000
                   phase = 0;
                   time0 = timepass;
                   soundplayed = 0;
                   soundalarmed = 0;
                   trial = trial + 1;
               end
               
           else % ordinary waiting
                cgpencol(1,0,0)
                cgellipse(-(hx+scx),hy+scy,2*rcursor,2*rcursor,'f')
%                 cgellipse(scx,scy,2*rstart,2*rstart,'f')
                timewait = iti(trial);
                
                if r > rstart % check early start
                    phase = 3;
                    validstart = 0;
                elseif timepass - time0 >= timewait
                    phase = 1;
                    time1 = timepass;
                    validstart = 1;
                end
                
           end
           
           
           %-------------------------------------------------------------------------------------
           % phase 1: target appears and shoot
           case 1
               
           cgpencol(1,0,0)
           if r <= rstart % offline feedback (i.e., no trajectory shown)
               cgellipse(svx,svy,2*rcursor,2*rcursor,'f')
           elseif r > rstart && initstart == 1
               reaction_time(trial) = timepass - time1; % time from onset of target to move out of start circle
               initstart = 0;
               time15 = timepass;
           end
           
           % arc
           for i=1:9
               cgpencol(1.0*normpdf(i,5,4),1.0*normpdf(i,5,4),1.0*normpdf(i,5,4))
               cgarc(scx,scy,2*(rarc+(i-5)),2*(rarc+(i-5)),90-halfarc,90+halfarc)
           end
           
           % target coordinate
           stx = -(rarc*cos(pi*targetlocation(trial)/180) + scx); 
           sty = rarc*sin(pi*targetlocation(trial)/180) + scy;
           cgpencol(1,1,1)
           cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
           cgellipse(stx,sty,2*rtargetout,2*rtargetout)
                   
           % algorithm to detect crossing and to calculate interpolation point
           if sqrt(vx^2+vy^2)>=rarc && sqrt(lastvx^2+lastvy^2)<=rarc
               a = (vy-lastvy)/(vx-lastvx); % slope
               b = lastvy - lastvx*(vy-lastvy)/(vx-lastvx); % y-intercept
               if vx==lastvx
                   arcx = vx;
                   arcy = sign(vy)*sqrt(rarc^2-arcx^2);
               elseif vy==lastvy
                   arcy = vy;
                   arcx = sign(vx)*sqrt(rarc^2-arcy^2);
               elseif vy > 0
                   arcy = (b + sqrt(a^2*(a^2+1)*rarc^2-a^2*b^2)) / (a^2+1);
                   arcx = (arcy-b)/a;
               elseif vy < 0
                   arcy = (b - sqrt(a^2*(a^2+1)*rarc^2-a^2*b^2)) / (a^2+1); 
                   arcx = (arcy-b)/a;
               end
               
               cursor_theta(trial) = (180/pi)*acos(arcx/sqrt(arcx^2+arcy^2));
               hand_theta(trial) = cursor_theta(trial) - rangle;
               d1 = sqrt((arcx-lastvx)^2+(arcy-lastvy)^2);
               d2 = sqrt((arcx-vx)^2+(arcy-vy)^2);
               time2 = (d2*timepass+d1*lastime)/(d1+d2); 
               movement_time(trial) = time2 - time15;
               
               if soundplayed==0
                   cgsound('play',9)
                   soundplayed = 1;
               end
               
                phase = 2;
           end
           
          kinematic_data = [kinematic_data; trial timepass hx hy];
        
       
       %-----------------------------------------------------------------------------------------
       % phase 2: provide feedback    
       case 2
           % check movement time
           if movement_time(trial) > tup
               cgdrawsprite(2,0,-100)
           elseif movement_time(trial) < tlow
               cgdrawsprite(3,0,-100)
           end
           % arc
           for i=1:9
               cgpencol(1.0*normpdf(i,5,4),1.0*normpdf(i,5,4),1.0*normpdf(i,5,4))
               cgarc(scx,scy,2*(rarc+(i-5)),2*(rarc+(i-5)),90-halfarc,90+halfarc)
           end
           
           % target
           cgpencol(1,1,1)
           cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
           cgellipse(stx,sty,2*rtargetout,2*rtargetout)
           
           % feedback
           switch taskschedule(trial)
               case 1 % feedback
                   cgpencol(1,0,0)
                   cgellipse(-(arcx+scx),arcy+scy,2*rcursor,2*rcursor,'f')
                   angle_clamped(trial) = NaN;
               case 2 % error-clamped
                   angle_clamped(trial) = targetlocation(trial) + Q*clampnoise(trial);
                   clampedx = rarc*cos(pi*angle_clamped(trial)/180);
                   clampedy = rarc*sin(pi*angle_clamped(trial)/180);
                   cgpencol(1,0,0)
                   cgellipse(-(clampedx+scx),clampedy+scy,2*rcursor,2*rcursor,'f')
           end
           
           % show feedback for 1000ms
           if timepass - time2 > 1000
               phase = 3;
           end
       
           
       %-----------------------------------------------------------------------------------------
       % phase 3: guide to return
       case 3
           if  r > 2*rstart
               cgpencol(1,0,0)
               cgellipse(scx,scy,2*r,2*r)
           elseif r <= 2*rstart && r > rstart
               cgpencol(1,0,0)
               cgellipse(-(hx+scx),hy+scy,2*rcursor,2*rcursor,'f')
           elseif r <= rstart
               phase = 0;
               time0 = timepass;
               soundplayed = 0;
               soundalarmed = 0;
               initstart = 1;
               if validstart==1
                   trial = trial + 1;
               end
               % save data
               data.hand_theta = hand_theta;
               data.cursor_theta = cursor_theta;
               data.angle_clamped = angle_clamped;
               data.reaction_time = reaction_time;
               data.movement_time = movement_time;
               data.kinematic_data = [data.kinematic_data; kinematic_data];
               save(sprintf('../Data/subj%d-%s',subjID,schedule),'data');
               kinematic_data = [];
           end
          
   end
   
   cgflip(0,0,0) 
   
   
end

expara.rcursor = rcursor;
expara.rstart = rstart;
expara.rarc = rarc;
expara.rtarget = rtargetin;
expara.tharc = tharc;
expara.actwidth = actwidth;
expara.tup = tup;
expara.tlow = tlow;
expara.calxy = calxy;
expara.scx = scx;
expara.scy = scy;

sch.nTask = nTask;
sch.iti = iti;
sch.rotationangle = rotationangle;
sch.targetlocation = targetlocation;
sch.taskschedule = taskschedule;
sch.reachnoise = reachnoise;
sch.clampnoise = clampnoise;

save(sprintf('../Data/subj%d-%s',subjID,schedule),'data','expara','sch');
cgsound('shut')
cgshut


