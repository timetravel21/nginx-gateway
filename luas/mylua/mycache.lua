local _M = {}

local cjson = require "cjson"
local lrucache=require "resty.lrucache"


_M.cacheclear=ngx.shared.clear
_M.cachepath=ngx.shared.path
_M.cachetoken=ngx.shared.token

local turn2table=true

--local cachepath,err=lrucache.new(10000)
--local cachetoken,errt=lrucache.new(10000)


function _M.set(cache,key,value)

    if(turn2table==true)
	then
	   value=cjson.encode(value)
	end

    cache:set(key,value)
end


function _M.set(cache,key,value,exptime)

    if(turn2table==true)
	then
	   value=cjson.encode(value)
	end


	return cache:set(key,value,exptime)
end




function _M.get(cache,key)
	local value=cache:get(key)
	
    if(value==nil)
    then
       return value
    end
    value=cjson.decode(value)

    return value	
	
end


function _M.setvalue(cache,key,value)

    cache:set(key,value)
	--_M.cacheclear:set(key,value)
end




function _M.getvalue(cache,key)
	local value=cache:get(key)
	
	--value=_M.cacheclear:get(key)
	

    return value	
	
end


function _M.clearall(cache)
	cache:flush_all()
end


return _M