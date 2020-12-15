function yrke = rke(I, u)
L=length(u);
yrke=0;
for i=1:L
    yrke=yrke+0.5*I*(u(i))^2;
end