-- Dump benchmarks
/run local B,f,t=WeakAuras.regions["Legion Demo Pet Tracker"].region.benchmarks;for n,b in pairs(B) do t={}for k,v in pairs(b)do t[#t+1]=format("{%d,%d}",k,v)end;WeakAurasSaved["BENCH_"..n]=table.concat(t,",")end

-- Clear dumps
/run for k,v in pairs(WeakAurasSaved)do if strfind(k,"^BENCH_")and type(v)=="string" then WeakAurasSaved[k]=nil end end

-- Reset current benchmarks
/run wipe(WeakAuras.regions["Legion Demo Pet Tracker"].region.benchmarks)
