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

q=[0 0 0 0 0 0];

jacobiano=Robot.jacob0(q)

v=[0.100 0.200 0.050]; %m/s
w=[5 10 -5];    %rad/s


velocidades_q= inv(jacobiano)*[v w]'




