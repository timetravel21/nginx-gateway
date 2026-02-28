
local _M = {}

--local pathlist={}
--local suffixlist={}
local pathdict={}

_M.pathdict={}
_M.hasvalue=0



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


function getdb()
     
 

 
--创建连接、设置超时时间、编码格式
local db,err = mysql:new()


 
db:set_timeout(1000)
db:connect(props)
db:query("SET NAMES utf8")
 
--SQL语句 (读取参数中id的值)
--local id = ngx.req.get_uri_args()["id"]
local sql = "select * from sys_path order by sortid"
 
--ngx.log(ngx.INFO,"sql语句为:",sql)
 
--执行SQL语句
local res, err, errno, sqlstate = db:query(sql)
 
--关闭连接
db:close()

   



local pdict={}
--local slist={}


for key, value in ipairs(res) do

local curpath=value["path"]

  
	
  
	
	    pdict[curpath]=value
	
end

    --pathlist=res;
	pathdict=pdict
	res=nil
	pdict=nil
	--suffixlist=slist
	
	--pdict=nil
	--slist=nil
	
	
	--return cjson.encode(suffixlist)


end



function getdb()
     
 
_M.hasvalue=1
 
--创建连接、设置超时时间、编码格式
local db,err = mysql:new()


 
db:set_timeout(1000)
db:connect(props)
db:query("SET NAMES utf8")
 
--SQL语句 (读取参数中id的值)
--local id = ngx.req.get_uri_args()["id"]
local sql = "select * from sys_path order by sortid"
 
--ngx.log(ngx.INFO,"sql语句为:",sql)
 
--执行SQL语句
local res, err, errno, sqlstate = db:query(sql)
 
--关闭连接
db:close()

   



local pdict={}
--local slist={}


for key, value in ipairs(res) do

local curpath=value["path"]

  
	
    --local ilen=string.len(curpath)
    --local charend=string.sub(curpath,ilen)
	
--[[	if(charend=="*") then
	    curpath=string.sub(curpath,1,ilen-1)
	
		value["path"]=curpath
		
		table.insert(slist,value)
--]]    
	
	    pdict[curpath]=value
	

end

    --pathlist=res;
	_M.pathdict=pdict
	res=nil
	pdict=nil
	_M.hasvalue=1
	--suffixlist=slist
	
	--values["hasdict"]=1
	
	--pdict=nil
	--slist=nil
	
	
	--return cjson.encode(suffixlist)


end

  



 function _M.getbypath(path)
	

    --hasvalue=true
    --local inum=table.getn(pathdict)
	
     
	
	
	
    if(_M.hasvalue<=0)
	then
	   getdb()
	   
		if(_M.hasvalue>0) then
		    return "novalue2"
		end


       return "novalue1"
	end


	if(1==1)
	then
	   return "bbb"
	end

  

    local spath=path
    while (string.len(spath)>0)
	do
	   local para=_M.pathdict[spath]
	   if(para~=nil)
	   then
	      return para
		end 
		
		
		spath=trimlast(spath)
		
	end
	
	return nil
		
end





return _M


--jret=cjson.encode(res)
--tableall=cjson.decode(jret)


--响应数据->json
-- ngx.say(tableall)

--ngx.say(res)