function TrackLastAttacker( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken

	for k, v in pairs(caster.last_attacker) do 
		caster.last_attacker[k] = nil 
	end
	caster.last_attacker[0] = attacker
end