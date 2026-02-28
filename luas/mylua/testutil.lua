

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
	   token=ngx.req.get_uri_args["_token"]
	end

	if(token==nil)
	then
	   token=cookie.get["JSESSIONID2"]
	end

   return token

end


function _M.setheader(rights)
    ngx.req.set_header("rights",rights)

end

function _M.senderror(format,errtext)
    ngx.req.set_header("rights","")
	
		--ngx.status = ngx.HTTP_UNAUTHORIZED
		ngx.header["Content-type"] = 'application/json'
		retdata=_M.toerror(format,errtext)
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
		    _M.senderror(format,"无权限")
			return
	    end
		
		--askrole=","..askrole..","
		local tusr=splitdou(userrole);
		
		local task=splitdou(askrole)
		
		for k,v in pairs(tusr) do
		    if(task[v]!=nil)
			then
			   return
		    end
		
	    end
	
		_m.senderror(format,"无相应的角色")
	    
end



function splitdou(str)
	
	

    local resultStrList = {}
	local reps = ","
	--  [^,]+ 正则表达式 匹配,

    string.gsub(starNum,'[^'..reps..']+',function ( w )
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