LinkLuaModifier( "modifier_lavatrigger_lua", LUA_MODIFIER_MOTION_NONE )

function OnLavaEnter(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:IsAlive() then
        ent:AddNewModifier( ent, self, "modifier_lavatrigger_lua", {} )
        return
    end
end

function OnLavaExit(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:IsAlive() then
        ent:RemoveModifierByName("modifier_lavatrigger_lua") 
        return
    end
end