local tn = script.Parent.Parent;

script.Parent.Died:connect(function()
wait(10)
tn:remove()
end)