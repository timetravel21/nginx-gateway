--local getconfig = require "mylua.getconfig"
local cjson = require "cjson"

local util=require "mylua.util"

local mycache=require "mylua.mycache"

--local path=ngx.var.uri

--ngx.say("topath3=")




--getconfig.reload()
--ngx.say("loaded")


local path="/factory-people/test"
local pattern="/factory-people/test"
local topath="http://127.0.0.1:8100/testweb";
--local topath1=util.replace(path,pattern,topath)

--ngx.say(" uri="..ngx.var.uri)
--ngx.say(" topath="..topath1)


--local surl="http://1.1.1.1:8/testweb"

--local ipport=util.getipport("http://10.1:1/testweb")

--local sret=cjson.encode(ipport)
--local sret=type(nil)

--ngx.say(ngx.worker.id())


--[[function set(cache,key,value)
	cache:set(key,value)
end
--]]

local cleartime=ngx.now() --∫¡√Îº∂
--ngx.shared.cache:set("cleartime",cleartime)

--set(ngx.shared.cache,"cleartime",cleartime)

mycache.setvalue(mycache.cacheclear,"cleartime",cleartime)

--local asktime=mycache.getvalue(mycache.cacheclear,"cleartime")

--[[ngx.say("asktime=",asktime)


local ok,err=ngx.shared.clear:set("cleartime",cleartime)
local asktime=ngx.shared.clear:get("cleartime")

ngx.say("asktime2=",asktime)
ngx.say("err=",err)
ngx.say("ok=",ok)
--]]

ngx.sleep(0.4)

mycache.clearall(mycache.cachepath)


ngx.say("askclear="..cleartime)


--[[local token="eyJhbGciOiJIUzI1NiJ9.eyJhcmVhIjoiMDAxMDAxMDIxMDA0MDAxMDA1Iiwicm9sZSI6IumVh-ihl1_nvZHmoLzplb8iLCJhcmVhbmFtZSI6Iua1i-ivlee9keagvCIsInJvbGVpZCI6bnVsbCwibW9iaWxlIjoiMTUzMDY2NjI4MjMiLCJsb2dpbiI6Inp4MDQiLCJ0eXBlIjowLCJkZXAiOiIwMDEwMDEwMjEwMDQwMDEwMDUiLCJ0eXVzZXJpZCI6IjhhOTM0OGI0ODYwYmIzMjUwMTg2MmU5ZGI1NjAwNTFjIiwiZGluZ3VzZXIiOiI1ODAyMzg1NyIsImRpbmdwaG9uZSI6IkdFXzM2Nzk1NjRhNGE2NDQ3ODFiMjIyNmM5YzJiZDA5NzUwIiwibmFtZSI6IuadjuaZk-aYjiIsImRpbmdjb2RlIjoiR0VfMzY3OTU2NGE0YTY0NDc4MWIyMjI2YzljMmJkMDk3NTAiLCJhcmVhdHlwZSI6Iue9keagvCIsImRlcG5hbWUiOiLmtYvor5XnvZHmoLwiLCJleHAiOjE2NzkwNDkxMDJ9.pzm660CaJxcul9W0L7LUVlFnofLRidqKX4D9BTnFhPs"
--token="aaa"
local payload={a=1,b=2}
local ok,err=mycache.set(mycache.cachetoken,token,payload,3600)

local payload2=mycache.get(mycache.cachetoken,token)

if(payload2==nil)
then
   ngx.say("cache is null err=",err)
   ngx.say(" ok =",ok)
else
ngx.say("cache is fine")

end--]]



--ngx.say(pathpara)
--ngx.say(cjson.encode(pathpara))
--ngx.say(pathpara["topath"])

--[[if(1==1)
then
   return
end--]]
