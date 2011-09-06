function v = Phi0_norm(A,B)

% Can be called with one or two parameters
if nargin == 1
    v = trace(A);
else
    v = trace_matmul(A,B);
end
