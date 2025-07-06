function colors = getColorArray(groups)
%GETCOLORARRAY Creates color arraybased on input group array
    % Create color array for cells
    colors = zeros(length(groups),3);

    for i = 1:length(groups)
        switch groups(i)
            case 2
                colors(i,:) = [0,1,0]; % green
            case 3
                colors(i,:) = [1,0,0]; % red
            case 4
                colors(i,:) = [0,0,1]; % blue
            case 5
                colors(i,:) = [1,1,0]; % yellow
            case 6
                colors(i,:) = [0,1,1]; % cyan
            case 7
                colors(i,:) = [1,0,1]; % purple
            case 8
                colors(i,:) = [0.5,0,0]; % dark red
            case 9
                colors(i,:) = [0,0.5,0]; % dark green
            otherwise
                colors(i,:) = [0,0,0]; % black
        end
    end
end

