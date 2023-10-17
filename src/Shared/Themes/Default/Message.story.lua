local Message = require(script.Parent.Message)

return function (target: Instance)
    local MessageUI = Message {
        Title = "Message from Jimmy (@Jyrezo)",
        Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec dapibus ligula eu magna posuere suscipit. Vestibulum convallis scelerisque lectus, in elementum diam tempor vehicula. Maecenas ligula nibh, sollicitudin et efficitur ac, lacinia cursus risus.",
        Parent = target,
        CloseCallback = function()
            print("test")
        end
    }

    return function ()
        MessageUI:Destroy()
    end
end