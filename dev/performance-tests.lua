/run local function f(a,b)return a,b end;local guid=UnitGUID("pet")local t=debugprofilestop()for i=1,100000 do gsub(guid, "(%w*)-.*-(%d*)-%w*", f)end; print(debugprofilestop()-t)
-- 0.910 us | GUID parsing, gsub method

/run local g=UnitGUID("pet")local t=debugprofilestop()for i=1,100000 do local s,a,b,c,d,e,x,y=strfind; a=s(g,"-",1,true);b=strrev(g);c=s(b,"-",1,true);d=s(b,"-",c+1,true);e=strlen(g);x=strsub(g,1,a-1);y=strsub(g,e-d+2,e-c) end; print(debugprofilestop()-t)
-- 0.800 us | GUID parsing, strfind/strrev method

/run D,g=debugprofilestop,UnitGUID("pet")
/run local t=D()for i=1,100000 do local a,b,c,d,e,x,y;a=strlen(g)b={string.byte(g,1,a)}c=1;while b[c]~=45 do c=c+1 end;d=a;while b[d]~=45 do d=d-1 end;e=d-1;while b[e]~=45 do e=e-1 end;x=strsub(g,1,c-1)y=strsub(g,e+1,d-2)end print(D()-t)
-- 3.000 us | GUID parsing, string.bytes method

/run local band = bit.band; local t=debugprofilestop(); local x = 1753924; for i=1,200000 do band(x, 1);band(x, 1);band(x, 1);band(x, 1);band(x, 1) end; print(debugprofilestop()-t)
-- 0.050 us | bit.band time

/run local function f() end; local t=debugprofilestop(); for i=1,200000 do f() f() f() f() f() end; print(debugprofilestop()-t)
-- 0.033 us | function call time

/run local t=debugprofilestop()local x=1753924 for i=1,200000 do local y=x%2;y=x%2;y=x%2;y=x%2;y=x%2 end print(debugprofilestop()-t)
-- 0.009 us | div/modulo time

/run local t=debugprofilestop()local x,sqrt=1753924,sqrt for i=1,200000 do local y=sqrt(x)y=sqrt(x)y=sqrt(x)y=sqrt(x)y=sqrt(x) end print(debugprofilestop()-t)
-- 0.038 us | sqrt time

/run local t=debugprofilestop()local x=1753924 for i=1,200000 do local y=sqrt(x)y=sqrt(x)y=sqrt(x)y=sqrt(x)y=sqrt(x) end print(debugprofilestop()-t)
-- 0.046 us | global sqrt time

/run local x={a=5}; local t=debugprofilestop(); for i=1,200000 do local y=x.a;y=x.a;y=x.a;y=x.a;y=x.a end; print(debugprofilestop()-t)
-- 0.014 us | table access time

/run local x={a=5}; local t=debugprofilestop(); for i=1,200000 do x.a=5;x.a=5;x.a=5;x.a=5;x.a=5 end; print(debugprofilestop()-t)
-- 0.016 us | table write time

/run local t=debugprofilestop(); for i=1,200000 do local y={}y={}y={}y={}y={} end; print(debugprofilestop()-t)
-- 0.160 us | table creation time

/run local t=debugprofilestop(); for i=1,500000 do local function a(x)return x end; a(i); local function b(x)return x+1 end; b(i) end; print(debugprofilestop()-t)
-- 0.170 us | function call + closure allocation time

/run local function a(x)return x end; local function b(x)return x end; local t=debugprofilestop(); for i=1,500000 do a(i);b(i) end; print(debugprofilestop()-t)
-- 0.043 us | function call/return time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[r()]=r() end end; local t=debugprofilestop(); for i=1,1000 do wipe(a[i]) end; print(debugprofilestop()-t)
-- 70 us | wipe 1000-entry table via wipe() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[r()]=r() end end; local t=debugprofilestop(); for i=1,1000 do local b=a[i]; for k,v in pairs(b) do b[k]=nil end end; print(debugprofilestop()-t)
-- 190 us | wipe 1000-entry table via pairs() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[j]=r() end end; local t=debugprofilestop(); for i=1,1000 do wipe(a[i]) end; print(debugprofilestop()-t)
-- 28 us | wipe 1000-entry array via wipe() time

/run local r,a=random,{};for i=1,1000 do local b={}; a[i]=b; for j=1,1000 do b[j]=r() end end; local t=debugprofilestop(); for i=1,1000 do local b=a[i]; for j=1,#b do b[j]=nil end end; print(debugprofilestop()-t)
-- 18 us | wipe 1000-entry array via for-loop time

/run local z={3,1,4,1,5,9,2,6,5,3}; local t=debugprofilestop(); for i=1,1000000 do local a,b,c,d,e,f,g,h,i,j=unpack(z) end; print(debugprofilestop()-t)
-- 0.134 us | unpack a 10-element array 

/run local a,b,c,d="JhhBVJPxjoZY9p9h3ovl","ykoFHuxSQR5JudpW2trk" c=a..b d=a..b local t=debugprofilestop() for i=1,1000000 do local _=(c==d) end; print(debugprofilestop()-t)
-- 0.016 us | compare two equal 40-chararacter strings

/run local t=debugprofilestop() for i=1,1000000 do GetTime() end; print(debugprofilestop()-t)
-- 0.033 us | call GetTime()
