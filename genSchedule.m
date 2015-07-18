%% new genSchedule generator
 
%% Default variables
clear all; clc;
rng(927); % fix random seed
targetvar_theta = 5;
nFam_T=80; % nTrial of familiarization
nB_T=20; % nTrial of baseline
nG_T=40; % nTrial of gradual perturbation
nEx_T=10; % nTrial of maximum level in extended gradual
nA_T=nG_T+nEx_T; % nTrial of abrupt perturbation
nEC_T=60; % nTrial of error clamp
P = [10 15 20]; % perturbation level
dp=P/nG_T; % increase step for gradual perturbation
ind_Trig=[1+1/4*nEC_T 2+1/4*nEC_T 1+3/4*nEC_T 2+3/4*nEC_T] ;% index of triggers, First and third quarters
reachvar_thetaControl = 0.5;
clampvar_thetaControl = 0.5;
reachvar_thetaNoise = 4;
clampvar_thetaNoise = 4;
% reachvar_thetaInt = 2;
% clampvar_thetaInt = 2;
save defaultVar.mat

%% Schedule Generator
% taskschedule -> 1 = feedback, 2= errorclamp, 6=control break

% test
% load defaultVar.mat
taskschedule = [1*ones(1,4) 2*ones(1,2) ]; 
rotationangle = [0*ones(1,2) P(end)*ones(1,2) 0*ones(1,2)];
nTask = length(taskschedule);
iti = 1000+500*rand(1,nTask);
targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
reachnoise = reachvar_thetaControl*randn(1,nTask);
clampnoise = clampvar_thetaControl*randn(1,nTask);
clear nFam_T nB_T nG_T nEx_T nA_T nEC_T dp P ind_Trig
save taskTest

% familiarization and baseline for abrupt perturbation
load defaultVar.mat
taskschedule = [1*ones(1,nFam_T)];
nTask = length(taskschedule);
rotationangle = [0*ones(1,nTask)];
iti = 1000+500*rand(1,nTask);
targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
reachnoise = reachvar_thetaControl*randn(1,nTask);
clampnoise = clampvar_thetaControl*randn(1,nTask);
clear nB_T nG_T nEx_T nA_T nEC_T dp ind_Trig
save taskBaseA

% main session for abrupt perturbation
load defaultVar.mat
taskschedule = [1*ones(1,nB_T)... 
    1*ones(1,nA_T) 1*ones(1,nG_T) 2*ones(1,nEC_T)...
    1*ones(1,nA_T) 1*ones(1,nG_T) 2*ones(1,nEC_T)...
    1*ones(1,nA_T) 1*ones(1,nG_T) 2*ones(1,nEC_T)];
