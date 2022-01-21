clc;
clear;
close all;

l=0.951*0.4; %longitud max 951mm

x0=0.5;
y0=-(l/4);
z0=0.5;
p=1.5*l+(pi*(l/4)); %Perimetro de la figura
paso=p/60; %Cantidad de puntos, Paso

%% Se hacen las 4 trayectorias a seguir, a trozos 
t1= linspace(0,l/2,20);
t2= linspace(0,pi,20);
t3= linspace(0,l/2,20);
t4= linspace(0,l/2,20);

y1 = y0+t1;
z1 = z0+t1-t1;
x1 = (t1-t1)+x0;

y2= -sqrt((l/4).^2 + ((t1)-l/4).^2)+y0+l/2 + sqrt((l/4).^2 + ((l/2)-l/4).^2);
z2= z0+((l/2)/pi)*t2*sin(pi/4);
x2= x0+((l/2)/pi)*t2*cos(pi/4);

y3 = y0+(l/2)-t3;
z3 = z0+t3-t3+(l/2)*sin(pi/4);
x3= -(t3-t3)+x0+(l/2)*cos(pi/4);

y4 = y0+t4-t4;
z4 = z0+t4-t4+(l/2)*sin(pi/4)-t4*cos(pi/4);
x4 = x0+t4-t4+(l/2)*cos(pi/4)-t4*cos(pi/4);


%Ahora se plotean las trayectorias
plot3(x1,y1,z1)
hold on
plot3(x2,y2,z2)
plot3(x3,y3,z3)
plot3(x4,y4,z4)

xlabel('X') 
ylabel('Y')
zlabel('Z')

