local balancer = require "ngx.balancer"


ngx.log(ngx.NOTICE,"balance time=",ngx.ctx.fromtime)

local ok, err = balancer.set_current_peer("10.1.1.1", 8402)