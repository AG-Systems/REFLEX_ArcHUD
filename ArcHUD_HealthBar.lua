require "base/internal/ui/reflexcore"

ArcHUD_HealthBar =
{
};
registerWidget("ArcHUD_HealthBar");


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function ArcHUD_HealthBar:initialize()
    self.userData = loadUserData();

    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "arcRadius", "number", 300);
    CheckSetDefaultValue(self.userData, "arcRaw", "number", 50);
    CheckSetDefaultValue(self.userData, "strokeWidth", "number", 30);
    CheckSetDefaultValue(self.userData, "bSnapRotation", "boolean", true);
    CheckSetDefaultValue(self.userData, "snapRotationIndex", "number", 6);
    CheckSetDefaultValue(self.userData, "rotationRaw", "number", 0);
    CheckSetDefaultValue(self.userData, "barAlpha", "number", 150);
    CheckSetDefaultValue(self.userData, "bReverseBar", "boolean", 0);
end

function ArcHUD_HealthBar:drawOptions(x,y)
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

function ArcHUD_HealthBar:draw()
 
    if not shouldShowHUD() then return end;
    local player = getPlayer();
    local showFrame = true; --unused, always truew
    -- local flatBar = false;

    local arcRadius = self.userData.arcRadius;
    local arcRaw = self.userData.arcRaw;
    local strokeWidth = self.userData.strokeWidth;
    local bSnapRotation = self.userData.bSnapRotation;
    local snapRotationIndex = self.userData.snapRotationIndex;
    local rotationRaw = self.userData.rotationRaw;
    local barAlpha = self.userData.barAlpha;
    local bReverseBar = self.userData.bReverseBar;
	
    local barColorRaw = self.userData.barColorRaw;
    local barBgColorRaw = self.userData.barBgColorRaw;
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
    colors[1] = Color(16,60,217, barAlha);
    colors[2] = Color(2,210,46, barAlpha);
    colors[3] = Color(255,154,30, barAlpha);
    colors[4] = Color(240,36,0,barAlpha);

    local barColor;
    local overhealBarColor = colors[1];
    if player.health > 100 then barColor = colors[2] end
    if player.health <= 100 then barColor = blendColors(colors[2], colors[3], 50, 100, player.health) end
    if player.health <= 50 then barColor = blendColors(colors[3], colors[4], 0, 50, player.health) end

    local bgColors = {}
    bgColors[1] = Color(10,68,127, barAlpha); --unused
    bgColors[2] = Color(14,53,9, barAlpha);
    bgColors[3] = Color(105,67,4, barAlpha);
    bgColors[4] = Color(141,30,10, barAlpha);

    local barBackgroundColor;    
    if player.health > 100 then barBackgroundColor = bgColors[2] end
    if player.health <= 100 then barBackgroundColor = blendColors(bgColors[2], bgColors[3], 50, 100, player.health) end
    if player.health <= 50 then barBackgroundColor = blendColors(bgColors[3], bgColors[4], 0, 50, player.health) end

    -- GLOBAL ROTATION --
    nvgRotate(rotation);

    -- Frame
    if showFrame then
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
    end

    -- Background bar
    nvgBeginPath();
    nvgStrokeWidth(strokeWidth*0.8);
    nvgArc(0, 0, arcRadius, 0, arcRange, 2);
    nvgStrokeColor(barBackgroundColor);
    nvgStroke();

    -- Bar
    nvgBeginPath();
    nvgStrokeWidth(strokeWidth*0.8);
    if player.health > 100 then barRads = arcRange --if over 100 hp, render it full size, overheal bar is on top
        else barRads = player.health/100*arcRange end --else hp / 100 * angle to get rad value
    if bReverseBar then 
        nvgRotate(arcRange);
        nvgArc(0,0,arcRadius, 0, -barRads, 1);
        nvgRotate(-arcRange);
    else
        nvgArc(0, 0, arcRadius, 0, barRads, 2);
    end
    nvgStrokeColor(barColor);
    nvgStroke();

  -- Overheal bar (100+hp)
    if(player.health > 100) then
        nvgBeginPath();
        nvgStrokeWidth(strokeWidth*0.8);
        local barRads = (player.health-100)/100*arcRange;
        if bReverseBar then 
            nvgRotate(arcRange);
            nvgArc(0,0,arcRadius, 0, -barRads, 1);
            nvgRotate(-arcRange);
        else
            nvgArc(0, 0, arcRadius, 0, barRads, 2);
        end
        nvgStrokeColor(overhealBarColor);
        nvgStroke();
    end

    -- Shading 
    -- TODO - attempt shading
    if flatBar == false then
        -- nvgBeginPath();
        -- nvgArc(0, 0, arcRadius, 0, arcRange, 2);
        -- \nvgRotate(math.pi/2);
        -- nvgStrokeLinearGradient(-math.cos(arcRange)*arcRadius, math.sin(arcRange)*arcRadius, math.cos(arcRange)*arcRadius, (1-math.sin(arcRange))*arcRadius, Color(255,255,255,0), Color(255,255,255,200));
        -- nvgStrokeLinearGradient(math.sin(arcRange)*arcRadius, arcRadius, (1-math.sin(arcRange))*arcRadius, arcRadius, Color(255,0,0,200), Color(0,0,255,200));

        -- nvgStrokeLinearGradient(startx, starty, endx, endy, startcol, endcol)wd
        -- nvgFillRadialGradient(0, arcRadius, math.pi-rotation, rotation, Color(255,255,255,0), Color(255,255,255,255));        
        -- nvgFillLinearGradient(barLeft, barTop, barLeft, barBottom, Color(255,255,255,30), Color(255,255,255,0))
        -- nvgFill();
        -- nvgStrokeWidth(strokeWidth);
        -- nvgStroke();
        -- nvgBeginPath();
        -- nvgMoveTo(barLeft, barTop);
        -- nvgLineTo(barRight, barTop);
        -- nvgStrokeWidth(1)
        -- nvgStrokeColor(Color(255,255,255,60));
        -- nvgStroke();
    end
          
    -- hp count
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    nvgFontFace(FONT_HUD);
    nvgRotate((arcRange-math.pi)/2); --so the text is rendered in the middle of bar
    --background
    nvgFontBlur(4);
    nvgFillColor(Color(0, 0, 0,barAlpha*6));
    nvgFontSize(strokeWidth);
    if player.hasMega then
        nvgText(0,arcRadius,player.health .. ' - MEGA' );
    else
        nvgText(0, arcRadius, player.health);
    end
    --foreground
    nvgFontBlur(0);
    nvgFillColor(Color(255,255,255,barAlpha*2));
    nvgFontSize(strokeWidth);
    if player.hasMega then
        nvgText(0,arcRadius,player.health .. ' - MEGA' );
    else
        nvgText(0, arcRadius, player.health);
    end
end

--returns a blend between color X and Y
function blendColors(x, y, min, max, perc)
    local range = max - min;
    if perc > range then perc = perc - range end
    local red = ((perc / range) * x.r) + ((1-(perc/range)) * y.r);
    local green = ((perc / range) * x.g) + ((1-(perc/range)) * y.g);
    local blue = ((perc / range) * x.b) + ((1-(perc/range)) * y.b);
    return Color(red,green,blue,x.a);
end

function colorToString(color)
    return color.r .. ' ' .. color.g .. ' ' .. color.b .. ' ' ..color.a;
end
function getRads(x)
    return x * (math.pi/180);
end
