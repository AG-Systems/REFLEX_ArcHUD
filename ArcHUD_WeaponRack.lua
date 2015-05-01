require "base/internal/ui/reflexcore"

ArcHUD_WeaponRack =
{
};
registerWidget("ArcHUD_WeaponRack");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_WeaponRack:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 270);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 70);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 30);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", true);
    CheckSetDefaultValue(self.userData, "bReverseBar", "boolean", false);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 5);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 0);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
    CheckSetDefaultValue(self.userData, "bSegment", "boolean", false);
    CheckSetDefaultValue(self.userData, "bAvailableOnly", "boolean", true);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_WeaponRack:drawOptions(x,y)
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
    user.bReverseBar= uiCheckBox(user.bReverseBar, "Reverse bar", x+200, y);
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

    user.bSegment= uiCheckBox(user.bSegment, "Arc angle = one timer", x, y); --buggy when used with reverse bar
    user.bAvailableOnly= uiCheckBox(user.bAvailableOnly, "Only available weapons", x+200, y);
    y = y + 30;
     
    saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_WeaponRack:draw()

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
    local bAvailableOnly = self.userData.bAvailableOnly; --display only weapons with ammo
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
    -- Colors
    local frameColor = Color(0,0,0,barAlpha);
    local barColor = Color(232,157,12,barAlpha);

    local weaponCount = 9;
    if bSegment then arcRange = arcRange * weaponCount end

    -- GLOBAL ROTATION --
    nvgRotate(rotation);

    local frameRot = math.pi/90/4; --todo - calcualte proper angle ---- works decent-ish

    local segmentGap = math.pi/180;
    local arcSegment = arcRange/weaponCount - segmentGap*(weaponCount-1)/weaponCount;
    for weaponIndex = 1, weaponCount do --begin for loop

        local weapon = player.weapons[weaponIndex];
		local color = weapon.color;
        if (bAvailableOnly and weapon.pickedup) or not bAvailableOnly then 
		  if not weapon.pickedup then -- if we havent picked up the weapon, colour it grey
                color.r = 128;
		  	color.g = 128;
		  	color.b = 128;
		  end
    
                local outlineColor = Color(color.r,color.g,color.b,lerp(0, 255, player.weaponSelectionIntensity));
                local backgroundColor = Color(0,0,0,barAlpha)    
    
                -- frame
                if bReverseBar then nvgRotate(arcRange) end
                nvgStrokeWidth(strokeWidth);
    
                if weaponIndex == player.weaponIndexSelected then --if the weapon is held, color the bar
                    outlineColor.r = lerp(outlineColor.r, color.r, player.weaponSelectionIntensity);
                    outlineColor.g = lerp(outlineColor.g, color.g, player.weaponSelectionIntensity);
                    outlineColor.b = lerp(outlineColor.b, color.b, player.weaponSelectionIntensity);
                    outlineColor.a = lerp(outlineColor.a, barAlpha, player.weaponSelectionIntensity);
    		  	local outlineColor = Color(color.r,color.g,color.b,lerp(0, barAlpha*2, player.weaponSelectionIntensity));
    
                nvgBeginPath();
                    if bReverseBar then 
                        nvgArc(0, 0, arcRadius, 0, -arcSegment, 1)
                    else 
                        nvgArc(0, 0, arcRadius, 0, arcSegment, 2) 
                    end
                    nvgStrokeColor(outlineColor);
                    nvgStroke();
                else --otherwise grey background
                    nvgBeginPath();
                    if bReverseBar then 
                        nvgArc(0, 0, arcRadius, 0, -arcSegment, 1)
                    else 
                        nvgArc(0, 0, arcRadius, 0, arcSegment, 2) 
                    end
                    nvgStrokeColor(backgroundColor);
                    nvgStroke();
                end
                if bReverseBar then nvgRotate(-arcRange) end
                
                if bReverseBar then 
                    nvgRotate(arcRange-math.pi/2 - arcSegment/2);
                else
                    nvgRotate(arcSegment/2-math.pi/2) 
                end
    
                -- icon
                local iconColor = color;
                if weaponIndex == player.weaponIndexSelected then 
    		  	   iconColor.r = lerp(iconColor.r, 0, player.weaponSelectionIntensity);
    		  	   iconColor.g = lerp(iconColor.g, 0, player.weaponSelectionIntensity);
    		  	   iconColor.b = lerp(iconColor.b, 0, player.weaponSelectionIntensity);
    		  	   iconColor.a = lerp(iconColor.a, 255, player.weaponSelectionIntensity);
                end
                local svgName = "internal/ui/icons/weapon"..weaponIndex;
    		    nvgFillColor(iconColor);
                nvgSvg(svgName, -strokeWidth/4, arcRadius, strokeWidth/2*0.75/2);
    
                -- Ammo
                local ammoCount = player.weapons[weaponIndex].ammo;
                if weaponIndex == 1 then ammoCount = "-" end
                nvgFontSize(strokeWidth/2);
                --nvgFontFace("oswald-bold");
                nvgFontFace("TitilliumWeb-Bold");
                nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
    
                if weaponIndex == player.weaponIndexSelected then 
                    nvgFontBlur(4);
                    nvgFillColor(Color(0,0,0,barAlpha*6));
                    nvgText(0, arcRadius, ammoCount);
                end
    
                nvgFontBlur(0);
                nvgFillColor(Color(255,255,255,barAlpha*2));
                nvgText(0, arcRadius, ammoCount);
    
                if bReverseBar then 
                    nvgRotate(-arcRange+math.pi/2+arcSegment/2);
                else
                    nvgRotate(-arcSegment/2+math.pi/2) 
                end
    
            if bReverseBar and weaponIndex < weaponCount then nvgRotate(-segmentGap - arcSegment) else nvgRotate(segmentGap + arcSegment) end
        end --end if available only
    end --end for loop
end
function getRads(x)
    local rads = x * (math.pi/180);
    return rads;
end
