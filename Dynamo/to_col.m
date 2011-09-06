function col = to_col(anything)
%
% Convert a matrix of any dimentionality into a column matrix of elements
% Convert a cell array of any dimentionality into a column cell array of elements
%
% Usage: col = to_col(anything)
% 

col = reshape(anything, numel(anything), 1);

