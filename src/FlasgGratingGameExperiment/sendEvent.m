function sendEvent(event, time)
tic; x = 0;
while x < time
    x = toc;
    trigger.push_chunk(event) ;
%     disp(x)
end