local jwt = require "resty.jwt"
local cjson = require "cjson"

local util=require "mylua.util"
 
--local secret = "token secret key"

local cookie = resty_cookie:new() 
 
local lrucache=require "resty.lrucache"
local cache,err=lrucache.new(10000)




function judgetoken(pathpara)
 

   local islogin=pathpara["islogin"];
   local format=pathpara["format"];
   
   if(islogin==nil)
   then
      islogin=0
	end
  

   local token=util.gettoken()

   if(islogin==0 and token==nil)
   then
        util.setrights("")
		return
   end


   local secret=pathpara["secret"]


--ngx.log(ngx.INFO, "auth_header = ",auth_header)
	if token == nil then
		util.senderror(format,"没有登录串")
		return
	end
 
    local jwt_obj=cache:get(token)

    if(jwt_obj==nil)
	then
	   jwt_obj = jwt:verify(secret, token)
    end
	
     if jwt_obj.verified == false and islogin==0 then	
        util.setrights("")
		return
	
     end
	
	
	if jwt_obj.verified == false then
		util.senderror(format,"无效的登录串")
		return
	end
	
	cache:set(token,jwt_obj,3600)
	
	
	
    local roles=jwt_obj.role

    util.judgeroles(format,roles,pathpara["roles"])	
	
	
	
	local rights=cjson.encode(jwt_obj)
	util.setrights(rights)


end




function verify(secret,token,isrsa)
	if(isrsa==nil or isrsa<=0)
	then
	   return jwt:verify(secret, token)
	end
	
	local jwt_obj = jwt:load_jwt(token)
    local verified = jwt:verify_jwt_obj(secret, jwt_obj)
	
	return verified
	
	
end

