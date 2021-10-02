function [res]=Giperbola(T,Tcm,GlubGran,RMT,dt,v)
    res=2*sqrt(((T-Tcm)*RMT)^2+(0.5*GlubGran*dt*v)^2)/v/dt;
end