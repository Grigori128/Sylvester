clear
close all
%% macierze obiektu
A = [-0.0226 -36.6 -18.9 -32.1 ;...
           0 -1.9  0.983     0;...
      0.0123 -11.7 -2.63     0;...
           0     0     1     0];
       
B = [0      0;...
     -0.414 0;...
     -77.8 22.4;...
     0     0];
 
C = [0  57.3  0  0;...
     0    0   0  57.3];
 
D = zeros(2,2);

% wart. w≈Çasne A
lambda = eig(A); % stabilne

% dobieranie macierzy M o zadanym wektorze warto≈õci w≈Çasnych < 0
M = eye(4)*diag([-6 -5 -7 -8]);

% dobieranie macierzy L
L = ones(4,2);

% sprawdzanie sterowalno≈õci 
S = [L M*L (M^2)*L M^3*L]; % rank S = rank A
%sprS = ctrb(M,L);
%rank(sprS);
% definicja macierzy T
T = sym('t',[4 4]);

% r√≥wnanie Sylvestera
l = M*T-T*A;
p = -L*C;

eqns = l == p; % tworzenie macierzy r√≥wna≈Ñ
[a,b] = equationsToMatrix(eqns); % konwersja r√≥wna≈Ñ do postaci macierzowej at = b
cT = linsolve(a,b);

nT = double([cT(1) cT(2) cT(3) cT(4);...
      cT(5) cT(6) cT(7) cT(8);...
      cT(9) cT(10) cT(11) cT(12);...
      cT(13) cT(14) cT(15) cT(16)]);
%sprT = sylv(-M,A,L*C);
N = double(nT*B-L*D);

%% Wykresy
x0 = [1 1 1 1]'; 
z0 = nT*[-1 -1 -1 -1]';
t = 5;
out = sim('Sylvester_sym');

figure(1)
set(1,'Position',[50 50 1300 500]);
movegui(1,'center');
tiledlayout(5,2,'Padding','compact','TileSpacing','compact')
nexttile(1);
hold on;
grid on;
plot(out.tout,out.state.signals.values(:,1),out.tout,out.estate.signals.values(:,1));
legend('$x_1(t)$','$\hat{x_1}(t)$','Interpreter','latex','Location','southeast');
hold off;

nexttile(3);
hold on;
grid on;
plot(out.tout,out.state.signals.values(:,2),out.tout,out.estate.signals.values(:,2));
legend('$x_2(t)$','$\hat{x_2}(t)$','Interpreter','latex','Location','southeast');

nexttile(5);
hold on;
grid on;
plot(out.tout,out.state.signals.values(:,3),out.tout,out.estate.signals.values(:,3));
legend('$x_3(t)$','$\hat{x_3}(t)$','Interpreter','latex','Location','southeast');
hold off;

nexttile(7);
hold on;
grid on;
plot(out.tout,out.state.signals.values(:,4),out.tout,out.estate.signals.values(:,4));
legend('$x_4(t)$','$\hat{x_4}(t)$','Interpreter','latex','Location','southeast');
hold off;

nexttile(9);
hold on;
grid on;
plot(out.tout,out.output.signals.values);
legend('$y_1(t)$','$y_2(t)$','Interpreter','latex','Location','southeast');
hold off;
xlabel('t (s)','Interpreter','latex');

nexttile(2,[5 1]);
hold on;
grid on;
xlim([0,1.5]);
plot(out.tout,out.error.signals.values);
legend('$e_1(t)$','$e_2(t)$','$e_3(t)$','$e_4(t)$','Interpreter','latex');
xlabel('t (s)','Interpreter','latex');
hold off;

% zapytanie o zapis
guifig = uifigure('Position',[680 678 398 271],'Name','Zapisaƒá wykresy?');
movegui(guifig,'center');
bg = uibuttongroup(guifig,'Position',[137 113 123 85]);
rb1 = uitogglebutton(bg,'Position',[150 60 91 25],'Text','Placeholder');
rb2 = uitogglebutton(bg,'Position',[15 40 91 25],'Text','Zapisuj');
rb3 = uitogglebutton(bg,'Position',[15 10 91 25],'Text','Nie zapisuj');
figure(guifig);

for i=1:500
if rb2.Value == 1 && rb3.Value == 0 
%zapis figurki do formatu png
close(guifig)
print(1, '-dpng', 'wyniki_estymacji', '-r600')
disp('Zapisano')%
break;
else
    if rb3.Value == 1 && rb2.Value == 0
        close(guifig)
        break;
    end
end
pause(0.25);
end

%% sterowanie
sys = ss(A,B,C,D);
Q = diag([1 1 1 1 100 50]); %[x1 x2 x3 x4 y1 y2]
R = diag([.1 .1]); %[u1 u2]
K = lqi(sys,Q,R);

t = 25;
out2 = sim('LQI_control');

%% wykresy odpowiedzi uk≈Çadu z regulatorem LQI

figure(3)
set(3,'Position',[50 50 1300 500]);
movegui(3,'center');
tiledlayout(4,2,'Padding','compact','TileSpacing','compact')
nexttile(1);
hold on;
grid on;
plot(out2.tout,out2.state.signals.values(:,1));
ylabel('$x_1$','Interpreter','latex');
hold off;

nexttile(3);
hold on;
grid on;
plot(out2.tout,out2.state.signals.values(:,2));
ylabel('$x_2$','Interpreter','latex');
hold off;

