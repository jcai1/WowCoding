local function pq_create()return{keys={},vals={},n=0}end
local function pq_push(a,b,c)local d,e,f=a.keys,a.vals,a.n;f=f+1;a.n=f;d[f]=b;e[f]=c;while f>1 do local g=floor(f/2)if d[g]>d[f]then local h=d[g]d[g]=d[f]d[f]=h;h=e[g]e[g]=e[f]e[f]=h;f=g else break end end end
local function pq_peek(a)return a.keys[1],a.vals[1]end
local function pq_pop(a)local d,e,f,b,c=a.keys,a.vals,a.n;if f==0 then return end;b,c=d[1],e[1]d[1]=d[f]d[f]=nil;e[1]=e[f]e[f]=nil;f=f-1;a.n=f;local g=1;while true do local i,j=2*g;if i>f then break elseif i==f or d[i]<=d[i+1]then j=i else j=i+1 end;if d[g]>d[j]then local h;h=d[g]d[g]=d[j]d[j]=h;h=e[g]e[g]=e[j]e[j]=h end;g=j end;return b,c end
