
local _M = {}

local pathdict={}
local suffixlist={}


--指定文本输出的文件类型为json类型
--ngx.header.content_type="application/json;charset=utf-8"
--引入库文件json
local cjson = require "cjson"
--引入依赖库mysql
local mysql = require "resty.mysql"
 
--配置数据库连接信息
local props = {
        host = "10.1.1.1",
        port = 3306,
        database = "",
        user = "",
        password = ""
}



return _M


--jret=cjson.encode(res)
--tableall=cjson.decode(jret)


--响应数据->json
-- ngx.say(tableall)

--ngx.say(res)