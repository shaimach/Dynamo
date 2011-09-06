function m = qft(n)
%m = qft(n)
%
% Create QFT matrix with 2^n rows and cols
%
%usage:
%  m'*x std->f  =fft
%  m *x f->std  =ifft

% matrix dimension
N = 2 ^ n;

w = exp(2 * pi * 1i / N);

%  s = zeros(N);

row = 0:N-1;

for r = 1:N
   m(r,:) = row*(r-1);
end

m = w .^ m;

m = m / sqrt(N);
