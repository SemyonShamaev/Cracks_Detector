TolshModeli=3.2;    %Общая толщина модели в метрах
DlinaModeli=3.2;    %Общая длина модели в метрах    
K=32;N=32;  %Колво трасс и отчетов
VremyaTrass=42;     %Длина трассы в наносекундах
DielPron1=4;DielPron2=6;     %Коэффициенты диэлектрической проницаемости
CentrFreq=0.85;     %Центральная частота георадара в ГГц
emptyCell=zeros(K,N,3)+255;     %Пустое изображение
colormap('bone');   %Выбор цветовой палитры
ImageCount=50000; LineCount=4;   %Колво изображений и линий

for i=1:ImageCount
    %создание пустых изображений
    filePathMask="C:\Cells\Mask\"+ i +".png"; filePathTrain="C:\Cells\Train\"+ i +".png";
    imwrite(emptyCell,filePathMask); imwrite(emptyCell,filePathTrain);   
    X1=0;X2=0;Y1=0;Y2=0;    %Координаты
    
    for j=1:LineCount
        Glubina=randi([8*(j-1) 8*j])/10;   %Глубина залегания границы в метрах
        cm=randi([-30 30])/100;    %Смещение по вертикали в метрах   
        LWcm=randi([0 20])/10-1; if LWcm<0, LWcm=0; end  %Ширина трещины в метрах  
        Lcm=randi([1 32])/10;     %Расстояние до трещины в метрах
        Ksin=randi([0 50])/100;     %Коэффициент синусоиды
        Kcm=randi([-10 10])/100;  %Коэффициент смещения
        if LWcm + Lcm > 3.1, Lcm = Lcm/2; end     %Проверка на наличие трещины в видимом диапазоне
        
        RMT=DlinaModeli/(K-1);  %Шаг между трассами в метрах
        dt=VremyaTrass/N;   %Время на 1 отсчет
        Tcm=round(Lcm/RMT)+1;   %Трасса с которой начинается трещина
        Wcm=round(LWcm/RMT);   %Ширина трещины в трассах    
        cg=(1/(CentrFreq/10))/dt;   %Ширина импульса в отчетах
        dcm=(2*cm/(0.3/sqrt(DielPron1)))/dt;    %Смещение по вертикали в отчетах                                   
        GlubGran=round((2*Glubina/(0.3/sqrt(DielPron1)))/dt);   %Глубина залегания границы в отчетах                     
        Kotr=abs((sqrt(DielPron1)-sqrt(DielPron2))/(sqrt(DielPron1)+sqrt(DielPron2)));    %Коэффициент отражения
        AmpSignal=Kotr*400;
        
        %проверка на наслоение
        if (Glubina*10+dcm+cg-Kcm*(Tcm+Wcm))<X1, break; end
        
        %Волновое поле
        gaus=zeros(K,N);   
        for T=1:K
            for d=1:N
                gaus(T,d)=GaussPulse(AmpSignal,d-myheav(T-Tcm)*dcm+Kcm*T,0.1*GlubGran*sin(T*Ksin)+GlubGran,cg,2)*(1-RectPulse2(T-Tcm,Wcm));
            end
        end
        
        %Преобразование массива в изображение
        BW=imbinarize(gaus); CC=bwconncomp(BW); L=labelmatrix(CC); 
        Mask=label2rgb(L,colormap); Train=label2rgb(L,colormap);    
       
        %Координаты начала и конца трещины
        X1=Glubina*10+cg-Kcm*Tcm-1; Y1=Tcm;    
        X2=Glubina*10+dcm+cg-Kcm*(Tcm+Wcm)-1; Y2=Tcm+Wcm+1;     
        
        %Отрисовка линии для маски
        if X1 < K + 5 && X2 < K + 5 && Y1 < K + 5 && Y2 < K + 5 && LWcm > 0
            Mask = insertShape(Mask,'Line',[X1 Y1 X2 Y2],'LineWidth',round(cg/2),'Color','red','Opacity', 0);   %Отрисовка линии на маске
        end
        Mask = rot90(Mask);  Train = rot90(Train);
          
        %Создание тренировочных изображений  
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