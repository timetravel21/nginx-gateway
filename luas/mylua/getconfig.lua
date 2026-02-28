local _M = {}

--local pathlist={}
--local suffixlist={}
_M.pathdict={}
_M.hasvalue=0
_M.beginloadtime=0


_M.loadtime=0

--local values={hasdict=0}

--指定文本输出的文件类型为json类型
--ngx.header.content_type="application/json;charset=utf-8"
--引入库文件json


--local lrucache=require "resty.lrucache"
--local cache,err=lrucache.new(10000)

local cjson = require "cjson"

--引入依赖库mysql
local mysql = require "resty.mysql"

--local jwt=require ".config.lua.jwttoken"
local util=require "mylua.util"

local myconfig=require "mylua.myconfig"

local mycache=require "mylua.mycache"

--local jwttoken=require "mylua.jwttoken"




--配置数据库连接信息
local props = myconfig.dbprop

local pathempty = {topath=""}



function getdb()
     
ngx.update_time()
local fromtime=ngx.now()
 _M.beginloadtime=fromtime
--hasvalue=1
 

ngx.log(ngx.ERR,"begin getdb")

--创建连接、设置超时时间、编码格式
local db,err = mysql:new()


 
db:set_timeout(10000)
db:connect(props)
db:query("SET NAMES utf8")
 
--SQL语句 (读取参数中id的值)
--local id = ngx.req.get_uri_args()["id"]
local sql = "select * from sys_nginx_path p left join sys_nginx_keys k  on p.keyname=k.keyname  order by sortid"
 
--ngx.log(ngx.INFO,"getdb","")
 
--执行SQL语句
local res, err, errno, sqlstate = db:query(sql)
 
--关闭连接
db:close()

if(err~=nil)
then  
   ngx.log(ngx.ERR,"getdberr=",err)
   _M.beginloadtime=0
   util.senderror(format,"nginx加载配置失败"..err)
end


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
		--cache:set(curpath,1,36000000)
	

end

    --pathlist=res;
	_M.pathdict=pdict
	res=nil
	pdict=nil
	_M.hasvalue=1

ngx.update_time()
local ltime=ngx.now()-fromtime

_M.loadtime=ngx.now()

ngx.log(ngx.ERR,"after getdb time=",ltime)	
	
	--suffixlist=slist
	
   --cache:set("dbload",1,36000000)	
	
	--values["hasdict"]=1
	
	--pdict=nil
	--slist=nil
	
	
	--return cjson.encode(suffixlist)


end


function _M.reload()
    getdb()
	--cache:flush_all()
end





function _M.getbypath_old(path)
	


    if(table.getn(pathlist)==0)
	then
	   getdb()
	end
	
--[[	local pathpara=pathdict[path]
	
	if (pathpara~=nil)
	then
	   return pathpara
	end
--]]	
	local mylist=pathlist




	for key, value in ipairs(mylist) do
		
--[[	if(1==1)
		then
		   return cjson.encode(value)
	    end
--]]

       local dbpath=value["path"]
		
	

        if string.find(path,dbpath) == 1 
        then
			return value["topath"]
		end
 	
		
	end
	
	return nil
end


function _M.getbypath(path)

    --ngx.update_time()
    --local fromtime=ngx.now()
    local pathpara= getbypathfun(path)
	
--ngx.log(ngx.NOTICE,"before judgetoken")	
    --jwttoken.judgetoken(pathpara)
--ngx.log(ngx.NOTICE,"after judgetoken")		
	
	--ngx.update_time()    
	--local ltime=ngx.now()-fromtime	
	
    --ngx.log(ngx.NOTICE,"getbypath=",ltime)	
	
    return   pathpara
end 


--[[function isloaded()
	
	local a,stale=cache:get("dbload")
	if(a==nil)
	then
	   return false
	end
	
	if(a~=1)
	then
	   return false
	end
	
end--]]


function shouldload()
	
	 --local ngcache=ngx.shared.cache
     local asktime=mycache.getvalue(mycache.cacheclear,"cleartime")
	
	--ngx.log(ngx.NOTICE,"asktime=",asktime)
	
	  if(asktime==nil)
	  then 
         asktime=0
	  end
	
	
	  if(_M.loadtime<=asktime) --有新的请求
	  then
	     return 1
	  end
	

    if(_M.hasvalue>0)  --已经有数据
	then
	   return 0
	end
	
	
	 --local curtime=os.time(date)
	 local curtime=ngx.now()  --毫秒级
	local lminus=curtime-_M.beginloadtime
	
	
	if(lminus>=1 or lminus<0) --1秒钟内无数据加载
	then
	   return 1
	end
	
	return 0   --1秒钟内有数据加载
	
end


function getbypathfun(path)
	
	local paracache=mycache.get(mycache.cachepath,path)
	
    if(paracache~=nil)
	then
	   ngx.log(ngx.NOTICE,"paracache=true")
       return paracache
	end	
	--local paracache=cache:get(path)
	
	local toload=shouldload()
	
	--ngx.log(ngx.NOTICE,"toload=",toload)
	
    if(toload>=100)
    then
       return nil
    end	
	

    if(toload>0)  --触发加载数据
	then
	   getdb()
       --return "novalue1"
	end
	
    if(_M.pathdict==nil)
	then
	
	    util.senderror(format,"nginx还未加载"..err)
        return nil
	end

  

    local spath=path
	
	
    local orginpath=true
	
    while (string.len(spath)>0)
	do
	   local para=_M.pathdict[spath]
	   
	   local ismatch=false

       if(para~=nil and orginpath==true)  --精确匹配 
	   then
	       ismatch=true
		   --ngx.log(ngx.ERR,"originmatch=",spath)
	   end
	   

       if(para~=nil and orginpath==false) --非精确匹配 
			then
				local matchtype=para["matchtype"]
				if(matchtype==ngx.null)  --若为null改0 非精确匹配
				then
					matchtype=0
				end
			
                if(matchtype==0)   --非精确
                then
				   --ngx.log(ngx.ERR,"not originmatch=",spath)
                    ismatch=true
				end
			end
                   			
			
			
        if(ismatch==true)
		then
            --cache:set(path,para,3600000)
			--mycache.set(mycache.cachepath,path,para,3600)
            return para
		end 
		
		
		spath=trimlast(spath)
		orginpath=false
		
		--ngx.log(ngx.ERR,"originpath=false=",orginpath)
		
	end

	--cache:set(path,pathempty,3600)
	mycache.set(mycache.cachepath,path,pathempty,600)
	
	ngx.log(ngx.ERR,"path null=",path)
    util.senderror(format,"nginx invalid path")	
	
    return nil
		
end




function trimlast(str)
	local ilen=string.len(str)
	if(ilen==0)
	then 
	  return ""
    end
	
    str=string.sub(str,1,ilen-1)

    return str	
	
	
end
	



return _M


--jret=cjson.encode(res)
--tableall=cjson.decode(jret)


--响应数据->json
-- ngx.say(tableall)

--ngx.say(res)