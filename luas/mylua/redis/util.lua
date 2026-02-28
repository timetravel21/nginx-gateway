
local _M = {}
local cjson = require "cjson"


function _M.toerror(format,perr)
    return _M.toresult(format,-1,perr,nil)

end


function _M.toresult(format,pcode,perr,pmessage)

    if(format==nil)
	then
	   format=1
	end
	
	if(format==1)
	then
	   return toresult_fj(pcode,perr,pmessage)
	end
	
	
     return toresult_magic(pcode,perr,pmessage)
	   

end

function _M.gettoken()
    local token = ngx.req.get_headers()["token"]

	if(token==nil)
	then
	   token=ngx.req.get_uri_args()["_token"]
	end

	if(token==nil)
	then
	   --token=cookie.get["JSESSIONID2"]
	   token=ngx.var["JSESSIONID2"]
	end

   return token

end


function _M.setheader(rights)
  --ngx.req.set_header("Accept-encoding", "");  
  ngx.req.set_header("rights",ngx.encode_base64(rights))

end


function _M.setrights(rights)
   --ngx.req.set_header("Accept-encoding", ""); 
   ngx.req.set_header("rights",ngx.encode_base64(rights))

end




function _M.senderror(format,errtext)
    ngx.req.set_header("rights","")
	
		--ngx.status = ngx.HTTP_UNAUTHORIZED
		ngx.header["Content-type"] = 'application/json;charset=utf8'
		local retdata=_M.toerror(format,errtext)
		
		
		ngx.log(ngx.NOTICE,"errtext=",errtext)	
		--retdata=_M.toerror(format,"aaa测试")

        ngx.say(retdata)
		return ngx.exit(0)	
end


function _M.judgeroles(format,userrole,askrole)
        

        if(askrole==nil or askrole=="")
		then
		   return
	    end
		
        if(userrole==nil or userrole=="")
		then
		    _M.senderror(format,"nginx无权限")
			return
	    end
		
		--askrole=","..askrole..","
		local tusr=splitdou(userrole,";");
		
		local task=splitdou(askrole,",")
		

        --ngx.log(ngx.NOTICE,"tuser=",cjson.encode(tusr))
		--ngx.log(ngx.NOTICE,"task=",cjson.encode(task))
		
		
		
		for k,v in pairs(tusr) do
		    if(task[k]~=nil)
			then
			   return
		    end
		
	    end
	
		_M.senderror(format,"nginx无相应的角色")
	    
end


local ngx_re=require "ngx.re"
function splitdou(str,fenge)
	
	
	local rlist={}

    local res,err=ngx_re.split(str,fenge)
	
	for i,v in ipairs(res) do
	    rlist[v]="1"
	end
	
	return rlist
	
end


function _M.replace(oldpath,sfrom,sto)
	
	local fromlen=string.len(sfrom)+1
	
	--ngx.log(ngx.ERR,"fromlen=",fromlen)	
	
	local str=sto..string.sub(oldpath,fromlen)
	
	return str
	
	
end




function splitdou_old(str,fenge)
	
	

    local resultStrList = {}
	--local reps = ","
	--  [^,]+ 正则表达式 匹配,

    string.gsub(str,'[^'..fenge..']+',function ( w )
        --table.insert(resultStrList,w)
		resultStrList[w]=w
    end)

	return resultStrList
	
end




function toresult_fj(pcode,perr,pmessage)

    local retdata = {
    code=pcode,
    errtext=perr,
	message=pmessage
    
    }
	
	
	return cjson.encode(retdata)


end




return _M