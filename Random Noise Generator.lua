-- Random Noise Generator
--
-- Random Noise Generator is released under the terms of the MIT Licence.
--
-- Random Noise Generator incorporates modified code from Aseprite Script Examples, Copyright (c) 2018 Igara Studio S.A. Aseprite Script Examples is distributed under the terms of the MIT Licence.

-- Get current cel
local cel = app.cel

-- Display no image error message
if not cel then
    return app.alert("No Image!")
end

-- Create a clone of current image for noise generation
local image = cel.image:clone()

-- Create an undoable action by setting the clone to the image before noise generation
cel.image = image

-- Generate random seed
math.randomseed(os.time())

-- Dialog Box
local dlg = Dialog({title="Random Noise Generator"})

if image.colorMode == ColorMode.RGB then
    dlg:slider{id="red", label="Red", min=0, max=255, value=255}
    dlg:slider{id="green", label="Green", min=0, max=255, value=255}
    dlg:slider{id="blue", label="Blue", min=0, max=255, value=255}
    dlg:separator{id="osep"}
    dlg:slider{id="opacity", label="Opacity", min=0, max=255, value=255}
    dlg:button{id="generate", text="Generate", onclick=function() addNoise() end}
    dlg:button{id="reset", text="Reset", onclick=function() resetSliders() end}
    dlg:button{id="ok", text="OK"}
    dlg:button{id="cancel", text="Cancel", onclick=function() app.undo() dlg:close() end}
elseif image.colorMode == ColorMode.GRAY then
    dlg:slider{id="gray", label="Gray", min=0, max=255, value=255}
    dlg:separator{id="osep"}
    dlg:slider{id="opacity", label="Opacity", min=0, max=255, value=255}
    dlg:button{id="generate", text="Generate", onclick=function() addNoise() end}
    dlg:button{id="reset", text="Reset", onclick=function() resetSliders() end}
    dlg:button{id="ok", text="OK"}
    dlg:button{id="cancel", text="Cancel", onclick=function() app.undo() dlg:close() end}
elseif image.colorMode == ColorMode.INDEXED then
    dlg:separator{id="indsep", text="Indexed (HSL)"}
    dlg:slider{id="hue", label="Hue", min=-180, max=180, value=0}
    dlg:slider{id="sat", label="Saturation", min=-100, max=100, value=0}
    dlg:slider{id="light", label="Lightness", min=-100, max=100, value=0}
    dlg:separator{id="asep"}
    dlg:slider{id="alpha", label="Alpha", min=-100, max=100, value=0}
    dlg:button{id="generate", text="Generate", onclick=function() addNoise() end}
    dlg:button{id="reset", text="Reset", onclick=function() resetSliders() end}
    dlg:button{id="ok", text="OK"}
    dlg:button{id="cancel", text="Cancel", onclick=function() app.undo() dlg:close() end}
end

--Allow the noise generation function to continue when dialog is open
dlg:show({wait=false})

-- Noise generation 
function addNoise()
    local sprite = app.sprite
    local layer = app.layer
    local cel = app.cel
    local noiseImg = cel.image:clone() --Clone noise generation for preview

    -- Undo previous noise before generating new noise
    if noiseImg ~= nil then
        noiseImg = nil
        app.undo()
    end
    
    if image.colorMode == ColorMode.RGB then
        for i in image:pixels() do
            local red = math.random(0, dlg.data.red)
            local green = math.random(0, dlg.data.green)
            local blue = math.random(0, dlg.data.blue)
            local rgb = app.pixelColor.rgba(red, green, blue, dlg.data.opacity)
            i(rgb)
        end
    elseif image.colorMode == ColorMode.GRAY then
        for i in image:pixels() do
            local gray = math.random(0, dlg.data.gray)
            local grey = app.pixelColor.graya(gray, dlg.data.opacity)
            i(grey)
        end
    elseif image.colorMode == ColorMode.INDEXED then
        local n = #app.sprite.palettes[1] -- Get currently selected palette
        if n > 2 then
            local palMask = image.spec.transparentColor -- This returns 0 to confirm the first colour index in the palette to be transparent, but can return a different value if user changes it
            -- Iterate through the entire image to get pixel values for drawing noise to the image
            for i in image:pixels() do 
                local ind = math.random(n)-1 -- Include the first colour index
                if cel.layer.isTransparent then
                    while ind == palMask do
                        ind = math.random(n)-1 -- Take 1 colour index away to accomodate change of transparent colour
                    end
                end
                i(ind) -- Set pixel values based on random values in the palette
            end
        end
    end

    -- Create a transaction in undo history of noise generation to the image and apply changes made to HSL in the indexed colour mode
    app.transaction("Noise Generation", function() if image.colorMode == ColorMode.INDEXED then app.command.HueSaturation {
        ui=false,
        hue=dlg.data.hue,
        saturation=dlg.data.sat,
        lightness=dlg.data.light,
        alpha=dlg.data.alpha
    }
end
cel.image = image end)
app.refresh()
end

-- Reset sliders to default values
function resetSliders()
    if image.colorMode == ColorMode.RGB then
        dlg:modify{id="red", value=255}
        dlg:modify{id="green", value=255}
        dlg:modify{id="blue", value=255}
        dlg:modify{id="opacity", value=255}
    elseif image.colorMode == ColorMode.GRAY then
        dlg:modify{id="gray", value=255}
        dlg:modify{id="opacity", value=255}
    elseif image.colorMode == ColorMode.INDEXED then
        dlg:modify{id="hue", value=0}
        dlg:modify{id="sat", value=0}
        dlg:modify{id="light", value=0}
        dlg:modify{id="alpha", value=0}
    end
end