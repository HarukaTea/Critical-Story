--!nocheck

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

local AssetBook = {}

AssetBook.TweenInfos = {
	fourHalf = newTweenInfo(0.05),
    fourOneHalf = newTweenInfo(0.1),
	threeHalf = newTweenInfo(0.15),
	twiceHalf = newTweenInfo(0.2),
	onceHalf = newTweenInfo(0.3),
	half = newTweenInfo(0.5),
	halfBack = newTweenInfo(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = newTweenInfo(0.75),
	threeHalfOne = newTweenInfo(0.9),
	one = newTweenInfo(1),
	oneHalf = newTweenInfo(1.5),
	two = newTweenInfo(2),
    three = newTweenInfo(3),
    four = newTweenInfo(4),
	six = newTweenInfo(6),
    fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}

AssetBook.TierColor = {
	fromRGB(0, 255, 0),
	fromRGB(49, 226, 236),
	fromRGB(214, 96, 253),
	fromRGB(250, 250, 65),
	fromRGB(255, 22, 57),
}

AssetBook.QuestColor = {
    Main = fromRGB(46, 213, 115),
    Side = fromRGB(255, 165, 2),
    Town = fromRGB(255, 107, 129)
}

AssetBook.PromptIcons = {
    Chat = "rbxassetid://13124035950",
    Exit = "rbxassetid://16458254833",
    Buy = "rbxassetid://16458319981",
    Craft = "rbxassetid://16458320089",
    Quest = "rbxassetid://16468992982",
    Travel = "rbxassetid://16458254833"
}

AssetBook.WorldInfo = {
	-- Mainworld = 12343565896, PrivateTest = 12003361010, NiximCavern = 12294239008,
	-- CE = 17302653565, TimeDomain = 11904003271, Everfrost = 12373196969,
	-- Stronghold = 12373229403, Arkus = 13970315225, LoneTown = 16555333700,
	-- SummerIsland = 17444533020

	Mainworld = 12343565896
}

AssetBook.ProductsInfo = {
	--1896117907, 1896118455, 1896276859, 1896119027, 1896119593
}
AssetBook.GamepassInfo = {
	--881563847, 881445935
	[117986452] = 10,
	[131953524] = 25,
	[131951086] = 50,
	[131952838] = 75,
	[131952197] = 100
}

return AssetBook
