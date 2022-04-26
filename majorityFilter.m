function [finalMajorityFil] = majorityFilter(original, W)


imageBW = (original); % converting image to black and while
M = size(imageBW,1); % getting number of rows 
N = size(imageBW,2); % getting number of columns 

finalMajorityFil = imageBW;

% function for majority filter
for i=1+floor(W/2):M-floor(W/2)
    for j=1+floor(W/2):N-floor(W/2)

        window                    = imageBW(i-floor(W/2):i+floor(W/2),j-floor(W/2):j+floor(W/2));
        window                    = window(:);
        outputValue               = mode(window);
        finalMajorityFil(i,j)     = uint8(outputValue);
    end % end for
end % end for
