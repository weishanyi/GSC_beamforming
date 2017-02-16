clear all

%% GSC Beamforming
%
%  Autores -> Juan Manuel L�pez Torralba
%             Jose Manuel Garcia Gim�nez
%             Ismael Yeste Esp�n
%             Daniel Melgarejo Garc�a


% Definici�n de Parametros:

Fs=16000; %frecuencia de muestreo
nc=15;    %numero de canales
L=400;    %longitud de la STFT
N=15;
c=340;
f=1:L/2;
win=sqrt(hanning(L)); %Ventana de Hanning
win_mat = repmat(win,1,N)';
load('steering_vector.mat')

clear angle



w=(1/N)*ds.';                %%%%%%%%%%%% M�todo Ai/N 



% ds2 = exp(j*angle(ds));       %%%%%%%%%%%%%% m�todo normalizar vector, ya
                                      %%%%%%%% har�a falta el 1/N
% w=ds2.';



% ds2 = exp(j*angle(ds));      %%%%%%%%%%%%% M�todo 1/Ai
% w = ds2.';
% Ai = abs(ds)';


% ds2 = exp(j*angle(ds));      %%%%%%%%%%%%% M�todo Ai/ds^2
% w = ds2.';
% Ai = abs(ds)';
% mod_ds = ds * ds';
% Ai2 = (Ai/mod_ds); 

% Generamos la matriz de bloqueo

B = [zeros(1,N-1)' -1*eye(N-1)] + [eye(N-1) zeros(1,N-1)'];


%Cargar las señales
Leer_Array_Signals;

%Dividir el mensaje en tramas
ntrama=Nsamp/(L/2);
ntrama=round(ntrama)-1;

xout=zeros(length(x{1}),1); %Creamos el vector de salida con zeros.

mat_temp = zeros(15,L/2+1);
matout = zeros(N,Nsamp);

ini=1;
ak = zeros(14,L/2+1);
%mu = 0.002271;
mu = 0.0003;
for k=1:ntrama-1
   xtemp=zeros;
    for nc=1:N
        x1=fft((win.*x{nc}(ini:ini+(L-1)))); %Aplicamos la ventana de Hanning a cada trama de cada canal y le hacemos la FFT
        
        mat_temp(nc,:) = (w(:,nc).*x1(1:(L/2)+1)).';  % matriz auxiliar para pasar los canales sincronizados a la matriz de bloqueo
        
% % % % % %      Este xtemp vale para m�todos  Ai/N  
       xtemp=xtemp+w(:,nc).*x1(1:(L/2)+1); %Multiplicamos por el vector de pesos y vamos sumando cada uno de los canales, 
                                            %a fin de tener una señal resultante constructiva
             
                                            
                                            
% % % % % % % % % % % % % % % % % % % % % % % % % % %     M�todo 1/Ai                                    
%         Ainvers = (1./Ai);                                    
%         xtemp=xtemp+Ainvers(:,nc).*w(:,nc).*x1(1:(L/2)+1);                                



% % % % % % % % % % % % % % % % % % % % %  % % % % % % M�todo Ai/||ds||^2;
        
                                            
%          xtemp=xtemp+Ai2(:,nc).*w(:,nc).*x1(1:(L/2)+1); 

    end
    %matout(:,ini:ini+L-1)=matout(:,ini:ini+L-1)+win_mat.*real(ifft([mat_temp conj(mat_temp(:,end-1:-1:2))],[],1)); %Formamos la otra mitad de xtemp, hacemos la ifft y la multiplicamos por la ventana.
   
    x2 = B*mat_temp;                          % Aplicamos la matriz de bloqueo a trama de los 15 canales                            
    [yout, ak] = lms_eq(ak,x2,xtemp,mu);      % se hace la parte adaptable
        
        
    xout(ini:ini+L-1)=xout(ini:ini+L-1)+win.*real(ifft([yout'; conj(yout(end-1:-1:2))'])); %Formamos la otra mitad de xtemp, hacemos la ifft y la multiplicamos por la ventana.
    ini=ini+L/2;
end

% xout es la salida del Beam Forming


xfinal=xout;

%Audio Array
array = 'array.wav';
%audiowrite(array,xfinal,Fs)
audiowrite(array,xfinal/max(max(xfinal), -min(xfinal)),Fs,'BitsPerSample',16);
%soundsc(xout,Fs);

%Cargar señal limpia
fname = 'an103-mtms-senn4.adc';
[fid,msg] = fopen(fname,'r','b');
if fid < 0
  disp(msg);
else
  data = fread(fid,'int16');
  fclose(fid);
end
xlimpia=data;


%Audio señal limpia
limpia = 'limpia.wav';
%audiowrite(limpia,xlimpia,Fs)
audiowrite(limpia,xlimpia/max(max(xlimpia),-min(xlimpia)),Fs,'BitsPerSample',16);
%Comparación
pesq=pesq(limpia,array)

soundsc(xfinal,Fs)

