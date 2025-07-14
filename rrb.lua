--// Настройки
local PASSWORD = "private"

--// Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local speedOn = false
local jumpOn = false
local espOn = false
local speedBoost = 90
local jumpBoost = 150
local espObjects = {}
local brainrotMarkers = {}

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "Tw3ch1kBoost"

local function roundify(obj, r)
	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, r)
	uic.Parent = obj
end

--// Пароль окно
local pwFrame = Instance.new("Frame", gui)
pwFrame.Size = UDim2.new(0, 220, 0, 120)
pwFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
pwFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
pwFrame.BorderSizePixel = 0
pwFrame.Active = true
pwFrame.Draggable = true
roundify(pwFrame, 12)

local titlePw = Instance.new("TextLabel", pwFrame)
titlePw.Size = UDim2.new(1, 0, 0, 30)
titlePw.Position = UDim2.new(0, 0, 0, 0)
titlePw.Text = "by:\nTw3ch1k"
titlePw.TextColor3 = Color3.new(1, 1, 1)
titlePw.BackgroundTransparency = 1
titlePw.Font = Enum.Font.GothamBold
titlePw.TextScaled = true

local input = Instance.new("TextBox", pwFrame)
input.Size = UDim2.new(1, -20, 0, 35)
input.Position = UDim2.new(0, 10, 0, 45)
input.PlaceholderText = "Enter password"
input.Text = ""
input.TextColor3 = Color3.new(1, 1, 1)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
input.Font = Enum.Font.Gotham
input.TextScaled = true
roundify(input, 10)

local confirm = Instance.new("TextButton", pwFrame)
confirm.Size = UDim2.new(1, -20, 0, 30)
confirm.Position = UDim2.new(0, 10, 1, -35)
confirm.Text = "✔️ Confirm"
confirm.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
confirm.TextColor3 = Color3.new(1, 1, 1)
confirm.Font = Enum.Font.GothamBold
confirm.TextScaled = true
roundify(confirm, 10)

--// Главное меню
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 280)
main.Position = UDim2.new(0, 60, 0, 120)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
roundify(main, 14)

local glow = Instance.new("UIStroke", main)
glow.Thickness = 2
glow.Color = Color3.fromRGB(0, 255, 150)
glow.Transparency = 0.2

local top = Instance.new("TextLabel", main)
top.Size = UDim2.new(1, -10, 0, 25)
top.Position = UDim2.new(0, 5, 0, 5)
top.Text = "by: Tw3ch1k_scripts"
top.BackgroundTransparency = 1
top.TextColor3 = Color3.new(1, 1, 1)
top.Font = Enum.Font.GothamBold
top.TextScaled = true

local function createButton(text, y)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(1, -20, 0, 25)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	roundify(btn, 10)
	return btn
end

local closeBtn = createButton("× Close", 35)
local speedBtn = createButton("🏃 Speed: OFF", 70)
local jumpBtn = createButton("🦘 Jump: OFF", 105)
local espBtn = createButton("🔍 ESP: OFF", 140)
local serverHopBtn = createButton("🌐 Low Server Hop", 175)

--// Аватарка
local icon = Instance.new("ImageButton", gui)
icon.Size = UDim2.new(0, 72, 0, 72)
icon.Position = UDim2.new(0, 20, 0, 20)
icon.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
icon.AutoButtonColor = true
icon.Draggable = true
icon.Visible = false
roundify(icon, 20)
icon.ZIndex = 10
icon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"

local iconText = Instance.new("TextLabel", icon)
iconText.Size = UDim2.new(1, 0, 0, 20)
iconText.Position = UDim2.new(0, 0, 1, -20)
iconText.Text = "by:\nTw3ch1k"
iconText.TextColor3 = Color3.fromRGB(20, 20, 20)
iconText.Font = Enum.Font.GothamBold
iconText.TextScaled = true
iconText.BackgroundTransparency = 1
iconText.ZIndex = 11

icon.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	icon.Visible = not main.Visible
end)

--// Анимация кнопок
local function animate(btn, state, col)
	TweenService:Create(btn, TweenInfo.new(0.3), {
		BackgroundColor3 = state and col or Color3.fromRGB(30, 30, 30)
	}):Play()
end

--// ESP игроков
local function addESP(plr)
	if plr == player then return end
	local char = plr.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	if espObjects[plr] then
		for _, o in pairs(espObjects[plr]) do if o then o:Destroy() end end
	end
	local boxes = {}
	for _, part in pairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Adornee = part
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
			box.Color3 = Color3.fromRGB(0, 170, 255)
			box.Transparency = 0.3
			box.Parent = part
			table.insert(boxes, box)
		end
	end
	espObjects[plr] = boxes
end

local function removeESP(plr)
	if espObjects[plr] then
		for _, o in pairs(espObjects[plr]) do
			if o then o:Destroy() end
		end
		espObjects[plr] = nil
	end
