clc;
clear;
close all;

l=0.951*0.4; %longitud max 951mm

x0=0.5;
y0=-(l/4);
z0=0.5;
%% Se hacen las 4 trayectorias a seguir, a trozos 
t1= linspace(0,l/2,20);
t2= linspace(0,pi,20);
t3= linspace(0,l/2,20);
t4= linspace(0,l/2,20);

y1 = -0.1+t1;
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
            0 1 0 -0.08;
            0 0 1 0;
            0 0 0 1];
%% Se lleva el robot a home
q=[0 0 0 0 0 0];
ql = [0 0 0 0 0 0];
Robot.teach(q)

%% Se calculan los movimientos
R = roty(-45,'deg');
for i=1:length(x)   
    
[q1(i) q2(i) q3(i) q4(i) q5(i) q6(i)]=pos_q(R,[x(i),y(i),z(i)],Robot,ql);
ql=[q1(i) q2(i) q3(i) q4(i) q5(i) q6(i)]';
end


%% Se crea una matriz que contiene todas las posiciones de los vectores.
tqc=[q1' q2' q3' q4' q5' q6'];

%% Trayectoria inicial Home to start:
tq = jtraj(q,tqc(1,:),60);
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
tmcur(1)=(x2(1)-x1(20))/v;%Punto de unión entre recta y curva    
tmcur(i+1)=N(i)/v;%Tiempo entre puntos de la curva 
tmcur(21)=0.0152/v; %SE CAMBIÓ ESTE VALOR

end
%%
%Ahora se crea un vector de tiempos equivalente a las posiciones
%de las articulaciones
for i=1:length(tmcur)-1
    tmcur(i+1)=tmcur(i+1)+tmcur(i); %tiempo acumulado en curva
end
temp0=[linspace(0,tmrec*20,20) (tmcur+tmrec*20) (tmcur(21)+tmrec*20)+linspace(0,tmrec*19,19)];
temp0 = [temp0 temp0(60)+linspace(0,tmrec*20,20)];


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
tqv = tqv(1:79,1:6);
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


function [q1,q2,q3,q4,q5,q6] = pos_q(R, tras, SerialLink,qn)

Target = [R,tras';0 0 0 1];

qSolve= SerialLink.ikcon(Target,qn);
q1 = qSolve(1);
q2 = qSolve(2);
q3 = qSolve(3);
q4 = qSolve(4);
q5 = qSolve(5);
q6 = qSolve(6);

end
