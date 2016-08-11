-- Path of Building
--
-- Class: DropDown Control
-- Basic drop down control.
--

local DropDownClass = common.NewClass("DropDownControl", function(self, x, y, width, height, list, selFunc, enableFunc)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.list = list or { }
	self.sel = 1
	self.selFunc = selFunc
	self.enableFunc = enableFunc
end)

function DropDownClass:GetPos()
	return type(self.x) == "function" and self:x() or self.x,
		   type(self.y) == "function" and self:y() or self.y
end

function DropDownClass:SelByValue(val)
	for index, listVal in ipairs(self.list) do
		if listVal == val then
			self.sel = index
			return
		end
	end
end

function DropDownClass:IsMouseOver()
	if self.hidden then
		return false
	end
	local x, y = self:GetPos()
	local cursorX, cursorY = GetCursorPos()
	local dropExtra = self.dropped and (self.height - 4) * #self.list + 2 or 0
	local mOver = cursorX >= x and cursorY >= y and cursorX < x + self.width and cursorY < y + self.height + dropExtra
	local mOverComp
	if mOver then
		if cursorY < y + self.height then
			mOverComp = "BODY"
		else
			mOverComp = "DROP"
		end
	end
	return mOver, mOverComp
end

function DropDownClass:Draw()
	if self.hidden then
		return
	end
	local x, y = self:GetPos()
	local enabled = not self.enableFunc or self.enableFunc()
	local mOver, mOverComp = self:IsMouseOver()
	local dropExtra = (self.height - 4) * #self.list + 4
	if not enabled then
		SetDrawColor(0.33, 0.33, 0.33)
	elseif mOver or self.dropped then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.5, 0.5, 0.5)
	end
	DrawImage(nil, x, y, self.width, self.height)
	if self.dropped then
		SetDrawLayer(nil, 5)
		DrawImage(nil, x, y + self.height, self.width, dropExtra)
		SetDrawLayer(nil, 0)
	end
	if not enabled then
		SetDrawColor(0, 0, 0)
	elseif self.dropped then
		SetDrawColor(0.5, 0.5, 0.5)
	elseif mOver then
		SetDrawColor(0.33, 0.33, 0.33)
	else
		SetDrawColor(0, 0, 0)
	end
	DrawImage(nil, x + 1, y + 1, self.width - 2, self.height - 2)
	if not enabled then
		SetDrawColor(0.33, 0.33, 0.33)
	elseif mOver or self.dropped then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.5, 0.5, 0.5)
	end
	local x1 = x + self.width - self.height / 2 - self.height / 4
	local x2 = x1 + self.height / 2
	local y1 = y + self.height / 4
	local y2 = y1 + self.height / 2
	DrawImageQuad(nil, x1, y1, x2, y1, (x1+x2)/2, y2, (x1+x2)/2, y2)
	if self.dropped then
		SetDrawLayer(nil, 5)
		SetDrawColor(0, 0, 0)
		DrawImage(nil, x + 1, y + self.height + 1, self.width - 2, dropExtra - 2)
		SetDrawLayer(nil, 0)
	end
	if enabled then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.66, 0.66, 0.66)
	end
	DrawString(x + 2, y + 2, "LEFT", self.height - 4, "VAR", self.list[self.sel] or "")
	if self.dropped then
		SetDrawLayer(nil, 5)
		local cursorX, cursorY = GetCursorPos()
		self.hoverSel = mOver and math.floor((cursorY - y - self.height) / (self.height - 4)) + 1
		if self.hoverSel and self.hoverSel < 1 then
			self.hoverSel = nil
		end
		for index, val in ipairs(self.list) do
			local y = y + self.height + 2 + (index - 1) * (self.height - 4)
			if index == self.hoverSel then
				SetDrawColor(0.5, 0.4, 0.3)
				DrawImage(nil, x + 2, y, self.width - 4, self.height - 4)
			end
			if index == self.hoverSel or index == self.sel then
				SetDrawColor(1, 1, 1)
			else
				SetDrawColor(0.66, 0.66, 0.66)
			end
			DrawString(x + 2, y, "LEFT", self.height - 4, "VAR", StripEscapes(val))
		end
		SetDrawLayer(nil, 0)
	end
end

function DropDownClass:OnKeyDown(key)
	if self.enableFunc and not self.enableFunc() then
		return
	end
	if key == "LEFTBUTTON" or key == "RIGHTBUTTON" then
		local mOver, mOverComp = self:IsMouseOver()
		if not mOver or (self.dropped and mOverComp == "BODY") then
			self.dropped = false
			return self
		end
		self.dropped = true
	elseif key == "ESCAPE" then
		self.dropped = false
	end
	return self.dropped and self
end

function DropDownClass:OnKeyUp(key)
	if self.enableFunc and not self.enableFunc() then
		return
	end
	if key == "LEFTBUTTON" or key == "RIGHTBUTTON" then
		local mOver, mOverComp = self:IsMouseOver()
		if not mOver then
			self.dropped = false
		elseif mOverComp == "DROP" then
			local x, y = self:GetPos()
			local cursorX, cursorY = GetCursorPos()
			local sel = math.max(1, math.floor((cursorY - y - self.height) / (self.height - 4)) + 1)
			self.sel = sel
			if self.selFunc then
				self.selFunc(sel, self.list[sel])
			end
			self.dropped = false
		end
	end
	return self.dropped and self
end