function [res]=GaussPulse(Amplituda,t,SmeshenieOt0,ShirinaImpulsa,Deriv)
    ShirinaImpulsa=ShirinaImpulsa*(1+Deriv)*0.5;
    SmeshenieOt0=SmeshenieOt0+ShirinaImpulsa*0.5;
    ShirinaImpulsa=0.25*ShirinaImpulsa;
    cur_t=SmeshenieOt0-t;
    res=-694*(2*(cur_t)^2/ShirinaImpulsa^2-1)*(2*Amplituda/ShirinaImpulsa^2)*exp(-(cur_t)^2/ShirinaImpulsa^2);
end