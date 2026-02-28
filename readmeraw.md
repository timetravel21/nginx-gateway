中文 | [English](./README.en-US.md)

Nginx Gateway 高并发api网关
===============

当前最新版本： 0.1.0（发布日期：2026-03-01） 


[![AUR](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/jeecgboot/JeecgBoot/blob/master/LICENSE)
[![](https://img.shields.io/badge/Author-FangJing-orange.svg)](https://jeecg.com)
[![](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jeecgboot/JeecgBoot)



项目介绍
-----------------------------------

<h3 align="center">Nginx Gateway 高并发api网关</h3>

基于Nginx,提供高并发api网关，api认证采用基于角色的jwttoken。开发初衷是用于替换spring gateway,以实现高并发的微服务网关。

采用Lua脚本语言，嵌入Nginx(openresty),路由参数配置在mysql中，采用高效缓存技术，在nginx加载或刷新时加载配置。 


项目可用于：
1、api微服务网关，基于角色的jwttoken认证
2、将nginx的路由配置设置在mysql的表里



系统安装
-----------------------------------
1、下载并安装openresty，下载地址：https://openresty.org/en/ (openresty将lua语言嵌入到nginx核心),
2、将项目代码复制到openresty/nginx/luas目录
3、执行sql脚本，创建路由配置表。其中sys_nginx_path用于配置路由及角色，sys_nginx_keys用于配置认证jwttoken的密钥


nginx初始配置（可参照样例nginx.conf）
-----------------------------------
1、nginx.conf文件地址：openresty/nginx/conf/nginx.conf
2、载入lua配置（在http小节内，server的前面），缓存参数可调整

proxy_buffer_size 1024k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
proxy_buffers 16 1024k; #proxy_buffers缓冲区，网页平均在32k以下的设置
proxy_busy_buffers_size 2048k; #高负荷下缓冲大小（proxy_buffers*2）
proxy_temp_file_write_size 2048k;#设定缓存文件夹大小，大于这个值，将从upstream服务器传


lua_shared_dict clear 12k;
lua_shared_dict path 50m;
lua_shared_dict token 50m;

client_max_body_size 100M;
lua_package_path "/usr/local/openresty/nginx/luas/?.lua;;";

3、根路径配置
    location / {
 
        #default_type 'text/html';
        set $topath '';
        access_by_lua_file luas/mylua/access.lua;
        header_filter_by_lua_file luas/mylua/cors.lua;

        if ($request_method = 'OPTIONS') {

            return 204;

        }

	    #set_by_lua_file $topath /lua/setvar.lua;
	    
	    #content_by_lua_file conf/lua/test.lua;
	    #content_by_lua "ngx.say('hello world2')";

        log_by_lua_file luas/mylua/log.lua;

        proxy_pass_request_body on;
        proxy_pass $topath$is_args$args;

        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header x-forwarded-for $remote_addr;   
     }
  

  location =/reload
  {

       default_type 'text/html';
       content_by_lua_file luas/mylua/reload.lua;
       #allow 127.0.0.1;
	   #allow 10.19.97.0/24;
	   #deny all;
       #echo "args: args";
  }




mysql连接配置
-----------------------------------
找到文件： openresty/nginx/luas/mylua/myconfig.lua，修改数据库连接参数

local _M = {}

_M.dbprop = {
        host = "数据库地址",
        port = 端口,
        database = "数据库名",
        user = "用户名",
        password = "密码"
}


return _M


路由配置
-----------------------------------
1、路由配置表 sys_nginx_path
path: 路径
topath: 替换路径
islogin:  -1表示不用认证  1表示必须要认证 0表示有token要认证，无token不认证 
matchtype: 1:对path进行精确匹配  否则以path为前缀的都算匹配
sortid:  排序，本参数无用
roles: 逗号分割的角色，为空时判断
areacode:  本参数无用
keyname: 验证时的密钥名，在sys_nginx_keys中设置其对应的密钥
keytype: 请填1或0或不填
format: 出错时返回的格式
   为空或1时 返回 {"code":-1,"errtext":"错误内容","message":数据}
   为0时 返回 {"code":-1,"message":"错误内容","data":数据}


2、密钥表 sys_nginx_keys
keyname: 密钥名称
secret: 密钥内容


3、配置示例
3.1 直接映射
path: /abc/test
topath: http://127.0.0.1:8001/test
matchtype: 1
islogin: -1
note: 将/abc/test映射到topath
3.2 前缀映射(匹配规则为最长匹配)
path: /api/
topath: http://127.0.0.1:8002/
islogin: -1
note: 将以/api开始的路径隐射到topath
3.3 前缀映射必须通过认证
path: /apiauth/
topath: http://127.0.0.1:8003/
islogin: 1
keyname: tokenauth
note: 需要在header的token中带jwttoken,且该token必须通过验证，token的密钥存在sys_nginx_keys表中，名称为tokenauth
3.4 前缀映射必须角色符合
path: /apiauth/auth/
topath: http://127.0.0.1:8003/auth/
islogin: 1
roles: 角色1,角色2
keyname: tokenauth
note: 需要在header的token中带jwttoken,且该token中含有以逗号分隔的roles字段，该字段值有角色1或角色2
如果想改成以别的符号分隔，请修改 luas/mylua/util.lua 的_M.judgeroles 函数
		local tusr=splitdou(userrole,",");
		local task=splitdou(askrole,",")
如果你的jwttoken不是以roles命名，请修改	luas/mylua/jwttoken.lua	的_M.judgetoken 函数
    util.judgeroles(format,roles,pathpara["roles"])	
3.5 前缀映射 传token时认证
path: /apiauth/authpass/
topath: http://127.0.0.1:8003/authpass/
islogin: 0
keyname: tokenauth
note: 当在header的token中带jwttoken时，启动网关认证


4、路由更新
地址 http://nginx地址/reload
当数据库修改后，路由并不会立即生效，需运行以上地址，路由才能生效
