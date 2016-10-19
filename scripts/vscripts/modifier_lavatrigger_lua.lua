modifier_lavatrigger_lua = class({})

function modifier_lavatrigger_lua:OnCreated( kv )  
    if IsServer() then
        self:StartIntervalThink( 0 )
    end
end

function modifier_lavatrigger_lua:GetTexture()
	return "lava"
end

function modifier_lavatrigger_lua:IsHidden() return false end
function modifier_lavatrigger_lua:IsDebuff() return true end
function modifier_lavatrigger_lua:RemoveOnDeath() return true end

function modifier_lavatrigger_lua:OnIntervalThink()
	if IsServer() then
		if self:GetParent().last_attacker ~= nil and self:GetParent():IsAlive() then
			local hAttacker = self:GetParent().last_attacker[0]
			local hVictim = self:GetParent()
			local damagetable = {
				victim = hVictim,
				attacker = hAttacker,
				damage = hVictim:GetHealth(),
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage( damagetable )

			ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red_flames01.vpcf", PATTACH_ABSORIGIN , self:GetParent())
		end
	end
end

