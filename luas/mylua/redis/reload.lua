local getconfig = require "mylua.getconfig"
local cjson = require "cjson"

local util=require "mylua.util"

--local path=ngx.var.uri

--ngx.say("topath3=")




getconfig.reload()


ngx.say("loaded")


local path="/factory-people/test"
local pattern="/factory-people/test"
local topath="http://127.0.0.1:8100/testweb";
local topath1=util.replace(path,pattern,topath)

--ngx.say(" uri="..ngx.var.uri)
ngx.say(" topath="..topath1)



--ngx.say(pathpara)
--ngx.say(cjson.encode(pathpara))
--ngx.say(pathpara["topath"])

--[[if(1==1)
then
   return
end--]]
