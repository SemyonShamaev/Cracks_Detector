TolshModeli=3.2;    %����� ������� ������ � ������
DlinaModeli=3.2;    %����� ����� ������ � ������    
K=32;N=32;  %����� ����� � �������
VremyaTrass=42;     %����� ������ � ������������
DielPron1=4;DielPron2=6;     %������������ ��������������� �������������
CentrFreq=0.85;     %����������� ������� ��������� � ���
emptyCell=zeros(K,N,3)+255;     %������ �����������
colormap('bone');   %����� �������� �������
ImageCount=50000; LineCount=4;   %����� ����������� � �����

for i=1:ImageCount
    %�������� ������ �����������
    filePathMask="C:\Cells\Mask\"+ i +".png"; filePathTrain="C:\Cells\Train\"+ i +".png";
    imwrite(emptyCell,filePathMask); imwrite(emptyCell,filePathTrain);   
    X1=0;X2=0;Y1=0;Y2=0;    %����������
    
    for j=1:LineCount
        Glubina=randi([8*(j-1) 8*j])/10;   %������� ��������� ������� � ������
        cm=randi([-30 30])/100;    %�������� �� ��������� � ������   
        LWcm=randi([0 20])/10-1; if LWcm<0, LWcm=0; end  %������ ������� � ������  
        Lcm=randi([1 32])/10;     %���������� �� ������� � ������
        Ksin=randi([0 50])/100;     %����������� ���������
        Kcm=randi([-10 10])/100;  %����������� ��������
        if LWcm + Lcm > 3.1, Lcm = Lcm/2; end     %�������� �� ������� ������� � ������� ���������
        
        RMT=DlinaModeli/(K-1);  %��� ����� �������� � ������
        dt=VremyaTrass/N;   %����� �� 1 ������
        Tcm=round(Lcm/RMT)+1;   %������ � ������� ���������� �������
        Wcm=round(LWcm/RMT);   %������ ������� � �������    
        cg=(1/(CentrFreq/10))/dt;   %������ �������� � �������
        dcm=(2*cm/(0.3/sqrt(DielPron1)))/dt;    %�������� �� ��������� � �������                                   
        GlubGran=round((2*Glubina/(0.3/sqrt(DielPron1)))/dt);   %������� ��������� ������� � �������                     
        Kotr=abs((sqrt(DielPron1)-sqrt(DielPron2))/(sqrt(DielPron1)+sqrt(DielPron2)));    %����������� ���������
        AmpSignal=Kotr*400;
        
        %�������� �� ���������
        if (Glubina*10+dcm+cg-Kcm*(Tcm+Wcm))<X1, break; end
        
        %�������� ����
        gaus=zeros(K,N);   
        for T=1:K
            for d=1:N
                gaus(T,d)=GaussPulse(AmpSignal,d-myheav(T-Tcm)*dcm+Kcm*T,0.1*GlubGran*sin(T*Ksin)+GlubGran,cg,2)*(1-RectPulse2(T-Tcm,Wcm));
            end
        end
        
        %�������������� ������� � �����������
        BW=imbinarize(gaus); CC=bwconncomp(BW); L=labelmatrix(CC); 
        Mask=label2rgb(L,colormap); Train=label2rgb(L,colormap);    
       
        %���������� ������ � ����� �������
        X1=Glubina*10+cg-Kcm*Tcm-1; Y1=Tcm;    
        X2=Glubina*10+dcm+cg-Kcm*(Tcm+Wcm)-1; Y2=Tcm+Wcm+1;     
        
        %��������� ����� ��� �����
        if X1 < K + 5 && X2 < K + 5 && Y1 < K + 5 && Y2 < K + 5 && LWcm > 0
            Mask = insertShape(Mask,'Line',[X1 Y1 X2 Y2],'LineWidth',round(cg/2),'Color','red','Opacity', 0);   %��������� ����� �� �����
        end
        Mask = rot90(Mask);  Train = rot90(Train);
          
        %�������� ������������� �����������  
        MaskImage = imread(filePathMask); TrainImage = imread(filePathTrain);
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