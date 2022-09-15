%% Perform autocorrelation on waveform

clc; close all; clear;

% Plot settings
set(0, 'DefaultFigureRenderer', 'painters');
fontsize = 16;
linewidth = 0.5;
markersize = 10;
% xpos=10;
% ypos=10;
% width=600;
% height=500;
color = parula(4);

% Load data
fn='waveform.mat';
load(fn);
t=waveform.time;
signal=waveform.volts;

%% Plot recorded signal
%zero-out the 'main bang', 0-5us
collected_signal = signal;
signal(t<5e-6)=0;
close all
hFig=figure; 
plot(t./1e-6,collected_signal,'linewidth',linewidth*1,'color',color(2,:))
xlabel('Time / $\mu$s', 'Interpreter', 'latex')
ylabel('Signal / V', 'Interpreter', 'Latex')
set(gca, 'FontSize', fontsize,'FontWeight','Normal') 
set(gca,'linewidth',1)
set(gca,'TickLabelInterpreter','latex')

%% Perform autocorrelation
[xc,lags]=xcorr(signal,'coef'); %autocorrelation
xc_env=abs(hilbert(xc)); %envelope using abs(hilbert())
% hFig=figure; plot(lags,xc,lags,xc_env); xlabel('lags'); ylabel('Correlation Coef.');

%% Find and plot peaks from autocorrelation
close all
hFig=figure; 
findpeaks(xc_env,lags,'MinPeakDistance',0.5e4,'MinPeakHeight',0.1);
[~,locs]=findpeaks(xc_env,lags,'MinPeakDistance',0.5e4,'MinPeakHeight',0.1);
hold on;
plot(lags,xc,'-','linewidth',linewidth,'color',color(3,:))
xlabel('Lags', 'Interpreter', 'latex')
ylabel('Correlation coefficient', 'Interpreter', 'Latex')
set(gca, 'FontSize', fontsize,'FontWeight','Normal') 
set(gca,'linewidth',1)
set(gca,'TickLabelInterpreter','latex')
xlim([-4,5]*1E4)
% Inset plot
axes('Position',[0.58 0.55 0.29 0.35])
box on
findpeaks(xc_env,lags,'MinPeakDistance',0.5e4,'MinPeakHeight',0.1);
[~,locs]=findpeaks(xc_env,lags,'MinPeakDistance',0.5e4,'MinPeakHeight',0.1);
hold on;
xlim([-0.5,1]*1E4)
plot(lags,xc,'-','linewidth',linewidth,'color',color(3,:))
xlabel('Lags', 'Interpreter', 'latex')
ylabel('Corr. Coef', 'Interpreter', 'Latex')
set(gca, 'FontSize', fontsize/1.5,'FontWeight','Normal') 
set(gca,'linewidth',0.5)
set(gca,'TickLabelInterpreter','latex')

%% Calculate ToF and speed of sound
Fs=t(2)-t(1); %sample frequency 
tt=locs(locs>=0)*Fs; %echo times
dt=diff(tt); %difference between echo times
distance=2*9.5e-3; %measured distance between echoes (round-trip)
c_sample=distance./dt;
fprintf('\nFound %u echos, c_sample = %g %g %g\n',length(c_sample),c_sample);
% Choose first c_sample for ToF between primary and secondary peaks.