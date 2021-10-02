TolshModeli=3.2;DlinaModeli=3.2;      
K=32;N=32;             
VremyaTrass=42;     
DielPron1=4;DielPron2=6;
emptyCell=zeros(K,N,3)+255;
colormap('bone'); 

for i=1:1000
    filePathMask="C:\Cells\Mask\"+ i +".png"; filePathTrain="C:\Cells\Train\"+ i +".png";
    imwrite(emptyCell,filePathMask);imwrite(emptyCell,filePathTrain);
    for j=1:4
        Glubina=(3.1-0)*rand+0;      
        cm=(0.5-(-0.5))*rand+(-0.5);           
        LWcm=(2-0)*rand+0;             
        Lcm=(2.5-0.5)*rand+0.5;             
        CentrFreq=(3.5-0.85)*rand+0.85;
        
        if LWcm + Lcm > 3.1, LWcm = LWcm/2; end
        RMT=DlinaModeli/(K-1); 
        dt=VremyaTrass/N;   
        Tcm=round(Lcm/RMT)+1;Wcm=round(LWcm/RMT);       
        cg=(1/(CentrFreq/10))/dt;
        dcm=(2*cm/(0.3/sqrt(DielPron1)))/dt;                                           
        GlubGran=round((2*Glubina/(0.3/sqrt(DielPron1)))/dt);                           
        Kotr=abs((sqrt(DielPron1)-sqrt(DielPron2))/(sqrt(DielPron1)+sqrt(DielPron2)));  
        AmpSignal= Kotr*400;
        gaus=zeros(K,N);    
        x=0:DlinaModeli/K:DlinaModeli;y=0:dt:VremyaTrass-dt;
        smeshCoef=(0.25-(-0.25))*rand+(-0.25);
        X1=Glubina*10+cg-smeshCoef*Lcm*10; Y1=Lcm*10+1;
        X2=Glubina*10+cm*10+cg-smeshCoef*Lcm*10-smeshCoef*LWcm*10; Y2=Lcm*10+LWcm*10+2;
        
        for T=1:K
            for d=1:N
                gaus(T,d)=GaussPulse(AmpSignal,d-myheav(T-Tcm)*dcm+smeshCoef*T,GlubGran,cg,2)*(1-RectPulse2(T-Tcm,Wcm));
            end
        end

        BW=imbinarize(gaus); CC=bwconncomp(BW); L=labelmatrix(CC); 
        Mask=label2rgb(L,colormap); Train=label2rgb(L,colormap); 
        MaskImage = imread(filePathMask); TrainImage = imread(filePathTrain);
        if X1 < K + 5 && X2 < K + 5 && Y1 < K + 5 && Y2 < K + 5
            Mask = insertShape(Mask,'Line',[X1 Y1 X2 Y2],'LineWidth',round(cg/2),'Color','red','Opacity', 0);
        end
        Mask = rot90(Mask); Train = rot90(Train);
        
        for n=1:K
            for m=1:N
                if TrainImage(n,m,:) == 255, TrainImage(n,m,:)=Train(n,m,:); end
                if MaskImage(n,m,:) == 255
                    if TrainImage(n,m,:) > 10, MaskImage(n,m,:) = Mask(n,m,:);
                    else, MaskImage(n,m,:) = Train(n,m,:); end       
                end
            end
        end
        imwrite(MaskImage,filePathMask); imwrite(TrainImage,filePathTrain);
    end
end