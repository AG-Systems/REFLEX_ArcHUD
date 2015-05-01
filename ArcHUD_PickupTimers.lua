require "base/internal/ui/reflexcore"

ArcHUD_PickupTimers =
{
};
registerWidget("ArcHUD_PickupTimers");

local PickupVis = {};
PickupVis[PICKUP_TYPE_ARMOR50] = {};
PickupVis[PICKUP_TYPE_ARMOR50].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR50].color = Color(0,255,0);
PickupVis[PICKUP_TYPE_ARMOR100] = {};
PickupVis[PICKUP_TYPE_ARMOR100].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR100].color = Color(255,255,0);
PickupVis[PICKUP_TYPE_ARMOR150] = {};
PickupVis[PICKUP_TYPE_ARMOR150].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR150].color = Color(255,0,0);
PickupVis[PICKUP_TYPE_HEALTH100] = {};
PickupVis[PICKUP_TYPE_HEALTH100].svg = "internal/ui/icons/health";
PickupVis[PICKUP_TYPE_HEALTH100].color = Color(60,80,255);
PickupVis[PICKUP_TYPE_POWERUPCARNAGE] = {};
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].svg = "internal/ui/icons/carnage";
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].color = Color(255,120,128);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_PickupTimers:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 360);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 8);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 30);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", true);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 6);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 0);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
    -- CheckSetDefaultValue(self.userData, "bReverseBar", "boolean", 1);
    CheckSetDefaultValue(self.userData, "bSegment", "boolean", 1);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_PickupTimers:drawOptions(x,y)
    local sliderWidth = 200
    local sliderStart = 140;
    local user = self.userData;

    uiLabel("Arc radius:", x, y);
    user.arcRadius = clampTo2Decimal(uiSlider(x + sliderStart, y, sliderWidth, 0, 1000, user.arcRadius));
    user.arcRadius = clampTo2Decimal(uiEditBox(user.arcRadius, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;

    uiLabel("Arc angle:", x, y);
    user.arcRaw = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 360, user.arcRaw));
    user.arcRaw = round(uiEditBox(user.arcRaw, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;

    uiLabel("Arc width:", x, y);
    user.strokeWidth = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 300, user.strokeWidth));
    user.strokeWidth = round(uiEditBox(user.strokeWidth, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;

    user.bSnapRotation= uiCheckBox(user.bSnapRotation, "Snap rotation", x, y);
    -- user.bReverseBar= uiCheckBox(user.bReverseBar, "Reverse bar", x+200, y);
    y = y + 30;

    uiLabel("Rotation snap:", x, y);
    user.snapRotationIndex = round(uiSlider(x + sliderStart, y, sliderWidth, 1, 16, user.snapRotationIndex));
    user.snapRotationIndex = round(uiEditBox(user.snapRotationIndex, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;
    
    uiLabel("Rotation:", x, y);
    user.rotationRaw = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 360, user.rotationRaw));
    user.rotationRaw = round(uiEditBox(user.rotationRaw, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;    

    uiLabel("Bar alpha:", x, y);
    user.barAlpha = round(uiSlider(x + sliderStart, y, sliderWidth, 0, 255, user.barAlpha));
    user.barAlpha = round(uiEditBox(user.barAlpha, x + sliderStart + sliderWidth + 10, y, 60));
    y = y + 40;   

    user.bSegment= uiCheckBox(user.bSegment, "Arc angle = one timer", x, y);
    y = y + 30;

    saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_PickupTimers:draw()
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
    -- local bReverseBar = self.userData.bReverseBar;
    local bSegment = self.userData.bSegment;

    -- local segmentRot = 
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
    
	local barColor = Color(0,0,0,barAlpha)

	-- count pickups
	local pickupCountTotal = 0;
	local pickupCount = 0;
	for k, v in pairs(pickupTimers) do
		pickupCountTotal = pickupCountTotal + 1;

		-- only display timers we care about
		-- (we expose all pickups to SPECATORS only, but we don't want all those pickups in this side list)
		-- (this is only an issue when you're following a player)
		if PickupVis[v.type] ~= nil then
			pickupCount = pickupCount + 1;
		end
	end

	if bSegment then arcRange = arcRange * pickupCount end

	-- GLOBAL ROTATION --
    nvgRotate(rotation);

	local frameRot = math.pi/90/4; --todo - calcualte proper angle ---- works decent-ish
    local segmentGap = math.pi/180;
    local arcSegment = arcRange/pickupCount - segmentGap*(pickupCount-1)/pickupCount;
    
    -- local spaceCount = pickupCount - 1;
    
    -- -- Options
    -- local timerWidth = 100;
    -- local timerHeight = 30;
    -- local timerSpacing = 5; -- 0 or -1 to remove spacing
    
    -- -- Helpers
    -- local rackHeight = (timerHeight * pickupCount) + (timerSpacing * spaceCount);
    -- local rackTop = -(rackHeight / 2);
    -- local timerX = 0;
    -- local timerY = rackTop;

    -- iterate pickups
	for i = 1, pickupCountTotal do
		local pickup = pickupTimers[i];
		local vis = PickupVis[pickup.type];
		if vis ~= nil then
        
			-- Frame background
			nvgBeginPath();
            nvgArc(0, 0, arcRadius, 0, arcSegment, 2) 
            nvgStrokeWidth(strokeWidth);
			nvgStrokeColor(barColor);
            nvgStroke();

			nvgRotate(arcSegment/2-math.pi/2)  --so icon and text is centered

			nvgFillColor(vis.color);
            nvgSvg(vis.svg, -strokeWidth/4, arcRadius, strokeWidth/2*0.75/2);
    
			-- -- Icon
			-- local iconRadius = timerHeight * 0.40;
			-- local iconX = timerX + iconRadius + 5;
			-- local iconY = timerY + (timerHeight / 2);
			-- local iconColor = vis.color;
			-- local iconSvg = vis.svg;
      
			-- Plot icon
			-- nvgFillColor(iconColor);
			-- nvgSvg(iconSvg, iconX, iconY, iconRadius);

			-- Time
			local t = FormatTime(pickup.timeUntilRespawn);
			local time = t.seconds + 60 * t.minutes;

			if time == 0 then
				time = "up";
			end

			if not pickup.canSpawn then
				time = "held";
			end

			--timer text
			nvgFontBlur(0);
			nvgFontFace("TitilliumWeb-Bold");
            nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
			nvgFontSize(strokeWidth/2);
            nvgFillColor(Color(255,255,255,barAlpha*2));
            nvgText(0, arcRadius, time);

            nvgRotate(-arcSegment/2+math.pi/2)  --revert centering
            nvgRotate(segmentGap + arcSegment) --rotate and create space for another segment
		end
    end
end
