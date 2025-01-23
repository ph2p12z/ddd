if not _G.Initialized then
	_G.Initialized = true;
	local RunService = game:GetService("RunService");
	local Camera = workspace.CurrentCamera;
	local IgnoreFolder = workspace:WaitForChild("Ignore");
	local WeaponInfo = {};
	local SleepAnimationId = "rbxassetid://13280887764";

	local function InitializeWeapons()
		local ReplicatedStorage = game:GetService("ReplicatedStorage");
		local Items = ReplicatedStorage:WaitForChild("HandModels");
		for _, item in pairs(Items:GetChildren()) do
			item:SetAttribute("RealName", item.Name);
		end
	end

	local function IsSleeping(Player)
		local Animations = Player.AnimationController:GetPlayingAnimationTracks();
		for _, animation in pairs(Animations) do
			if animation.IsPlaying and animation.Animation.AnimationId == SleepAnimationId then
				return true;
			end
		end
		return false;
	end

	local function CreateDrawingElements()
		local Box = Drawing.new("Square");
		local Name = Drawing.new("Text");
		local Weapon = Drawing.new("Text");
		local Distance = Drawing.new("Text");

		Box.Visible = false;
		Box.Color = Color3.fromRGB(255, 255, 255);
		Box.Thickness = 1;
		Box.Transparency = 1;

		Name.Visible = false;
		Name.Color = Color3.fromRGB(255, 255, 255);
		Name.Size = 14;
		Name.Center = true;
		Name.Outline = true;

		Weapon.Visible = false;
		Weapon.Color = Color3.fromRGB(255, 255, 255);
		Weapon.Size = 14;
		Weapon.Center = true;
		Weapon.Outline = true;

		Distance.Visible = false;
		Distance.Color = Color3.fromRGB(255, 255, 255);
		Distance.Size = 14;
		Distance.Center = true;
		Distance.Outline = true;

		return {Box = Box, Name = Name, Weapon = Weapon, Distance = Distance};
	end

	local function GetPlayerWeapon(Player)
		local Model = Player:FindFirstChildOfClass("Model");
		return Model and Model:GetAttribute("RealName") or "None";
	end

	local function IsValidPlayer(Model)
		return Model.ClassName == "Model" and Model:FindFirstChild("Torso") and Model.PrimaryPart ~= nil;
	end

	local PlayerDrawings = {};
	InitializeWeapons();

	RunService.Heartbeat:Connect(function()
		local DistanceLimit = 1500;
		local IncludeSleepers = false;

		for _, Player in pairs(workspace:GetChildren()) do
			if PlayerDrawings[Player] or IsValidPlayer(Player) then
				if not PlayerDrawings[Player] then
					PlayerDrawings[Player] = CreateDrawingElements();
				end

				local Drawings = PlayerDrawings[Player];
				local Position = Player.PrimaryPart.Position;
				local CameraPosition = Camera.CFrame.Position;
				local Distance = (CameraPosition - Position).Magnitude;

				if Distance > DistanceLimit or (not IncludeSleepers and IsSleeping(Player)) then
					Drawings.Box.Visible = false;
					Drawings.Name.Visible = false;
					Drawings.Weapon.Visible = false;
					Drawings.Distance.Visible = false;
					continue;
				end

				local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Position);
				if OnScreen then
					Drawings.Box.Visible = false;
					Drawings.Distance.Visible = true;
					Drawings.Name.Visible = true;
					Drawings.Weapon.Visible = true;

					Drawings.Distance.Text = "[" .. math.round(Distance) .. "m]";
					Drawings.Weapon.Text = GetPlayerWeapon(Player);

					if Player.Head.Nametag.tag.Text ~= "" then
						Drawings.Name.Text = Player.Head.Nametag.tag.Text;
					end

					local Size = 1000 / Distance;
					Drawings.Box.Size = Vector2.new(Size, Size);
					Drawings.Box.Position = Vector2.new(ScreenPosition.X - Size / 2, ScreenPosition.Y - Size / 2);
					Drawings.Name.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y - Size / 2 - 15);
					Drawings.Weapon.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y - Size / 2 - 30);
					Drawings.Distance.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y + Size / 2 + 5);
				else
					Drawings.Box.Visible = false;
					Drawings.Name.Visible = false;
					Drawings.Weapon.Visible = false;
					Drawings.Distance.Visible = false;
				end
			end
		end

		for Player, Drawings in pairs(PlayerDrawings) do
			if not Player or not Player.Parent then
				for _, Drawing in pairs(Drawings) do
					Drawing:Remove();
				end
				PlayerDrawings[Player] = nil;
			end
		end
	end)
end
