

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



function toresult_fj(pcode,perr,pmessage)

    local retdata = {
    code=pcode,
    errtext=perr,
	message=pmessage
    
    }
	
	
	return cjson.encode(retdata)


end




function toresult_magic(pcode,perr,pmessage)

    if(perr==nil)
	then 
	   perr="null"
	end
	
    if(perr=="")
	then 
	   perr="success"
	end
	


    local retdata = {
    code=pcode,
    message=perr,
	data=pmessage
    
    }
	
	return cjson.encode(retdata)


end