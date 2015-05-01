require "base/internal/ui/reflexcore"

--made by FTr :]

ArcHUD_ArmorBar =
{
};
registerWidget("ArcHUD_ArmorBar");


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_ArmorBar:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 330);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 40);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 30);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", true);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 5);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 0);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
    CheckSetDefaultValue(self.userData, "bReverseBar", "boolean", 1);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_ArmorBar:drawOptions(x,y)
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

function ArcHUD_ArmorBar:draw()
        
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

    local colors = {}
    colors[1] = Color(2,167,46, barAlpha);
    colors[2] = Color(245,215,50, barAlpha);
    colors[3] = Color(236,0,0, barAlpha);

    local barColor = colors[player.armorProtection+1];

    local bgcolors = {}
    bgcolors[1] = Color(16,53,9, barAlpha);
    bgcolors[2] = Color(122,111,50, barAlpha);
    bgcolors[3] = Color(141,30,10, barAlpha);

    local barBackgroundColor = bgcolors[player.armorProtection+1];

    

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

    local fillWidth;
    if player.armorProtection == 0 then fillWidth = math.min((arcRange / 100) * player.armor, arcRange); --always fills the meter based on armor type
    elseif player.armorProtection == 1 then fillWidth = math.min((arcRange / 150) * player.armor, arcRange);
    elseif player.armorProtection == 2 then fillWidth = (arcRange / 200) * player.armor;
    end

    -- Background
    nvgBeginPath();
    nvgStrokeWidth(strokeWidth*0.8);
    nvgArc(0,0,arcRadius, 0, arcRange, 2);
    nvgStrokeColor(barBackgroundColor);
    nvgStroke();
    
    -- Bar
    nvgBeginPath();
    nvgStrokeWidth(strokeWidth*0.8);
    if bReverseBar then 
        nvgRotate(arcRange);
        nvgArc(0,0,arcRadius, 0, -fillWidth, 1);
        nvgRotate(-arcRange);
    else
        nvgArc(0,0, arcRadius, 0, fillWidth, 2);
    end
    nvgStrokeColor(barColor);
    nvgStroke();
    
    -- Armor count
    nvgRotate((arcRange-math.pi)/2); --so the text is rendered in the middle of bar

    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    nvgFontFace(FONT_HUD);
    --background
    nvgFontBlur(4);
    nvgFillColor(Color(0,0,0,barAlpha*6));
    nvgFontSize(strokeWidth * 1.1);
    nvgText(0,arcRadius, player.armor);
    --foreground
    nvgFontBlur(0);
    nvgFillColor(Color(255,255,255,barAlpha*2));
    nvgFontSize(strokeWidth);
    nvgText(0, arcRadius, player.armor);
end

function blendColors(x, y, min, max, amount)
    local red   = (x.r*amount/(100) + y.r*(100-amount)/(100));
    if red > 255 then red = red / 2 end
    local green = (x.g*amount/(100) + y.g*(100-amount)/(100));
    if green > 255 then green = green / 2 end
    local blue  = (x.b*amount/(100) + y.b*(100-amount)/(100));
    if blue > 255 then blue = blue / 2 end
    -- local alpha = (x.a + y.a) / 2;
    return Color(red,green,blue,x.a);
end

function colorToString(color)
    return color.r .. ' ' .. color.g .. ' ' .. color.b .. ' ' ..color.a;
end
function getRads(x)
    local rads = x * (math.pi/180);
    return rads;
end