modifier_sven_woosh_thinker_lua = class({})

function modifier_sven_woosh_thinker_lua:IsHidden()
	return true
end

function modifier_sven_woosh_thinker_lua:OnCreated( kv )
	self.centre = self:GetParent():GetAbsOrigin()
	self.aoe = self:GetAbility():GetSpecialValueFor("woosh_radius")
	self.team_number = self:GetAbility():GetCaster():GetTeamNumber()
	self.multiplier = self:GetAbility():GetSpecialValueFor("speed_multiplier")
	self.caster = self:GetAbility():GetCaster()

	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_sven_woosh_thinker_lua:OnIntervalThink()
	if IsServer() then
		for id, infotable in pairs(GameMode.projectile_table) do
			if math.sqrt( math.pow(infotable.vSpawnOrigin.x - self.centre.x, 2) + 
				math.pow(infotable.vSpawnOrigin.y - self.centre.y, 2) + 
				math.pow(infotable.vSpawnOrigin.z - self.centre.z, 2)
				) < self.aoe + 1 and infotable.iVisionTeamNumber ~= self.team_number then

				ProjectileManager:DestroyLinearProjectile( id )
				GameMode.projectile_table[ id ] = nil



				reflect_info = infotable
				reflect_info.Source = self.caster
				reflect_info.Ability = self:GetAbility()
				reflect_info.iVisionTeamNumber = self.team_number
				local speed = (reflect_info.vVelocity.x/ reflect_info.vVelocity:Normalized().x)*self.multiplier
				reflect_info.vVelocity = self.caster:GetForwardVector():Normalized() * speed
				reflect_info.vSpawnOrigin = self.centre

				self:GetAbility():ReflectBolt( reflect_info )

				--for k, v in pairs(reflect_info) do
					--print(k, v)
				--end
			end
		end
		UTIL_Remove( self:GetParent() )
	end
end

