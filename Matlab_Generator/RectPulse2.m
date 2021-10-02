function [res]=RectPulse2(s,w)
    if s>=0 && s<w
        res=1;
    else
        res=0;
    end    
end