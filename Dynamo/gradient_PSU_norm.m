function grad = gradient_PSU_norm(subspace_mask)
global OC;

[value_at_point, grad] = OC.config.gradientFunc(subspace_mask);

grad = 2 * real(grad * conj(value_at_point)) / OC.config.normNorm;
