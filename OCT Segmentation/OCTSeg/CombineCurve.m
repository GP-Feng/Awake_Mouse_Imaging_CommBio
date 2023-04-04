function OutCurv=CombineCurve(Curv)

[len,num]=size(Curv);

for ii0=1:num
    curv0=Curv(:,ii0);
    cmean=mean(curv0);
    curv0(abs((curv0-cmean))>40)=nan;
    Curv1(:,ii0)=curv0;
end

alpha=2;beta=0.1;
fun=@(x)CostFun1(x,Curv1,alpha,beta);
x0=zeros(1,num);
x = fminsearch(fun,x0);
for ii1=1:num
    Curv(:,ii1)=Curv(:,ii1)-x(ii1);
end
% figure;plot(Curv)
Combined=zeros(1,len);
for ii2=1:len
   column=Curv(ii2,:);
   column=sort(column);
   medval=median(column);
   column(abs(column-medval)>20)=[];
   Combined(ii2)=mean(column);
end
% Combined=mean(Curv,2);
% figure;plot(Combined)

xx=1:len;
xx(abs(Combined)>50)=[];
Combined(abs(Combined)>50)=[];
xx(isnan(Combined))=[];
Combined(isnan(Combined))=[];


p=polyfit(xx,Combined,5);
OutCurv=round(polyval(p,1:len));
