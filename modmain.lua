-- Lose all items upon death
local _G = GLOBAL
local R_diao = GetModConfigData("rendiao")
local B_diao = GetModConfigData("baodiao")
local amu_diao = GetModConfigData("amudiao")
local zhuang_bei = GetModConfigData("zbdiao")
local modnillots = GetModConfigData("nillots") or 0
local R_d = R_diao - 3
local B_d = B_diao - 5
if R_d < 0 then R_d = 0 end if B_d < 0 then B_d = 0 end

AddComponentPostInit("container", function(Container, inst)
	function Container:DropSuiji(ondeath)
		local amu_x = true
		local rev_x = true
		for k=1, self.numslots do
			local v = self.slots[k]
			if amu_diao and amu_x and v and v.prefab == "amulet" then -- Drop the amulet
				amu_x = false
				self:DropItem(v)
			end
			if amu_diao and rev_x and v and v.prefab == "reviver" then -- Drop the heart
				rev_x = false
				self:DropItem(v)
			end
		end
		for k=1, self.numslots do -- Randomly drop items in your backpack
			local v = self.slots[math.random(1, self.numslots)]
			if k > math.random(B_d, B_diao) then
				return false
			end
			if v then
				self:DropItem(v)
			end
		end
	end
end)

AddComponentPostInit("inventory", function(Inventory, inst)
	Inventory.oldDropEverythingFn = Inventory.DropEverything
	function Inventory:DropSuiji(ondeath)
		local amu_x = true
		local rev_x = true
		local nillots = modnillots
		for k=1, self.maxslots do
			local v = self.itemslots[k]
			if amu_diao and amu_x and v and v.prefab == "amulet" then -- Drop the amulet
				amu_x = false
				self:DropItem(v, true, true)
			end
			if amu_diao and rev_x and v and v.prefab == "reviver" then -- Drop the heart
				rev_x = false
				self:DropItem(v, true, true)
			end
		end

		for k=1, self.maxslots do -- Randomly drop items on the body
			if k~=1 and k > math.random(R_d, R_diao) then
				return false
			end
			if v then
				self:DropItem(v, true, true)
			end
		end

		for k=1, self.maxslots do -- Count the number of spaces
			if v == nil then
				nillots = nillots + 1
			end
		end
		if nillots == 0 then -- Drop items from a block of your body in order to be able to use your heart to revive
			local v = self.itemslots[1] --math.random(1, self.maxslots)
			if v then
				self:DropItem(v, true, true)
			end
		end
	end

	function Inventory:PlayerSiWang(ondeath)
		for k, v in pairs(self.equipslots) do
			if v:HasTag("backpack") and v.components.container then
				v.components.container:DropSuiji(true)
			end
		end
		if zhuang_bei then
			for k, v in pairs(self.equipslots) do
				if not v:HasTag("backpack") then
					self:DropItem(v, true, true)
				end
			end
		end
		self.inst.components.inventory:DropSuiji(true)
	end

	function Inventory:DropEverything(ondeath, keepequip)
		if not inst:HasTag("player") or inst:HasTag("player") and not inst.components.health  -- If the player is not a player or the player has blood, all items are dropped
		    or inst:HasTag("player") and inst.components.health and inst.components.health.currenthealth > 0 then -- Compatible with substitution
			return Inventory:oldDropEverythingFn(ondeath, keepequip)
		else
			return Inventory:PlayerSiWang(ondeath)
		end
	end
end)

-- Ban deceased player character from being reselected

-- Force character reselect

-- Spawn in with stats temporarily reduced