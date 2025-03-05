clc;
clear;

% toolboxes used: image processing toolbox

img = im2gray(imread("teeth_sample.png"));
img = im2double(adapthisteq(img));
[m, n] = size(img);

intensityThreshold = 0.2;
center = (m / 2) - 30;
probabilityThreshold = 0.90;
windowSize = 10;
sigma = 0.1 * m;

indices = [];
allProbabilities = [];
allColumns = [];

for colIdx = 1:windowSize:n
    column = img(:, colIdx);
    
    minimaIdx = find(islocalmin(column));
    validIdx = minimaIdx(column(minimaIdx) < intensityThreshold);
    validIntensities = column(validIdx);
    
    distance = abs(validIdx - center);
    
    % gaussian weighting function
    probabilities = exp(-(distance .^ 2) / (2 * sigma^2));
    
    indices = [indices; validIdx];
    allProbabilities = [allProbabilities; probabilities];
    allColumns = [allColumns; repmat(colIdx, length(validIdx), 1)];
end

validResults = allProbabilities >= probabilityThreshold;

indices = indices(validResults);
allProbabilities = allProbabilities(validResults);
allColumns = allColumns(validResults);

% add default point to left side of image
allColumns = [1;allColumns];
indices = [191; indices];
allProbabilities = [0; allProbabilities];

% sort by column number
[sortedColumns, sortIdx] = sort(allColumns);
sortedIndices = indices(sortIdx);
sortedProbabilities = allProbabilities(sortIdx);

% remove duplicate values in columns
[uniqueColumns, ~, uniqueIdx] = unique(sortedColumns);
averagedIndices = accumarray(uniqueIdx, sortedIndices, [], @mean);

% spline interpolation for smoothing the dividing line
x = uniqueColumns;
y = averagedIndices;

interpX = linspace(min(x), max(x), 1000);
interpY = interp1(x, y, interpX, 'spline');

figure;
imshow(img);
hold on;

% smoothed curve
plot(interpX, interpY, 'r-', 'LineWidth', 2);

% vertices
%plot(sortedColumns, sortedIndices, 'ro', 'MarkerSize', 6, 'LineWidth', 2);
%hold off;

grid on;

%disp(table(allColumns, indices, allProbabilities));