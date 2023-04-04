function loss = Align_offset(Drift,x)

for ii1 = 1:size(Drift,2)
    Offset(:,ii1)=round(Drift(:,ii1)+x(ii1));
end

loss = mean(std(Offset,[],2));

