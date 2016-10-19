sven_storm_bolt_lua = class({})

function sven_storm_bolt_lua:OnSpellStart()
	self.storm_bolt_speed = self:GetSpecialValueFor( "bolt_speed" )
	self.storm_bolt_width = self:GetSpecialValueFor( "bolt_width" )
	self.storm_bolt_distance = self:GetSpecialValueFor( "max_range" )
	self.storm_bolt_damage = self:GetAbilityDamage()
	self.storm_bolt_knockback_distance = self:GetSpecialValueFor("bolt_knockback")
	self.storm_bolt_knockback_duration = self:GetSpecialValueFor("bolt_knockback_duration")
	self.storm_bolt_aoe = self:GetSpecialValueFor("bolt_aoe")
	self.storm_bolt_vision_radius = self:GetSpecialValueFor("vision_radius")

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local info = {
		EffectName = "particles/units/heroes/hero_sven/sven_s_2pell_storm_bolt.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.storm_bolt_width,
		fEndRadius = self.storm_bolt_width,
		vVelocity = vDirection * self.storm_bolt_speed,
		fDistance = self.storm_bolt_distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bDeleteOnHit = true,
		bProvidesVision = true,
		iVisionRadius = self.storm_bolt_vision_radius,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber()
	}

	self.storm_bolt_projectile_id = ProjectileManager:CreateLinearProjectile( info )

	GameMode.projectile_table[self.storm_bolt_projectile_id] = info 

	EmitSoundOn( "Hero_Sven.StormBolt", self:GetCaster() )
end

function sven_storm_bolt_lua:OnProjectileThink( vLocation )
	-------vSpawnOrigin now tracks the vLocation of projectile----------------
	GameMode.projectile_table[self.storm_bolt_projectile_id].vSpawnOrigin = vLocation
end

--------------------------------------------------------------------------------
function sven_storm_bolt_lua:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), 
										vLocation, 
										self:GetCaster(),
										self.storm_bolt_aoe,
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										0, 
										false )

		for _, unit in pairs (enemies) do
				local damage = {
					victim = unit,
					attacker = self:GetCaster(),
					damage = self.storm_bolt_damage,
					damage_type = self:GetAbilityDamageType(),
				}
				ApplyDamage( damage )

				local knockbackProperties = {
					center_x = vLocation.x,
        			center_y = vLocation.y,
        			center_z = vLocation.z,
        			duration = self.storm_bolt_knockback_duration,
       				knockback_duration = self.storm_bolt_knockback_duration,
        			knockback_distance = self.storm_bolt_knockback_distance,
        			knockback_height = 0
				}
				unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )

				EmitSoundOn( "Hero_Sven.StormBoltImpact", unit )
		end

		ProjectileManager:DestroyLinearProjectile( self.storm_bolt_projectile_id )

		GameMode.projectile_table[self.storm_bolt_projectile_id] = nil
	end
end
--------------------------------------------------------------------------------


