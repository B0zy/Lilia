
local MODULE = MODULE

function MODULE:SaveData()
    self:setData(self.oocBans)
end


function MODULE:LoadData()
    self.oocBans = self:getData()
end


function MODULE:InitializedModules()
    SetGlobalBool("oocblocked", false)
end