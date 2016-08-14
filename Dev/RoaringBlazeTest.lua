local A=aura_env
local playerGUID=UnitGUID("player")

local n={}
local t={}
WeakAuras.ImmolateTest=t

local function doCombatTrigger(_,_,subEvent,_,sourceGUID,sourceName,sourceFlags,_,destGUID,destName,destFlags,_,...)
    if sourceGUID==playerGUID then
        if destGUID then n[destGUID]=n[destGUID]or 0 end
        if ...==17962 then
            if subEvent=="SPELL_DAMAGE"then
                n[destGUID]=n[destGUID]+1
            end
        elseif ...==157736 then
            if strsub(subEvent,1,11)=="SPELL_AURA_"then
                n[destGUID]=0
            elseif subEvent=="SPELL_PERIODIC_DAMAGE" then
                local nn=n[destGUID]
                t[nn]=t[nn]or {}
                local amt=select(4,...)
                local crit=select(10,...)
                tinsert(t[nn],crit and (amt/2) or amt)
            end
        end
    end
end
A.doCombatTrigger=doCombatTrigger


/run local function S(t)local a,s,n,f,b=math.huge,0,#t,format b=-a for _,v in ipairs(t)do a=min(a,v)b=max(b,v)s=s+v end print(f("n=%d min=%d avg=%f max=%d spd=%f",n,a,n==0 and"NaN"or f("%f",s/n),b,b/a))end for i=0,3 do S(WeakAuras.ImmolateTest[i])end