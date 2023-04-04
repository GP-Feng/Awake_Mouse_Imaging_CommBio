function Output=Blending(Img,guide)
[H,W]=size(Img);
Output=zeros(H,W);
Output(:,1)=Img(:,1);

for ii4=2:W
    ind=guide(ii4);
    if ind>=0
        Output(1:(end-ind),ii4)=Img((ind+1):end,ii4);
    else
        Output((abs(ind)+1):end,ii4)=Img(1:(end+ind),ii4);
    end
end