end

local function toggleESP(active)
	for _, p in pairs(Players:GetPlayers()) do
		if active then
			addESP(p)
		else
			removeESP(p)
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		wait(1)
		if espOn then addESP(plr) end
	end)
end)

Players.PlayerRemoving:Connect(removeESP)

--// Brainrot ESP
brainrotMarkers = {}

local function clearBrainrotMarkers()
	for _, mark in pairs(brainrotMarkers) do
		if mark.ring and mark.ring.Parent then
			mark.ring:Destroy()
		end
	end
	brainrotMarkers = {}
end

local function createRing(position, color)
	local disk = Instance.new("Part")
	disk.Anchored = true
	disk.CanCollide = false
	disk.CastShadow = false
	disk.Shape = Enum.PartType.Cylinder
	disk.Material = Enum.Material.Neon
	disk.Color = color
	disk.Transparency = 0.3
	disk.Size = Vector3.new(30, 1, 30)
	disk.CFrame = CFrame.new(position + Vector3.new(0, 40, 0)) * CFrame.Angles(math.rad(90), 0, 0)
	disk.LocalTransparencyModifier = 0
	disk.Parent = workspace
	return disk
end

local function updateBrainrot()
	for i = #brainrotMarkers, 1, -1 do
		local mark = brainrotMarkers[i]
		if not mark.part or not mark.part:IsDescendantOf(workspace) then
			if mark.ring then mark.ring:Destroy() end
			table.remove(brainrotMarkers, i)
		else
			local dist = (hrp.Position - mark.part.Position).Magnitude
			if dist < 20 then
				if mark.ring and mark.ring.Transparency ~= 1 then
					mark.ring.Transparency = 1
					mark.ring.CanCollide = false
				end
			else
				if mark.ring and mark.ring.Transparency ~= 0.3 then
					mark.ring.Transparency = 0.3
					mark.ring.CanCollide = false
				end
			end
		end
	end
end

local function findBrainrotESP()
	clearBrainrotMarkers()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextBox") then
			local txt = obj.Text
			if txt == "Brainrot God" or txt == "Secret" then
				local root = obj:FindFirstAncestorOfClass("Model")
				if root then
					local part = root.PrimaryPart or root:FindFirstChildWhichIsA("BasePart")
					if part then
						local ring = createRing(part.Position, Color3.fromRGB(255, 0, 0))
						table.insert(brainrotMarkers, {part = part, ring = ring})
					end
				end
			end
		end
	end
end

-- Обновление brainrot ESP каждые 30 секунд
task.spawn(function()
	while true do
		wait(30)
		if espOn then
			findBrainrotESP()
		end
	end
end)

--// Server Hop
local function hopToLowServer()
	local gameId = game.PlaceId
	local http = game:GetService("HttpService")
	local success, pages = pcall(function()
		return http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..gameId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if not success or not pages or not pages.data then return end
	for _, s in pairs(pages.data) do
		if s.playing <= 2 and s.id ~= game.JobId then
			TeleportService:TeleportToPlaceInstance(gameId, s.id)
			break
		end
	end
end

--// Обновление логики
RunService.Heartbeat:Connect(function()
	if speedOn then
		local dir = humanoid.MoveDirection
		if dir.Magnitude > 0 then
			local target = dir.Unit * speedBoost
			local vel = hrp.Velocity
			hrp.Velocity = Vector3.new(
				vel.X + (target.X - vel.X) * 0.3,
				vel.Y,
				vel.Z + (target.Z - vel.Z) * 0.3
			)
		end
	end
	if jumpOn and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
		hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpBoost, hrp.Velocity.Z)
	end
	if espOn then
		updateBrainrot()
	end
end)

--// Кнопки
confirm.MouseButton1Click:Connect(function()
	if input.Text == PASSWORD then
		pwFrame.Visible = false
		main.Visible = true
		icon.Visible = false
	else
		input.Text = ""
		input.PlaceholderText = "Wrong password!"
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	icon.Visible = true
end)

speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	speedBtn.Text = "🏃 Speed: " .. (speedOn and "ON" or "OFF")
	animate(speedBtn, speedOn, Color3.fromRGB(0, 255, 150))
end)

jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	jumpBtn.Text = "🦘 Jump: " .. (jumpOn and "ON" or "OFF")
	animate(jumpBtn, jumpOn, Color3.fromRGB(0, 255, 150))
end)

espBtn.MouseButton1Click:Connect(function()
	espOn = not espOn
	espBtn.Text = "🔍 ESP: " .. (espOn and "ON" or "OFF")
	animate(espBtn, espOn, Color3.fromRGB(0, 255, 150))
	toggleESP(espOn)
	if espOn then findBrainrotESP() else clearBrainrotMarkers() end
end)

serverHopBtn.MouseButton1Click:Connect(function()
	hopToLowServer()
end)