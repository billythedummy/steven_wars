sven_woosh_lua = class({})
LinkLuaModifier( "modifier_sven_woosh_thinker_lua",  LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_sven_woosh_anim_lua", LUA_MODIFIER_MOTION_NONE )

------------------------------------------------

function sven_woosh_lua:GetWooshPoint()
	local caster = self:GetCaster()
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = self:GetSpecialValueFor("woosh_range")
	
	local front_position = origin + fv * distance	
	return front_position
end
-----------------------------------------------
function sven_woosh_lua:OnAbilityPhaseStart( )
	self:GetCaster():StartGesture( ACT_DOTA_ATTACK )
	return true
end	

function sven_woosh_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_ATTACK )
end

-----------------------------------------------
function sven_woosh_lua:OnSpellStart()
	local hCaster = self:GetCaster()
	local centre = self:GetWooshPoint()
	local aoe = self:GetSpecialValueFor("woosh_radius")
	local origin = hCaster:GetAbsOrigin()


	-------------------damage
	local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), 
										centre, 
										hCaster,
										aoe,
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE, 
										0, 
										false )

	if #enemies > 0 then
	--------------sound
		EmitSoundOn("Hero_Sven.Attack", hCaster)
	
		--------------damage
		for _, unit in pairs (enemies) do
			local damageTable = {
			victim = unit, 
			attacker = hCaster,
			damage = self:GetAbilityDamage(),
			damage_type = self:GetAbilityDamageType(),
			}

			ApplyDamage(damageTable)
		end

	end
	------------------------------

	---------------------knockback
	local k_enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), 
										centre, 
										hCaster,
										aoe,
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
										DOTA_UNIT_TARGET_FLAG_NONE, 
										0, 
										false )
	if #k_enemies > 0 then
		for _, unit in pairs (k_enemies) do
			local knockbackProperties = {
       	 	center_x = origin.x,
        	center_y = origin.y,
        	center_z = origin.z,
       		duration = self:GetSpecialValueFor("knockback_duration"),
        	knockback_duration = self:GetSpecialValueFor("knockback_duration"),
        	knockback_distance = self:GetSpecialValueFor("knockback"),
        	knockback_height = 0
			}
			if unit:IsMagicImmune() == true then
				return
			elseif unit:IsMagicImmune() == false then
				unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )	
			end
		end
	end

	local kv = {}
	CreateModifierThinker( self:GetCaster(), 
		self, 
		"modifier_sven_woosh_thinker_lua",
		kv, 
		centre, 
		self:GetCaster():GetTeamNumber(), 
		false )
	------------------------------
end

function sven_woosh_lua:ReflectBolt( infotable )
	self.storm_bolt_projectile_id = ProjectileManager:CreateLinearProjectile( infotable )
	GameMode.projectile_table[self.storm_bolt_projectile_id] = infotable
end

function sven_woosh_lua:OnProjectileThink( vLocation )
	-------vSpawnOrigin now tracks the vLocation of projectile----------------
	GameMode.projectile_table[self.storm_bolt_projectile_id].vSpawnOrigin = vLocation
end

--------------------------------------------------------------------------------
function sven_woosh_lua:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), 
										vLocation, 
										self:GetCaster(),
										255,
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										0, 
										false )

		for _, unit in pairs (enemies) do
				local damage = {
					victim = unit,
					attacker = self:GetCaster(),
					damage = 200,
					damage_type = DAMAGE_TYPE_PURE
				}
				ApplyDamage( damage )

				local knockbackProperties = {
					center_x = vLocation.x,
        			center_y = vLocation.y,
        			center_z = vLocation.z,
        			duration = 0.2,
       				knockback_duration = 0.2,
        			knockback_distance = 400,
        			knockback_height = 0
				}
				unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )

				EmitSoundOn( "Hero_Sven.StormBoltImpact", unit )
		end

		ProjectileManager:DestroyLinearProjectile( self.storm_bolt_projectile_id )

		GameMode.projectile_table[self.storm_bolt_projectile_id] = nil
	end
end
