function grating = sinusoidGrating(f, len)
offset = 128;
amplitude =127;
p=ceil(1/f); % pixels/cycle, rounded up.
fr=f*2*pi;

% Create one single static grating image:
x = meshgrid(-len:len + p, -len:len);
grating = 128 + 127*cos(fr*x);

% Create circular aperture for the alpha-channel:
[x,y]=meshgrid(-len:len, -len:len);
circle = 255 * (x.^2 + y.^2 <= (len)^2);

% Set 2nd channel (the alpha channel) of 'grating' to the aperture
% defined in 'circle':
grating(:,:,2) = 0;
grating(1:2*len+1, 1:2*len+1, 2) = circle;

end