nexttile(5);
hold on;
grid on;
plot(out2.tout,out2.state.signals.values(:,3));
ylabel('$x_3$','Interpreter','latex');
hold off;

nexttile(7);
hold on;
grid on;
plot(out2.tout,out2.state.signals.values(:,4));
ylabel('$x_4$','Interpreter','latex');
xlabel('t (s)','Interpreter','latex');
hold off;

nexttile(2)
hold on;
grid on;
plot(out2.tout,out2.output.signals.values(:,1),out2.tout,out2.ref1.signals.values);
legend('$y_1(t)$','$r_1(t)$','Interpreter','latex');
hold off;

nexttile(4)
hold on;
grid on;
plot(out2.tout,out2.output.signals.values(:,2),out2.tout,out2.ref2.signals.values);
legend('$y_2(t)$','$r_2(t)$','Interpreter','latex');
hold off;

nexttile(6)
hold on;
grid on;
plot(out2.tout,out2.control.signals.values(:,1));
ylabel('$u_1$','Interpreter','latex');
hold off;

nexttile(8)
hold on;
grid on;
plot(out2.tout,out2.control.signals.values(:,2));
ylabel('$u_2$','Interpreter','latex');
xlabel('t (s)','Interpreter','latex');
hold off;

% zapytanie o zapis
guifig2 = uifigure('Position',[680 678 398 271],'Name','Zapisaƒá wykresy?');
movegui(guifig2,'center');
bg = uibuttongroup(guifig2,'Position',[137 113 123 85]);
rb1 = uitogglebutton(bg,'Position',[150 60 91 25],'Text','Placeholder');
rb2 = uitogglebutton(bg,'Position',[15 40 91 25],'Text','Zapisuj');
rb3 = uitogglebutton(bg,'Position',[15 10 91 25],'Text','Nie zapisuj');
figure(guifig2);

for i=1:500
if rb2.Value == 1 && rb3.Value == 0 
%zapis figurki do formatu png
close(guifig2)
print(3, '-dpng', 'wyniki_sterowania', '-r600')
disp('Zapisano')%
break;
else
    if rb3.Value == 1 && rb2.Value == 0
        close(guifig2)
        break;
    end
end
pause(0.25);
end

%% wizualizacja

%HiMAT w STL
fv = stlread('HiMAT_V003.STL');
Sm = diag([0.01 0.01 0.01]); % scale
%R1 = [cosd(60),0,sind(60);0 1 0; -sind(60) 0, cosd(60)];
fv.vertices = fv.vertices*Sm;
ftmp = fv;

figure(2)
set(2,'Position', [200 200 1300 600]);
set(gca, 'LooseInset', [0,0,0,0]);

grid on;
time = out2.tout;
theta = out2.state.signals.values(:,4);
alpha = out2.state.signals.values(:,2);

for r = 1:10:length(time)
set(0,'CurrentFigure',2)
title(strcat('t =',{' '},string((r*0.01)-0.01),'s'));

subplot(4,2,1)
plot(out2.tout(1:r),out2.state.signals.values(1:r,1),'k-','LineWidth',1.8);
%ylim([min(theta)-0.1*max(theta) max(theta)+0.1*max(theta)])
xlim([0 t]);
xlabel('t (s)');
ylabel('x_1');
grid on;

subplot(4,2,3)
plot(out2.tout(1:r),out2.state.signals.values(1:r,2),'b-','LineWidth',1.8);
%ylim([min(omega)-0.1*max(omega) max(omega)+0.1*max(omega)])
xlim([0 t]);
xlabel('t (s)');
ylabel('x_2');
grid on;

subplot(4,2,5)
plot(out2.tout(1:r),out2.state.signals.values(1:r,3),'r-','LineWidth',1.8);
%ylim([min(tau)-0.1*max(tau) max(tau)+0.1*max(tau)])
xlim([0 t]);
xlabel('t (s)'); 
ylabel('x_3');
grid on;

subplot(4,2,7)
plot(out2.tout(1:r),out2.state.signals.values(1:r,4),'g-','LineWidth',1.8);
xlim([0 t]);
%ylim([min(ctrl)-(0.1*max(ctrl)+0.1) max(ctrl)+(0.1*max(ctrl)+0.1)])
xlabel('t (s)'); 
ylabel('x_4');
grid on;

subplot(4,2,[2,4,6,8])

%%
%limity
xlim([-50 50])
ylim([-50 50])
zlim([-50 50])

%kπty obrotu
s = theta(r)-90; %oú x
p = 0; %oú y
y = 0; %oú z <-- to nas interesuje

%macierze rotacji dla poszczegÛlnych osi
Rx = [1 0 0; 0 cosd(s) -sind(s); 0 sind(s), cosd(s)];
Ry = [cosd(p) 0 sind(p); 0 1 0; -sind(p) 0 cosd(p)];
Rz = [cosd(y) -sind(y) 0; sind(y) cosd(y) 0; 0 0 1];

%wektor translacji do centrowania
le=length(ftmp.vertices);
trans=[-25.9*ones(le,1),-12*ones(le,1),-35*ones(le,1)];

cla
grid on;
view(-76,15); % <--- blokada kamery

%dodanie translacji i wymnoøenie przez rotacjÍ
ftmp.vertices = (fv.vertices+trans)*Rx*Ry*Rz;

camlight('left');
material('metal');
h = patch(ftmp,'FaceColor',       [0 1 0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
material('metal');
rotate(h, [1,0,0], 0)
drawnow

end

