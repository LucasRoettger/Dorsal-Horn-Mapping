function [newFileName, coordinateTable] = cleanUpFilename(oldFileName, coordinateTable)
%CLEANUPFILENAME If the filename contanis a '.' this function will replace
%it in the fileName variable as well as the coordinateTable
newChar = '_';

newFileName = replace(oldFileName, '.', newChar);
newFileName = replace(newFileName, '-', newChar);

if isscalar(newFileName(1))
    newFileName = append('LR',newFileName);
end


coordinateTable.Label(startsWith(coordinateTable.Label(:), oldFileName)) = {strcat(newFileName,'.tif')};
end