taskschedule(nB_T+1*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=1;
taskschedule(nB_T+2*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=1;
taskschedule(nB_T+3*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=1; % Trigger setting on first&third quarters in error clamp
nTask = length(taskschedule);
rotationangle = [0*ones(1,nB_T)... % Baseline
    P(1)*ones(1,nA_T) 0*ones(1,nG_T) 0*ones(1,nEC_T)... % First gradual
    P(2)*ones(1,nA_T) 0*ones(1,nG_T) 0*ones(1,nEC_T)...
    P(3)*ones(1,nA_T) 0*ones(1,nG_T) 0*ones(1,nEC_T)];
rotationangle(nB_T+1*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=P(1);
rotationangle(nB_T+2*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=P(2);
rotationangle(nB_T+3*(nA_T+nG_T+nEC_T)-nEC_T+ind_Trig)=P(3);
iti = 1000+500*rand(1,nTask);
targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
reachnoise = reachvar_thetaControl*randn(1,nTask);
clampnoise = clampvar_thetaControl*randn(1,nTask);
clear nFam_T nEx_T dp 
save taskMainA


% familiarization and baseline gradual perturbation
% load defaultVar.mat
% taskschedule = [1*ones(1,nFam_T)];
% nTask = length(taskschedule);
% rotationangle = [0*ones(1,nTask)];
% iti = 1000+500*rand(1,nTask);
% targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
% reachnoise = reachvar_thetaControl*randn(1,nTask);
% clampnoise = clampvar_thetaControl*randn(1,nTask);
% clear nB_T nG_T nEx_T nA_T nEC_T dp ind_Trig
% save taskBaseG

% main session for Gradual perturbation 
load defaultVar.mat
taskschedule = [1*ones(1,nB_T)... % Baseline
    1*ones(1,2*nG_T+nEx_T) 2*ones(1,nEC_T)... %First gradual
    1*ones(1,2*nG_T+nEx_T) 2*ones(1,nEC_T)... % second gradual
    1*ones(1,2*nG_T+nEx_T) 2*ones(1,nEC_T)]; % thrid gradual
taskschedule(nB_T+1*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=1;
taskschedule(nB_T+2*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=1;
taskschedule(nB_T+3*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=1; % Trigger setting on first&third quarters in error clamp
nTask = length(taskschedule);
rotationangle = [0*ones(1,nB_T)...
    (dp(1):dp(1):P(1)).*ones(1,nG_T) P(1)*ones(1,nEx_T) ((P(1)-dp(1)):-dp(1):0).*ones(1,nG_T) 0*ones(1,nEC_T)... % First gradual
    (dp(2):dp(2):P(2)).*ones(1,nG_T) P(2)*ones(1,nEx_T) ((P(2)-dp(2)):-dp(2):0).*ones(1,nG_T) 0*ones(1,nEC_T)...
    (dp(3):dp(3):P(3)).*ones(1,nG_T) P(3)*ones(1,nEx_T) ((P(3)-dp(3)):-dp(3):0).*ones(1,nG_T) 0*ones(1,nEC_T)];
rotationangle(nB_T+1*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=P(1);
rotationangle(nB_T+2*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=P(2);
rotationangle(nB_T+3*(2*nG_T+nEx_T+nEC_T)-nEC_T+ind_Trig)=P(3); % Trigger setting on first&third quarters in error clamp
iti = 1000+500*rand(1,nTask);
targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
reachnoise = reachvar_thetaControl*randn(1,nTask);
clampnoise = clampvar_thetaControl*randn(1,nTask);
clear nFam_T nA_T 
save taskMainG

% % main session for Noise 20 and 40
% taskschedule = [1*ones(1,20) 1*ones(1,60) 1*ones(1,40) 1*ones(1,50) 1*ones(1,20) 1*ones(1,30) 1*ones(1,20) 6 1*ones(1,20) 1*ones(1,50) 2*ones(1,120)];
% nTask = length(taskschedule);
% rotationangle = [0*ones(1,20) 20*ones(1,60) 40*ones(1,40) 20*ones(1,50) 40*ones(1,20) 20*ones(1,30) 40*ones(1,41) 20*ones(1,50) 40*ones(1,120)];
% iti = 1000+500*rand(1,nTask);
% targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
% reachnoise = reachvar_thetaNoise*randn(1,nTask);
% clampnoise = clampvar_thetaNoise*randn(1,nTask);
% save taskMainN40


% % familiarization and baseline for Intermediate(5 min)
% taskschedule = [1*ones(1,80)];
% nTask = length(taskschedule);
% rotationangle = [0*ones(1,nTask)];
% iti = 1000+500*rand(1,nTask);
% targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
% reachnoise = reachvar_thetaInt*randn(1,nTask);
% clampnoise = clampvar_thetaInt*randn(1,nTask);
% save taskBaseInt


% % main session for Intermediate
% taskschedule = [1*ones(1,20) 1*ones(1,60) 1*ones(1,40) 1*ones(1,50) 1*ones(1,20) 1*ones(1,30) 1*ones(1,20) 6 1*ones(1,20) 1*ones(1,50) 2*ones(1,120)];
% nTask = length(taskschedule);
% rotationangle = [0*ones(1,20) P*ones(1,60) 0*ones(1,40) P*ones(1,50) 0*ones(1,20) P*ones(1,30) 0*ones(1,41) P*ones(1,50) P*ones(1,120)];
% iti = 1000+500*rand(1,nTask);
% targetlocation = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
% reachnoise = reachvar_thetaInt*randn(1,nTask);
% clampnoise = clampvar_thetaInt*randn(1,nTask);
% save taskMainInt

%% Temporary plot
load taskMainA
A=rotationangle; % Abrupt
load taskMainG
B=rotationangle; % Gradual
EC_x(1,1)=nB_T+1*(2*nG_T+nEx_T+nEC_T)-nEC_T+1;
EC_x(1,2)=nB_T+1*(2*nG_T+nEx_T+nEC_T);
EC_x(2,1)=nB_T+2*(2*nG_T+nEx_T+nEC_T)-nEC_T+1;
EC_x(2,2)=nB_T+2*(2*nG_T+nEx_T+nEC_T);
EC_x(3,1)=nB_T+3*(2*nG_T+nEx_T+nEC_T)-nEC_T+1;
EC_x(3,2)=nB_T+3*(2*nG_T+nEx_T+nEC_T);
EC_y=[0 P(end)+5];
TRIG=NaN*ones(1,nTask); IND_TEMP=[EC_x(1,1)+ind_Trig-1 EC_x(2,1)+ind_Trig-1 EC_x(3,1)+ind_Trig-1];
TRIG(IND_TEMP)=1; TRIG=TRIG.*A;
A(IND_TEMP)=NaN; B(IND_TEMP)=NaN; 

subplot(2,1,1),h1=plot(A,'b');axis([0 nTask EC_y(1) EC_y(2)]),set(h1,'linewidth',2.5),grid on
patch([EC_x(1,1) EC_x(1,2) EC_x(1,2) EC_x(1,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
patch([EC_x(2,1) EC_x(2,2) EC_x(2,2) EC_x(2,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
patch([EC_x(3,1) EC_x(3,2) EC_x(3,2) EC_x(3,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
title('Perturbation schedule: Abrupt'),xlabel('Trial'),ylabel('Angle')
hold on; stem(TRIG,'k')

subplot(2,1,2),h2=plot(B,'b');axis([0 nTask EC_y(1) EC_y(2)]),set(h2,'linewidth',2.5),grid on
patch([EC_x(1,1) EC_x(1,2) EC_x(1,2) EC_x(1,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
patch([EC_x(2,1) EC_x(2,2) EC_x(2,2) EC_x(2,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
patch([EC_x(3,1) EC_x(3,2) EC_x(3,2) EC_x(3,1)], [EC_y(1) EC_y(1) EC_y(2) EC_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
title('Perturbation schedule: Gradual'),xlabel('Trial'),ylabel('Angle')
hold on; stem(TRIG,'k')
%clear all; clc;

