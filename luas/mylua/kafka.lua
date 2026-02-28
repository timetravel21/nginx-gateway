local _M = {}


-- 引入lua所有api
            local cjson = require "cjson"
            local producer = require "resty.kafka.producer"
            -- 定义kafka broker地址，ip需要和kafka的host.name配置一致
            local broker_list = {
                { host = "1.1.7.5", port = 1999 },
            }


function _M.send(log_json)
	
         local message ="";
		
		if(type(log_json)=="string")
		then
		   message=log_json
	    else
		   message=cjson.encode(log_json)
	    end
	
      -- 转换json为字符串
            local message = cjson.encode(log_json);
            -- 定义kafka异步生产者
            local bp = producer:new(broker_list, { producer_type = "async" })
            -- 发送日志消息,send第二个参数key,用于kafka路由控制:
            -- key为nill(空)时，一段时间向同一partition写入数据
            -- 指定key，按照key的hash写入到对应的partition
            local ok, err = bp:send("test1", nil, message)  
            if not ok then
                ngx.log(ngx.ERR, "kafka send err:", err)
                return
            end	
	
	
end


return _M

      