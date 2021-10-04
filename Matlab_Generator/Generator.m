TolshModeli=3.2;    %Общая толщина модели в метрах
DlinaModeli=3.2;    %Общая длина модели в метрах    
K=32;N=32;  %Колво трасс и отчетов
VremyaTrass=42;     %Длина трассы в наносекундах
DielPron1=4;DielPron2=6;    %Коэффициенты диэлектрической проницаемости
emptyCell=zeros(K,N,3)+255;     %Пустое изображение
colormap('bone');   %Выбор цветовой палитры

for i=1:1
    filePathMask="C:\Cells\Mask\"+ i +".png"; filePathTrain="C:\Cells\Train\"+ i +".png";
    imwrite(emptyCell,filePathMask); imwrite(emptyCell,filePathTrain);   %создание пустых изображений
    
    for j=1:1
        Glubina=(3.1-0)*rand+0;     %Глубина залегания границы в метрах
        cm=(0.5-(-0.5))*rand+(-0.5);    %Смещение по вертикали в метрах   
        LWcm=(2-0)*rand+0;    %Ширина трещины в метрах   
        Lcm=(2.5-0.5)*rand+0.5;     %Расстояние до трещины в метрах
        CentrFreq=(3.5-0.85)*rand+0.85;     %Центральная частота георадара в ГГц
        
        if LWcm + Lcm > 3.1, LWcm = LWcm/2; end     %Проверка на наличие трещины в видимом диапазоне
        
        RMT=DlinaModeli/(K-1);  %Шаг между трассами в метрах
        dt=VremyaTrass/N;   %Время на 1 отсчет
        Tcm=round(Lcm/RMT)+1;   %Трасса с которой начинается трещина
        Wcm=round(LWcm/RMT);   %Ширина трещины в трассах    
        cg=(1/(CentrFreq/10))/dt;   %Ширина импульса в отчетах
        dcm=(2*cm/(0.3/sqrt(DielPron1)))/dt;    %Смещение по вертикали в отчетах                                   
        GlubGran=round((2*Glubina/(0.3/sqrt(DielPron1)))/dt);   %Глубина залегания границы в отчетах                     
        Kotr=abs((sqrt(DielPron1)-sqrt(DielPron2))/(sqrt(DielPron1)+sqrt(DielPron2)));    %Коэффициент отражения
        AmpSignal= Kotr*400;
           
        x=0:DlinaModeli/K:DlinaModeli;y=0:dt:VremyaTrass-dt;
        Kcm=(0.25-(-0.25))*rand+(-0.25);  %Коэффициент смещения
        
        X1=Glubina*10+cg-Kcm*Lcm*10; Y1=Lcm*10+1;     %Координаты начала трещины
        X2=Glubina*10+cm*10+cg-Kcm*Lcm*10-Kcm*LWcm*10; Y2=Lcm*10+LWcm*10+2;     %Координаты конца трещины
        
        gaus=zeros(K,N);    %Волновое поле
        for T=1:K
            for d=1:N
                gaus(T,d)=GaussPulse(AmpSignal,d-myheav(T-Tcm)*dcm+Kcm*T,0.1*GlubGran*sin(T*0.5),cg,2)*(1-RectPulse2(T-Tcm,Wcm));
            end
        end

        BW=imbinarize(gaus); CC=bwconncomp(BW); L=labelmatrix(CC); 
        Mask=label2rgb(L,colormap); Train=label2rgb(L,colormap);    %Преобразование массива в изображение
        MaskImage = imread(filePathMask); TrainImage = imread(filePathTrain);
        if X1 < K + 5 && X2 < K + 5 && Y1 < K + 5 && Y2 < K + 5
            Mask = insertShape(Mask,'Line',[X1 Y1 X2 Y2],'LineWidth',round(cg/2),'Color','red','Opacity', 0);   %Отрисовка линии на маске
        end
        Mask = rot90(Mask); Train = rot90(Train);
        
        for n=1:K
            for m=1:N
                if TrainImage(n,m,:) == 255, TrainImage(n,m,:)=Train(n,m,:); end
                if MaskImage(n,m,:) == 255
                    if TrainImage(n,m,:) > 10, MaskImage(n,m,:) = Mask(n,m,:);
                    else, MaskImage(n,m,:) = Train(n,m,:); end    %Создание тренировочных изображений   
                end
            end
        end
        imwrite(MaskImage,filePathMask); imwrite(TrainImage,filePathTrain);
    end
end