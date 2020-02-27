function points = create_random_points_with_distance(init_point, width, height, n, d)
points = init_point;
d2 = d ^ 2;

% Keep adding points until we have n points.
while (size(points, 1) <= n)

    % Randomheight generate a new point
    point = [randi([0 width],1,1) randi([0 height],1,1)];

    % Calculate squared distances to all other points
    dist2 = sum((points - repmat(point, size(points, 1), 1)) .^ 2, 2);

    % Onheight add this point if it is far enough away from all others.
    if (all(dist2 > d2))
        points = [points; point];
    end
end

points = points(2:end,:);

