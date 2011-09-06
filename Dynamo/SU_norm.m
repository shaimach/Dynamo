function v = SU_norm(varargin)
global OC;

if (nargin==1) && isscalar(varargin{1})     % Input is already the Phi0 norm
    v = varargin{1}; 
else                                        % Input are the data needed to compute the Phi0 norm
    v = Phi0_norm(varargin{:});
end

v = real(v) / OC.config.normNorm;
