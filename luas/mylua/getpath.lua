--local getconfig = require ".config.lua.getconfig"
--local ngx = require "ngx"

ngx.header.content_type="application/json;charset=utf-8"

local path=ngx.var.uri

--ngx.args[1]="https://baidu.com"
--ngx.var.target="https://baidu.com"

--ngx.say(ngx.var.uri)

local topath=getconfig.getbypath(path)


return topath