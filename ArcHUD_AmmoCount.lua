require "base/internal/ui/reflexcore"

ArcHUD_AmmoCount =
{
};
registerWidget("ArcHUD_AmmoCount");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_AmmoCount:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 300);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 20);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 30);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", true);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 5);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 0);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
    CheckSetDefaultValue(self.userData, "bQuad", "boolean", 1);
    
end

function ArcHUD_AmmoCount:drawOptions(x,y)
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

    user.bQuad= uiCheckBox(user.bQuad, "Quad indicator", x, y);
    y = y + 30;
     
    saveUserData(user);
end

function ArcHUD_AmmoCount:draw()

    if not shouldShowHUD() then return end;
	local player = getPlayer();
    
    local iconSpacing = 40; --offset icon from text

	-- Options
    local arcRadius = self.userData.arcRadius;
    local arcRaw = self.userData.arcRaw;
    local strokeWidth = self.userData.strokeWidth;
    local bSnapRotation = self.userData.bSnapRotation;
    local snapRotationIndex = self.userData.snapRotationIndex;
    local rotationRaw = self.userData.rotationRaw;
    local barAlpha = self.userData.barAlpha;
    local bQuad = self.userData.bQuad;

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
    local frameColor;
    -- if bQuad and player.carnageTimer > 0 then
    --     frameColor = Color(255,120,128, barAlpha);
    -- else
        frameColor = Color(0,0,0,barAlpha);
    -- end

	local weaponIndexSelected = player.weaponIndexSelected;
	local weapon = player.weapons[weaponIndexSelected];
	local ammo = weapon.ammo;

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
          
    nvgRotate((arcRange-math.pi)/2); --so the text is rendered in the middle of bar
    -- colour changes when low on ammo
	local fontColor = Color(230,230,230,barAlpha*2);
	local glow = false;
	if ammo == 0 then
		fontColor = Color(230, 0, 0,barAlpha*2);
		glow = true;
	elseif ammo < weapon.lowAmmoWarning then
		fontColor = Color(230, 230, 0,barAlpha*2);
		glow = true;
	end

	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    
    if weaponIndexSelected == 1 then ammo = "-" end 
    
    -- if bQuad and player.carnageTimer > 0 then
    --     nvgFontSize(strokeWidth*1.5);
    --     nvgFillColor(Color(255,120,128, barAlpha));
    --     nvgText(0,arcRadius, 'QUAD');
    -- end

    nvgFontSize(strokeWidth);
    -- draw ammo count
    if glow then
	    nvgFontBlur(5);
        nvgFillColor(Color(64, 64, 200));
	    nvgText(0, arcRadius, ammo);
    end
    
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(arcRaw/2, arcRadius, ammo);

    if bQuad and player.carnageTimer > 0 then
        nvgFontSize(strokeWidth*0.8);
        nvgFillColor(Color(255,120,128,barAlpha*2));
        local t = FormatTime(player.carnageTimer);
        nvgText(arcRaw*2, arcRadius, t.seconds);
    end
    
    -- Draw icon    
	local svgName = "internal/ui/icons/weapon" .. weaponIndexSelected;
	iconColor = player.weapons[weaponIndexSelected].color;
    iconColor.a = iconColor.a*2;
	nvgFillColor(iconColor);
	nvgSvg(svgName, -arcRaw, arcRadius, strokeWidth/2*0.75);

    -- GLOBAL ROTATION --
    nvgRotate(-rotation);
end
