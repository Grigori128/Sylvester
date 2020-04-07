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

% wart. własne A
lambda = eig(A); % stabilne

% dobieranie macierzy M o zadanym wektorze wartości własnych < 0
M = eye(4)*diag([-5 -6 -7 -8]);

% dobieranie macierzy L
L = ones(4,2);

% sprawdzanie sterowalności 
S = [L M*L (M^2)*L M^3*L];
%S = ctrb(M,L);

% definicja macierzy T
T = sym('t',[4 4]);

% równanie Sylvestera
l = M*T-T*A;
p = -L*C;

eqns = l == p; % tworzenie macierzy równań
[a,b] = equationsToMatrix(eqns); % konwersja równań do postaci macierzowej at = b
cT = linsolve(a,b);

nT = double([cT(1) cT(2) cT(3) cT(4);...
      cT(5) cT(6) cT(7) cT(8);...
      cT(9) cT(10) cT(11) cT(12);...
      cT(13) cT(14) cT(15) cT(16)]);

N = double(nT*B-L*D);

%% Wykresy
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
guifig = uifigure('Position',[680 678 398 271],'Name','Zapisać wykresy?');
movegui(guifig,'center');
bg = uibuttongroup(guifig,'Position',[137 113 123 85]);
rb1 = uitogglebutton(bg,'Position',[150 60 91 25],'Text','Placeholder');
rb2 = uitogglebutton(bg,'Position',[15 40 91 25],'Text','Zapisuj');
rb3 = uitogglebutton(bg,'Position',[15 10 91 25],'Text','Nie zapisuj');
figure(guifig);

for i=1:500
if rb2.Value == 1 && rb3.Value == 0 
%zapis figurki do formatu png
print(1, '-dpng', 'wyniki_estymacji', '-r600')
close(guifig)
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
