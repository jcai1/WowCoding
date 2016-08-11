function()
	local A, t = aura_env, GetTime()
	if t - A.t > A.dt then
		A.t = t
		A.updateDisplay()
	elseif t - A.t2 > A.dt2 then
		A.t2 = t
		A.updatePandemic()
	end
	return A.display
end