--!TRANSPILED BY DERGLANG!
--- A simple Color3 implementation

type RGB = {
    R: number,
    G: number,
    B: number
}

local Color3 = {}
Color3.__index = Color3

function Color3.new(R: number, G: number, B: number)
    local self = setmetatable({} :: RGB, Color3)
    self.R = R or 0
    self.G = G or 0
    self.B = B or 0
    return self
end

Color3.__add = function(self, color)
    self.R = math.clamp(self.R + color.R, 0, 1)
    self.G = math.clamp(self.G + color.G, 0, 1)
    self.B = math.clamp(self.B + color.B, 0, 1)
end

return {
    Color3 = Color3
}
