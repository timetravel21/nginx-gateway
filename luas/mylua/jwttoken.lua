local _M = {}

local secretpeople="enb_application"

local jwt = require "resty.jwt"
local cjson = require "cjson"

local util=require "mylua.util"

local resty_cookie = require "resty.cookie"

local mycache=require "mylua.mycache"
 
--local secret = "token secret key"

local cookie = resty_cookie:new() 
 
--local lrucache=require "resty.lrucache"
--local cache,err=lrucache.new(10000)




function _M.judgetoken(pathpara)
 
--ngx.log(ngx.NOTICE,"enter judgetoken")	


   local islogin=pathpara["islogin"];
   local format=pathpara["format"];
   
   if(islogin==nil)
   then
      islogin=0
	end
  

--不用处理登录
    if(islogin<0)
	then
	    return
    end


   local token=util.gettoken()

   if(islogin==0 and token==nil)
   then
        util.setrights("")
		return
   end


   local secret=pathpara["secret"]
   local keyname=pathpara["keyname"]

   if(keyname~=nil and keyname=="people")
   then
        secret=secretpeople
   end

--ngx.log(ngx.NOTICE,"after gettoken")	

--ngx.log(ngx.INFO, "auth_header = ",auth_header)
	if token == nil then
		util.senderror(format,"nginx没有登录串")
		return
	end
 

--ngx.log(ngx.NOTICE,"token is not null")	

    --local payload=cache:get(token)
	local payload=mycache.get(mycache.cachetoken,token)
	
	

    if(payload~=nil)
    then
       ngx.log(ngx.ERR,"payloadcache=true")
	   --payload.test="abc"
	
	   --payload=cache:get(token)
	   --ngx.log(ngx.ERR,"payloadcache2=",cjson.encode(payload))

    end		
	

--ngx.log(ngx.ERR,"pathpara=",cjson.encode(pathpara))

    if(payload==nil)
	then
	   payload = verify(secret, token,pathpara["keytype"])
    end
	
     if payload == nil and islogin==0 then	
        util.setrights("")
		return
	
     end
	
	
	if payload==nil 
    then
		util.senderror(format,"nginx无效的登录串")
		return
	end
	
	
	
	--cache:set(token,payload,3600)
	mycache.set(mycache.cachetoken,token,payload,600)
	
--[[	local payload2=mycache.get(mycache.cachetoken,token)
	
    if(payload2==nil)
    then
         util.senderror(format,token)
    end	
--]]	
	
	
	--ngx.log(ngx.NOTICE,cjson.encode(payload))
	
    local roles=payload.role

--ngx.log(ngx.NOTICE,cjson.encode(payload.role))

    util.judgeroles(format,roles,pathpara["roles"])	
	
	
	
	local rights=cjson.encode(payload)
	util.setrights(rights)


end




function verify(secret,token,keytype)
	

    local jret={}
    if(type(keytype)=="userdata")
    then
       keytype=1
	end	

   ngx.log(ngx.ERR,"keytype=",keytype)    	
	
    if(keytype<=1)
	then
	   jret=jwt:verify(secret, token)
	
	else
		local jwt_obj = jwt:load_jwt(token)
		jret = jwt:verify_jwt_obj(secret, jwt_obj)
    end	
	
	if(jret.verified==false)
	then
	   return nil
	end
	
	return jret.payload
	
end

return _M