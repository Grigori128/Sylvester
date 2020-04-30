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

% wart. w³asne A
lambda = eig(A); % stabilne

% dobieranie macierzy M o zadanym wektorze wartoœci w³asnych < 0
M = eye(4)*diag([-6 -5 -7 -8]);

% dobieranie macierzy L
L = ones(4,2);

% sprawdzanie sterowalnoÅ›ci 
S = [L M*L (M^2)*L M^3*L]; % rank S = rank A

% definicja macierzy T
T = sym('t',[4 4]);

% rownanie Sylvestera
l = M*T-T*A;
p = -L*C;

eqns = l == p; % tworzenie macierzy rownan
[a,b] = equationsToMatrix(eqns); % konwersja do postaci macierzowej At = B
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
t = 10;
out = sim('Sylvester_sym'); %skoki jednostkowe na t = 2 dla u1 i t = 7 dla u2 

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
guifig = uifigure('Position',[680 678 398 271],'Name','ZapisaÄ‡ wykresy?');
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
print(1, '-dpng', 'wyniki_estymacji0', '-r600')
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
Q = diag([0.1 0.1 0.1 0.1 50 50]); %[x1 x2 x3 x4 y1 y2]
R = diag([0.1 0.1]); %[u1 u2]
K = lqi(sys,Q,R);

t = 15;
out2 = sim('LQI_control');

%% wykresy odpowiedzi ukÅ‚adu z regulatorem LQI

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
guifig2 = uifigure('Position',[680 678 398 271],'Name','ZapisaÄ‡ wykresy?');
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
fv = stlread('HiMAT_V003.STL'); % wczytanie modeli stl
ar = stlread('arrow.stl');
Sm = diag([0.01 0.01 0.01]); % skalowanie
Sm2 = diag([0.3 0.3 1]);
fv.vertices = fv.vertices*Sm;
ar.vertices = ar.vertices*Sm2;
ftmp = fv;
artmp = ar;

figure(2)
set(2,'Position', [200 200 1300 600]);
set(gca, 'LooseInset', [0,0,0,0]);

grid on;
time = out2.tout;
theta = out2.state.signals.values(:,4);
alpha = out2.state.signals.values(:,2);

for r = 1:10:length(time) % wyswietlanie w pêtli
set(0,'CurrentFigure',2)
title(strcat('t =',{' '},string((r*0.01)-0.01),'s'));

subplot(4,2,1)
plot(out2.tout(1:r),out2.state.signals.values(1:r,1),'k-','LineWidth',1.8);
xlim([0 t]);
xlabel('t (s)');
ylabel('x_1 (rad/s)');
grid on;

subplot(4,2,3)
plot(out2.tout(1:r),out2.state.signals.values(1:r,2),'b-','LineWidth',1.8);
xlim([0 t]);
xlabel('t (s)');
ylabel('x_2 (rad)');
grid on;

subplot(4,2,5)
plot(out2.tout(1:r),out2.state.signals.values(1:r,3),'r-','LineWidth',1.8);
xlim([0 t]);
xlabel('t (s)'); 
ylabel('x_3 (rad/s)');
grid on;

subplot(4,2,7)
plot(out2.tout(1:r),out2.state.signals.values(1:r,4),'g-','LineWidth',1.8);
xlim([0 t]);
xlabel('t (s)'); 
ylabel('x_4 (rad)');
grid on;

subplot(4,2,[2,4,6,8])

%%
%limity
xlim([-50 50])
ylim([-50 50])
zlim([-50 50])

%k¹ty obrotu
s = theta(r) - deg2rad(90); %oœ x
d = alpha(r) - deg2rad(90);
p = 0; %oœ y
y = 0; %oœ z <-- to nas interesuje

%macierze rotacji dla poszczególnych osi
Rx = [1 0 0; 0 cos(s) -sin(s); 0 sin(s), cos(s)];
Ra = [1 0 0; 0 cos(d) -sin(d); 0 sin(d), cos(d)];
Ry = [cos(p) 0 sin(p); 0 1 0; -sin(p) 0 cos(p)];
Rz = [cos(y) -sin(y) 0; sin(y) cos(y) 0; 0 0 1];

%wektor translacji do centrowania
le=length(ftmp.vertices);
trans=[-25.9*ones(le,1),-12*ones(le,1),-35*ones(le,1)];

cla
grid on;
view(-76,15); % <--- blokada kamery

%dodanie translacji i wymno¿enie przez rotacjê
ftmp.vertices = (fv.vertices+trans)*Rx*Ry*Rz;
artmp.vertices = (ar.vertices)*Ra;

patch([50 -50 -50 50],[50 50 -50 -50],'k','FaceAlpha',0.2)
camlight('left');
material('metal');
h = patch(ftmp,'FaceColor',       [0 1 0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
material('metal');

a = patch(artmp,'FaceColor',       [1 0 0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
material('metal');

rotate(h, [1,0,0], 0)
drawnow

end
%print(2, '-dpng', 'wizualizacja', '-r600');

