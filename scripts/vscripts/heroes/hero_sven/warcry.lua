function ReflectPhysical( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken

	if damageTaken == 100 and attacker ~= nil then
		for k, v in pairs(attacker.last_attacker) do 
			attacker.last_attacker[k] = nil 
		end		
		attacker.last_attacker["last_attacker_id"] = caster:GetPlayerID()

		local damagetable = {
			victim = attacker,
			attacker = caster,
			damage = damageTaken,
			damage_type = DAMAGE_TYPE_PURE
		 }

		ApplyDamage( damagetable )

		keys.ability:ApplyDataDrivenModifier(caster, attacker, "modifier_warcry_stunned", {})
		caster:SetHealth(caster:GetHealth() + damageTaken)


		EmitSoundOn( "Hero_Sven.GodsStrength", attacker )
		caster:StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 )
	end
end