function F=CostFun1(x,Curv,alpha,beta)

num=size(Curv,2);
for ii1=1:num
    Curv(:,ii1)=Curv(:,ii1)+x(ii1);
end

F=norm(std(Curv,[],2),2)+alpha.*norm(x,1)+beta.*mean(mean(Curv));

