function()
	local A, t = aura_env, GetTime()
	if t - A.t > A.dt then
		A.t = t
		A.updateDisplay()
	end
	return A.display
end