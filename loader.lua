-- Project Delta Key System v2.0
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HTTP = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- Конфигурация
local CONFIG = {
    GitHubURL = "https://raw.githubusercontent.com/pelmeshek/CheatKeys/main/keys.json",
    EncryptionKey = "A1B2C3D4E5F6G7H8",
    MaxAttempts = 3
}

-- Системные переменные
local KeyValid = false
local AttemptsLeft = CONFIG.MaxAttempts

-- Получение HWID
local function GetHWID()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

-- Шифрование данных
local function Encrypt(data)
    return game:GetService("CryptService"):Hash(data..CONFIG.EncryptionKey)
end

-- Проверка ключа
local function ValidateKey(inputKey)
    local success, keysData = pcall(function()
        return HTTP:JSONDecode(game:HttpGet(CONFIG.GitHubURL))
    end)
    
    if not success then return false end
    
    local hashedInput = Encrypt(inputKey)
    
    for storedKey, keyInfo in pairs(keysData.valid_keys) do
        if Encrypt(storedKey) == hashedInput then
            if keyInfo.hwid_lock and GetHWID() ~= Encrypt(LP.Name) then
                return false, "HWID mismatch"
            end
            if os.time() > os.time(keyInfo.expiry) then
                return false, "Key expired"
            end
            return true
        end
    end
    return false
end

-- GUI для ввода ключа
local function CreateKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeyAuthSystem"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.Parent = ScreenGui

    local InputBox = Instance.new("TextBox")
    InputBox.PlaceholderText = "Введите ключ доступа"
    InputBox.Size = UDim2.new(0.9, 0, 0, 40)
    InputBox.Position = UDim2.new(0.05, 0, 0.2, 0)
    InputBox.Parent = MainFrame

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Text = "Активировать ("..AttemptsLeft.." попыток)"
    SubmitBtn.Size = UDim2.new(0.9, 0, 0, 40)
    SubmitBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
    SubmitBtn.Parent = MainFrame

    SubmitBtn.MouseButton1Click:Connect(function()
        if AttemptsLeft <= 0 then
            game:Shutdown()
            return
        end
        
        local valid, reason = ValidateKey(InputBox.Text)
        if valid then
            KeyValid = true
            ScreenGui:Destroy()
            -- Запуск основных функций
            loadstring(game:HttpGet("https://github.com/pelmeshek2323/PROJECT-DELTA-SAMBO-WOW/blob/main/swift.lua""))()
        else
            AttemptsLeft = AttemptsLeft - 1
            SubmitBtn.Text = "Неверный ключ! Осталось: "..AttemptsLeft
            if AttemptsLeft <= 0 then
                wait(2)
                game:Shutdown()
            end
        end
    end)
end

-- Запуск системы
if not KeyValid then
    CreateKeyUI()
    repeat wait() until KeyValid
end
