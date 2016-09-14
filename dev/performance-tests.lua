/run local function f(a,b)return a,b end;local guid=UnitGUID("pet")local t=debugprofilestop()for i=1,100000 do gsub(guid, "(%w*)-.*-(%d*)-%w*", f)end; print(debugprofilestop()-t)
-- 1.350 us | GUID parsing, gsub method

/run local g=UnitGUID("pet")local t=debugprofilestop()for i=1,100000 do local s,a,b,c,d,e,x,y=strfind; a=s(g,"-",1,true);b=strrev(g);c=s(b,"-",1,true);d=s(b,"-",c+1,true);e=strlen(g);x=strsub(g,1,a-1);y=strsub(g,e-d+2,e-c) end; print(debugprofilestop()-t)
-- 2.300 us | GUID parsing, strfind/strrev method

/run D,g=debugprofilestop,UnitGUID("pet")
/run local t=D()for i=1,100000 do local a,b,c,d,e,x,y;a=strlen(g)b={string.byte(g,1,a)}c=1;while b[c]~=45 do c=c+1 end;d=a;while b[d]~=45 do d=d-1 end;e=d-1;while b[e]~=45 do e=e-1 end;x=strsub(g,1,c-1)y=strsub(g,e+1,d-2)end print(D()-t)
-- 6.000 us | GUID parsing, string.bytes method

/run local band = bit.band; local t=debugprofilestop(); local x = 1753924; for i=1,200000 do band(x, 1);band(x, 1);band(x, 1);band(x, 1);band(x, 1) end; print(debugprofilestop()-t)
-- 0.110 us | bit.band time

/run local function f() end; local t=debugprofilestop(); for i=1,200000 do f() f() f() f() f() end; print(debugprofilestop()-t)
-- 0.050 us | function call time

/run local t=debugprofilestop(); local x = 1753924; for i=1,200000 do local y=x%2;y=x%2;y=x%2;y=x%2;y=x%2 end; print(debugprofilestop()-t)
-- 0.029 us | div/modulo time

/run local x={a=5}; local t=debugprofilestop(); for i=1,200000 do local y=x.a;y=x.a;y=x.a;y=x.a;y=x.a end; print(debugprofilestop()-t)
-- 0.036 us | table access time

/run local x={a=5}; local t=debugprofilestop(); for i=1,200000 do x.a=5;x.a=5;x.a=5;x.a=5;x.a=5 end; print(debugprofilestop()-t)
-- 0.043 us | table write time

/run local t=debugprofilestop(); for i=1,200000 do local y={}y={}y={}y={}y={} end; print(debugprofilestop()-t)
-- 0.300 us | table creation time

/run local t=debugprofilestop(); for i=1,500000 do local function a(x)return x end; a(i); local function b(x)return x+1 end; b(i) end; print(debugprofilestop()-t)
-- 0.325 us | function call + closure allocation time

/run local function a(x)return x end; local function b(x)return x+1 end; local t=debugprofilestop(); for i=1,500000 do a(i);b(i) end; print(debugprofilestop()-t)
-- 0.125 us | function call time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[r()]=r() end end; local t=debugprofilestop(); for i=1,1000 do wipe(a[i]) end; print(debugprofilestop()-t)
-- 138 us | wipe 1000-entry table via wipe() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[r()]=r() end end; local t=debugprofilestop(); for i=1,1000 do local b=a[i]; for k,v in pairs(b) do b[k]=nil end end; print(debugprofilestop()-t)
-- 260 us | wipe 1000-entry table via pairs() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[j]=r() end end; local t=debugprofilestop(); for i=1,1000 do wipe(a[i]) end; print(debugprofilestop()-t)
-- 73 us | wipe 1000-entry array via wipe() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[j]=r() end end; local t=debugprofilestop(); for i=1,1000 do local b=a[i]; for j=1,#b do b[j]=nil end end; print(debugprofilestop()-t)
-- 51 us | wipe 1000-entry array via for-loop time

/run local z={3,1,4,1,5,9,2,6,5,3}; local t=debugprofilestop(); for i=1,1000000 do local a,b,c,d,e,f,g,h,i,j=unpack(z) end; print(debugprofilestop()-t)
-- 0.215 us | unpack a 10-element array 

/run local a,b,c,d="JhhBVJPxjoZY9p9h3ovl","ykoFHuxSQR5JudpW2trk" c=a..b d=a..b local t=debugprofilestop() for i=1,1000000 do local _=(c==d) end; print(debugprofilestop()-t)
-- 0.020 us | compare two equal 40-chararacter strings

/run local t=debugprofilestop() for i=1,1000000 do GetTime() end; print(debugprofilestop()-t)
-- 0.051 us | call GetTime()
