return function(loveframes)
    local canvasobject = loveframes.NewObject("canvas", "loveframes_object_canvas", true)

    function canvasobject:initialize()
        self.type = "canvas"
        self.width = 100
        self.height = 100
        self.canvas = love.graphics.newCanvas(self.width, self.height)
        self.OnCanvasDraw = nil
        self.canCheckHover = false
    end

    function canvasobject:draw()
        love.graphics.draw(self.canvas, self.x, self.y)
    end

    function canvasobject:update(elapsed)
        self.canvas:renderTo(function()
            if self.OnCanvasDraw then
                self.OnCanvasDraw(self)
            end
        end)


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
            update(self, elapsed)
        end
    end

    function canvasobject:SetSize(w, h)
        self.width = w
        self.height = h
        self.canvas = love.graphics.newCanvas(self.width, self.height)
    end
end