x=[x1 x2 x3 x4];
y=[y1 y2 y3 y4];
z=[z1 z2 z3 z4];
xyz=[x' y' z']; %Se define una matriz con todos los puntos xyz
%% Luego se plotean los puntos de las trayectorias
scatter3(x1,y1,z1)
scatter3(x2,y2,z2)
scatter3(x3,y3,z3)
scatter3(x4,y4,z4)

%%
ws = [-100 100 -100 100 -100 400]/100;
plot_options={'workspace',ws,'scale',.4,'view',[-160,39],'tilesize',2,'ortho', 'lightpos',[2 2 14]};


L1=0.265; L2=0.444; L3=0.110; L4=0.470; L5=0.080; L6=0.037;

L(1) = Link('revolute','alpha', 0,    'a', 0,   'd',L1,   'offset', 0,   'modified', 'qlim',[-pi pi]);
L(2) = Link('revolute','alpha', -pi/2,    'a', 0,   'd',0,   'offset', -pi/2,   'modified', 'qlim',[-pi pi]);
L(3) = Link('revolute','alpha', 0,    'a', L2,   'd',0,   'offset', 0,   'modified', 'qlim',[-3.92699 1.48353]);
L(4) = Link('revolute','alpha', -pi/2,    'a', L3,   'd',L4,   'offset', 0,   'modified', 'qlim',[-pi pi]);
L(5) = Link('revolute','alpha', pi/2,    'a', 0,   'd',0,   'offset', 0,   'modified', 'qlim',[-pi pi]);
L(6) = Link('revolute','alpha', -pi/2,    'a', L5,   'd',L6,   'offset', 0,   'modified', 'qlim',[-pi pi]);
Robot = SerialLink(L,'name','ABB CRB 15000','plotopt',plot_options); 

Robot.tool= [1 0 0 0;
            0 1 0 0;
            0 0 1 0;
            0 0 0 1];
%% Se lleva el robot a home
q=[0 0 0 0 0 0];
Robot.teach(q)

%% Se calculan los movimientos
rpy=[1.1071 0.7297 -1.1071]; %[r,p,y]=rod2angle([-1,0,1])
for i=1:length(x)   
[q1(i) q2(i) q3(i) q4(i) q5(i) q6(i)]=pos_q(rpy,[x(i),y(i),z(i)],Robot);
%rpy(i,:)=tr2rpy(Robot.fkine([q1(i) q2(i) q3(i) q4(i) q5(i) q6(i)]));
end


%% Se crea una matriz que contiene todas las posiciones de los vectores.
tqc=[q1' q2' q3' q4' q5' q6'];

%% Trayectoria inicial Home to start:
tq = jtraj(q,tqc(1,:),40);
Robot.plot(tq)

%%
Robot.plot(tqc)
%%
v=0.5
for i=1:length(x2)-1 
%Busqueda de las distancia entre los puntos pertenecientes a la curva
x2v(i)=x2(i+1)-x2(i);
y2v(i)=y2(i+1)-y2(i);
z2v(i)=z2(i+1)-z2(i);
N(i)=sqrt((x2v(i).^2)+(y2v(i).^2)+(z2v(i).^2));

tmrec=(x1(2)-x1(1))/v; %Tiempo entre los puntos de las partes rectas
tmcur(1)=(x2(1)-x1(20))/v;%Punto de unión entre recta y curva    %Se cambió de 14 a 20
tmcur(i+1)=N(i)/v;%Tiempo entre puntos de la curva 
tmcur(20)=0.951/v; %SE CAMBIÓ ESTE VALOR

end
%%
%Ahora se crea un vector de tiempos equivalente a las posiciones
%de las articulaciones
for i=1:length(tmcur)-1
tmcur(i+1)=tmcur(i+1)+tmcur(i); %tiempo acumulado en curva
end
temp0=[0:tmrec:tmrec*80 (tmcur+tmrec*80) (tmcur(20)+tmrec*80)+(tmrec:tmrec:tmrec*80)];
temp0=[temp0 temp0(80)+(tmrec:tmrec:tmrec*80)];



%% Ahora se crean los vectores de velocidad ángular
for i=1:length(q1)-1
tqv(i,:)=(tqc(i+1,:)-tqc(i,:))/(temp0(i+1)-temp0(i));
end
tqv(80,:)= tqv(79,:);

%% Se hacen todas las graficas de posición
figure(2)
subplot(2,3,1)
plot(temp0,q1)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q1')
subplot(2,3,2)
plot(temp0,q2)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q2')
subplot(2,3,3)
plot(temp0,q3)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q3')
subplot(2,3,4)
plot(temp0,q4)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q4')
subplot(2,3,5)
plot(temp0,q5)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q5')
subplot(2,3,6)
plot(temp0,q6)
xlabel('Tiempo (s)')
ylabel('Ángulo (rad)')
title('q6')
%% Se hacen todas las graficas de velocidad
figure(3)
subplot(2,3,1)
plot(temp0(1:end-1),tqv(:,1))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q1')
subplot(2,3,2)
plot(temp0(1:end-1),tqv(:,2))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q2')
subplot(2,3,3)
plot(temp0(1:end-1),tqv(:,3))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q3')
subplot(2,3,4)
plot(temp0(1:end-1),tqv(:,4))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q4')
subplot(2,3,5)
plot(temp0(1:end-1),tqv(:,5))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q5')
subplot(2,3,6)
plot(temp0(1:end-1),tqv(:,6))
xlabel('Tiempo (s)')
ylabel('Velocidad (rad/s)')
title('q6')

%% BORRAR ESTA PARTE
function [q1,q2,q3,q4,q5,q6] = myik(rpy, tras, SerialLink)
T = transl(tras)*rpy2tr(rpy);
dm = T(1:3,4)+0.1*T(1:3,2);
xm = dm(1);
ym = dm(2);
zm = dm(3)-0.525;
L = sqrt(xm^2+ym^2)-0.15;
L1 = 0.770;
L21 = 0.100;
L22 = 0.740;
L2 = sqrt(L21^2+L22^2);
q1 = atan2(ym, xm);
alpha = atan(0.740/0.100);
% Se trabajará codo arriba
ca3 = (L^2+zm^2-L1^2-L2^2)/(2*L1*L2);
q3a = atan2(sqrt(1-ca3^2),ca3);
q3 = q3a-alpha;
sg = L2*sin(pi-q3-alpha)/(sqrt(L^2+zm^2));
gamma = atan2(sg,sqrt(1-sg^2));
q2 = pi/2-atan2(zm,L)-gamma;
% Ya se tienen las primeras 3 matrices de rotación
T03 = trotz(q1)*troty(q2)*troty(q3);
R0_3 = SerialLink.A([1,2,3],[q1 -q2 -q3]);
R03 = R0_3(1:3,1:3);
R30 = R03';
R0f = T(1:3,1:3);
R3f = R30*R0f;
c5 = R3f(2,3);
q5 = atan2(sqrt(1-c5^2),c5);
s4 = R3f(3,3)/sin(q5);
q4 = atan2(s4,sqrt(1-s4^2));
s6 = R3f(2,1)/sin(q5);
q6 = atan2(s6,sqrt(1-s6^2));

end

function [q1,q2,q3,q4,q5,q6] = pos_q(rpy, tras, SerialLink)
R=rpy2r(rpy);
Target = [R,tras';0 0 0 1];

qSolve= SerialLink.ikcon(Target);
q1 = qSolve(1);
q2 = qSolve(2);
q3 = qSolve(3);
q4 = qSolve(4);
q5 = qSolve(5);
q6 = qSolve(6);

end
