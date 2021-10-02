function [res]=DifragVoln(vetv,AmpSignal,d,T,Tcm,GlubGran,RMT,dt,v,ShirinaImpulsa,Deriv)
    %vetv: 0 - net voln; 2 - obe volny; 11 - levaya; 12 - pravaya
    DTT=T-Tcm;
    if vetv==2 || (vetv==11 && DTT<0)|| (vetv==12 && DTT>=0)
        res=GaussPulse(AmpSignal,d,Giperbola(T,Tcm,GlubGran,RMT,dt,v),ShirinaImpulsa,Deriv);
    else
        res=0;
    end
end

