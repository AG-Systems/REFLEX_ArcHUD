require "base/internal/ui/reflexcore"

ArcHUD_TrueHealth =
{
};
registerWidget("ArcHUD_TrueHealth");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function round2(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GetStackAfterRocket(h, a, prot)

	local armorProtectionAmount = {};
	armorProtectionAmount[0] = 0.5;
	armorProtectionAmount[1] = 0.66;
	armorProtectionAmount[2] = 0.75;

	local damage = 100; 
	
	local playerArmorProtection = armorProtectionAmount[prot];
	local playerArmor = a;
	local playerHealth = h;
	
	--return playerArmorProtection;
	
	local maxProtectAmount = round2(100 * playerArmorProtection);
	local damageProtectAmount = math.min(maxProtectAmount, playerArmor);
	
	playerArmor = playerArmor - damageProtectAmount;
	damage = damage - damageProtectAmount;
	playerHealth = playerHealth - damage;
	
	local result = {};
	result["health"] = playerHealth;
	result["armor"] = playerArmor;
	return result;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function GetRocketsUntilDeath(player)
	
	-- save the maths, you cant survive a full rocket, ever
	-- also prevents readout from showing -1 after you die
	if player.health < 20 then 
	return 0;
	end
	
	local h = player.health;
	local a = player.armor;
	local prot = player.armorProtection;
	local rocketCount = -1; -- because we want to know how many we can survive and this tells us how many will kill us
	
	while h > 1 do
		h = GetStackAfterRocket(h, a, prot)["health"];
		a = GetStackAfterRocket(h, a, prot)["armor"];
		rocketCount = rocketCount + 1;
	end
	
	return rocketCount;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_TrueHealth:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 320);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 20);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 15);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", false);
    CheckSetDefaultValue(self.userData, "bReverseBar", "boolean", false);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 1);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 130);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_TrueHealth:drawOptions(x,y)
    local sliderWidth = 200
    local sliderStart = 140;
    local user = self.userData;

    uiLabel("Arc radius:", x, y);
    user.arcRadius = clampTo2Decimal(uiSlider(x + sliderStart, y, sliderWidth, 0, 1000, user.arcRadius));
    user.arcRadius = clampTo2Decimal(uiEditBox(user.arcRadius, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;

    uiLabel("Arc angle:", x, y);
    user.arcRaw = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 360, user.arcRaw));
    user.arcRaw = round(uiEditBox(user.arcRaw, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;

    uiLabel("Arc width:", x, y);
    user.strokeWidth = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 300, user.strokeWidth));
    user.strokeWidth = round(uiEditBox(user.strokeWidth, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;

    user.bSnapRotation= uiCheckBox(user.bSnapRotation, "Snap rotation", x, y);
    user.bReverseBar= uiCheckBox(user.bReverseBar, "Reverse bar", x+200, y);
    y = y + 30;

    uiLabel("Rotation snap:", x, y);
    user.snapRotationIndex = round(uiSlider(x + sliderStart, y, sliderWidth, 1, 16, user.snapRotationIndex));
    user.snapRotationIndex = round(uiEditBox(user.snapRotationIndex, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;
    
    uiLabel("Rotation:", x, y);
    user.rotationRaw = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 360, user.rotationRaw));
    user.rotationRaw = round(uiEditBox(user.rotationRaw, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;    

    uiLabel("Bar alpha:", x, y);
    user.barAlpha = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 255, user.barAlpha));
    user.barAlpha = round(uiEditBox(user.barAlpha, x + sliderStart + sliderWidth + 10, y, 60)); --60 = ?
    y = y + 40;   
     
    saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_TrueHealth:draw()
    
    if not shouldShowHUD() then return end;
    local player = getPlayer();

    -- Options
    local arcRadius = self.userData.arcRadius;
    local arcRaw = self.userData.arcRaw;
    local strokeWidth = self.userData.strokeWidth;
    local bSnapRotation = self.userData.bSnapRotation;
    local snapRotationIndex = self.userData.snapRotationIndex;
    local rotationRaw = self.userData.rotationRaw;
    local barAlpha = self.userData.barAlpha;
    local bReverseBar = self.userData.bReverseBar;

    local arcRange = getRads(arcRaw);
    local rotation = getRads(self.userData.rotationRaw);

    local rotationSnap = {};
    rotationSnap[1] = 0;                    --bottom right
    -- bottom right centered
    rotationSnap[3] = (math.pi/2-arcRange);  --bottom center right --2,3,4
    rotationSnap[4] = (math.pi-arcRange)/2; --bottom center
    rotationSnap[5] = math.pi/2;            --bottom center left
    -- bottom left centered
    rotationSnap[7] = (math.pi-arcRange);   --bottom left --5,6,7
    rotationSnap[8] = (math.pi-arcRange/2); --left center
    rotationSnap[9] = (math.pi);            --top left
    -- top left centered
    rotationSnap[11] = rotationSnap[3]-math.pi;     --top center left
    rotationSnap[12] = rotationSnap[4]-math.pi;    --top center 
    rotationSnap[13] = rotationSnap[5]-math.pi;    --top center right
    -- top right centered
    rotationSnap[15] = rotationSnap[7]-math.pi;   --top right
    rotationSnap[16] = rotationSnap[8]-math.pi;    --right center
    --centered in each segment
    rotationSnap[2] = rotationSnap[4]-math.pi/4; 
    rotationSnap[6] = rotationSnap[2]+math.pi/2;
    rotationSnap[10] = rotationSnap[2]+math.pi;
    rotationSnap[14] = rotationSnap[2]-math.pi/2;

    if(bSnapRotation) then rotation = rotationSnap[snapRotationIndex]
        else rotation = getRads(rotationRaw) end    
    -- Colors
    local frameColor = Color(0,0,0,barAlpha);
    local barColor = Color(232,157,12,barAlpha);

    -- GLOBAL ROTATION --
    nvgRotate(rotation);

    -- Frame
    nvgBeginPath();
    nvgStrokeWidth(strokeWidth);
    local frameRot = math.pi/90/4; --todo - calcualte proper angle ---- works decent-ish
    nvgRotate(-frameRot/8);    --purposefuly rotate and create bigger frame to fix gaps between elements
    nvgArc(0, 0, arcRadius, 0, arcRange+frameRot/2, 2);
    nvgRotate(frameRot/8);
    nvgRotate(frameRot);
    arcRange = arcRange - frameRot*2;
    nvgStrokeColor(frameColor);
    nvgStroke();

    local nSegments = arcRange/3;
    for segments = 0, GetRocketsUntilDeath(player) do              
        if segments ~= 0 then
            -- Bar Segments
            nvgBeginPath();
            nvgStrokeWidth(strokeWidth*0.8);
            if bReverseBar then 
                nvgRotate(arcRange);
                nvgArc(0,0,arcRadius, 0, -nSegments+math.pi/180+frameRot, 1);
                nvgRotate(-arcRange);
            else
                nvgArc(0,0, arcRadius, 0, nSegments-math.pi/180+frameRot, 2);
            end
            nvgStrokeColor(barColor);
            nvgStroke();

            if bReverseBar then nvgRotate(-nSegments-math.pi/360/2) else nvgRotate(nSegments+math.pi/360/2  ) end
        end
    end
end

function getRads(x)
    local rads = x * (math.pi/180);
    return rads;
end
