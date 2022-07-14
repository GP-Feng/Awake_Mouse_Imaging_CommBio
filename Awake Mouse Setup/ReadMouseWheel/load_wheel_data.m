function [times ,channel_a, channel_b] = load_wheel_data(filename)
%LOAD_WHEEL_DATA Converts binary Mouse Wheel data collected with internal
%software
%   Wheel monitor software ouputs data in binary format. Each frames of
%   data has ten bytes. The first eight bytes are a double that represent
%   the seconds since midnight of the day the data was collected. The next
%   two bytes are either one or zero and correspond to the two digital
%   output channels on the wheel

fileID = fopen(filename);
[~, count] = fread(fileID);
frewind(fileID);

size = count / 10; % There are ten bytes for each entry

times = zeros([size, 1], 'double');
channel_a = zeros([size, 1], 'int8');
channel_b = zeros([size, 1], 'int8');

for i=1:size
    times(i) = fread(fileID, 1, 'double');
    channel_a(i) = fread(fileID, 1, 'int8');
    channel_b(i) = fread(fileID, 1, 'int8');
end

end

