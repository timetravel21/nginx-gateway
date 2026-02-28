local getconfig = require "mylua.getconfig"
local cjson = require "cjson"
local util=require "mylua.util"

local path=ngx.var.uri

local redis = require "mylua.myredis"
local kafka=require "mylua.kafka"

local jwttoken=require "mylua.jwttoken"
--ngx.say("topath3=")


--开始时间
local fromtime=ngx.now()
ngx.ctx.fromtime=fromtime

--ngx.sleep(3)



local pathpara=getconfig.getbypath(path)





if(pathpara==nill)
then 
  return
end

if(type(pathpara)=="string")
then 

   ngx.say(pathpara)
   return
end


--ngx.log(ngx.NOTICE,"before judgetoken")	
   jwttoken.judgetoken(pathpara)

--local topath=string.gsub(path,"^"..pathpara.path,pathpara.topath)
  local topath=util.replace(path,pathpara.path,pathpara.topath)
  ngx.var.topath=topath

--ngx.log(ngx.NOTICE,"frompath=",path)		
--ngx.log(ngx.NOTICE,"topath=",topath)		
	
	ngx.update_time()    
	local ltime=ngx.now()-fromtime	
	ngx.log(ngx.NOTICE,"getbypath=",ltime)	
	




--ngx.say(pathpara["topath"])

--ngx.ctx.topath=pathpara["topath"]


--ngx.ctx.topath="testtopath"
--ngx.var.topath=ngx.ctx.topath

--ngx.var.topath="http://127.0.0.1:8402/testweb"
--ngx.req.set_uri("http://127.0.0.1:8402/testweb",true)


--ngx.say(pathpara)
--ngx.say(cjson.encode(pathpara))
--ngx.say(pathpara["topath"])

--[[if(1==1)
then
   return
end--]]
