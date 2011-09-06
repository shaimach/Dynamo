function gradient = gradient_SU_norm(subspace_mask)
global OC;

[value_at_point, gradient] = OC.config.gradientFunc(subspace_mask);

gradient = real(gradient) / OC.config.normNorm;
