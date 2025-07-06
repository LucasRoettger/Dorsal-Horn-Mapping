
pattern = "T6" + "*";
outlineFile = dir(fullfile("ROIOUTLINES/", pattern));
fig = figure('Name', "Figure");
        ax = gca;
        ax.YDir = 'reverse'; % flips figure
        ax.Color = 'white';
        axis off equal
for j = 1:length(outlineFile)
    hold on
    outline = readmatrix(fullfile("ROIOUTLINES/", outlineFile(j).name), "FileType","text", "Delimiter",",","NumHeaderLines",1);
    
    outline(end+1,:) = outline(1,:);

    plot(outline(:,1), outline(:,2), "LineStyle","-", "Color", "black", "LineWidth", 1);
    hold off
end