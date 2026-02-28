--平台公共的配置文件常量
local config = require "mylua.redis.config_constant"
--redis连接池工厂
local redis_factory = require('mylua.redis.redis_factory')(config.redisConfig) -- import config when construct



_M={}






--[[local function close_redis(red) 
    if not red then 
        return;
    end;
 
 
    local pool_max_idle_time = 10000; --毫秒 
    local pool_size = 100; --连接池大小 
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size);
    if not ok then 
        ngx.say("set keepalive error : ", err);
    end;
end;--]]

function _M.getconnection()
   local ok, redis_a = redis_factory:spawn('redis_a')
   return redis_a
end


function _M.get(key)

	--获取redis的连接实例
	local ok, redis_a = redis_factory:spawn('redis_a')

	-- 调用redis的get方法，获取redis中存储的key的值
	local va = redis_a:get(key)

	return va
	 

end

function _M.set(key,val)

	--获取redis的连接实例
	local ok, redis_a = redis_factory:spawn('redis_a')

	-- 调用redis的get方法，获取redis中存储的key的值
	redis_a:set(key,val)
	 

end


return _M