return function(loveframes)
    local gradientobject = loveframes.NewObject("gradient", "loveframes_object_gradient", true)

    function gradientobject:initialize()
        self.type = "gradient"
        self.width = 1
        self.height = 1
        self.orientation = 0
        self.mesh = nil
        self.color = { 1, 1, 1, 1 }
        self.canCheckHover = false

        self:SetDrawFunc()
    end

    function gradientobject:update(elapsed)
        local state = loveframes.state
        local selfstate = self.state

        if state ~= selfstate then
            return
        end

        local visible = self.visible
        local alwaysupdate = self.alwaysupdate

        if not visible then
            if not alwaysupdate then
                return
            end
        end

        local parent = self.parent
        local base = loveframes.base
        local update = self.Update

        if self.canCheckHover then
            self:CheckHover()
        end

        if parent ~= base then
            self.x = self.parent.x + self.staticx - (parent.offsetx or 0)
            self.y = self.parent.y + self.staticy - (parent.offsety or 0)
        end

        if update then
            update(self, dt)
        end
    end

    function gradientobject:SetMesh(mesh)
        if type(mesh) == "userdata" then
            self.mesh = mesh
        end

        return self
    end

    function gradientobject:GetMesh()
        return self.mesh
    end

    function gradientobject:SetColor(r, g, b, a)
        self.color = { r, g, b, a }
        return self
    end

    function gradientobject:GetColor()
        return unpack(self.color)
    end

    function gradientobject:SetOrientation(orientation)
        self.orientation = orientation
        return self
    end

    function gradientobject:GetOrientation()
        return self.orientation
    end
end
