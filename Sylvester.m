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
M = eye(4)*diag([-2 -3 -4 -5]);

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


  