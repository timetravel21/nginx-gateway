

--ngx.sleep(3)
ngx.update_time()

if(ngx.ctx.fromtime==nil)
then
   return
end


local ltime=ngx.now()-ngx.ctx.fromtime

if(ltime>=1)
then
  ngx.log(ngx.ERR,"time=",ltime)
end







