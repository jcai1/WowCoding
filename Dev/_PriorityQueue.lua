-- Min priority queue where keys are numbers (can easily be generalized)

local function pq_create()
	return {keys = {}, vals = {}, n = 0}
end

local function pq_push(pq, key, val)
	local keys, vals, n = pq.keys, pq.vals, pq.n
	n = n + 1
	pq.n = n
	keys[n] = key
	vals[n] = val
	while n > 1 do
		local p = floor(n / 2)
		if keys[p] > keys[n] then
			local tmp
			tmp = keys[p]; keys[p] = keys[n]; keys[n] = tmp
			tmp = vals[p]; vals[p] = vals[n]; vals[n] = tmp
			n = p
		else
			break
		end
	end
end

local function pq_peek(pq)
	return pq.keys[1], pq.vals[1]
end

local function pq_pop(pq)
	local keys, vals, n = pq.keys, pq.vals, pq.n
	if n == 0 then
		return nil
	end
	local key, val = keys[1], vals[1]
	keys[1] = keys[n]; keys[n] = nil
	vals[1] = vals[n]; vals[n] = nil
	n = n - 1
	pq.n = n
	local p = 1
	while true do
		local c1 = 2 * p
		local c
		if c1 > n then
			break
		elseif c1 == n or keys[c1] <= keys[c1 + 1] then
			c = c1
		else
			c = c1 + 1
		end
		if keys[p] > keys[c] then
			local tmp
			tmp = keys[p]; keys[p] = keys[c]; keys[c] = tmp
			tmp = vals[p]; vals[p] = vals[c]; vals[c] = tmp
		end
		p = c
	end
	return key, val
end
