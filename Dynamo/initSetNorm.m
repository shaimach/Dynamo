function initSetNorm ()
global OC;

OC.config.normNorm = 1;
OC.config.normNorm = OC.config.normFunc(OC.config.uFinal', OC.config.uFinal);

end
