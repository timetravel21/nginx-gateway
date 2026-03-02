# Nginx Gateway 高并发API网关
中文 | [English](./README.md)

当前最新版本：0.1.0（发布日期：2026-03-01）

[![AUR](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/jeecgboot/JeecgBoot/blob/master/LICENSE)
[![](https://img.shields.io/badge/Author-FangJing-orange.svg)](https://jeecg.com)
[![](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jeecgboot/JeecgBoot)

## 项目介绍
基于 Nginx（OpenResty）开发的高并发 API 网关，旨在替代 Spring Gateway 以满足微服务场景下的高并发网关需求。
核心特性：
- 认证机制：基于角色的 JWT Token 认证
- 开发语言：嵌入 Nginx 的 Lua 脚本
- 配置管理：路由参数存储于 MySQL，通过高效缓存技术在 Nginx 加载/刷新时同步配置
- 核心用途：
  1. 微服务 API 网关，支持基于角色的 JWT Token 认证
  2. 将 Nginx 路由配置统一管理在 MySQL 数据表中

## 系统安装
1. 下载并安装 OpenResty（内置 Lua 环境的 Nginx 发行版）：
   下载地址：[https://openresty.org/en/](https://openresty.org/en/)
2. 将项目代码复制到 OpenResty 安装目录的 `openresty/nginx/luas` 路径下
3. 执行 SQL 脚本，创建路由配置相关数据表：
   - `sys_nginx_path`：路由规则与角色配置表
   - `sys_nginx_keys`：JWT Token 认证密钥配置表

## Nginx 初始配置
### 配置文件路径
`openresty/nginx/conf/nginx.conf`

### 核心配置项（HTTP 节点内，Server 节点前）
```nginx
proxy_buffer_size 1024k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
proxy_buffers 16 1024k; #proxy_buffers缓冲区，网页平均在32k以下的设置
proxy_busy_buffers_size 2048k; #高负荷下缓冲大小（proxy_buffers*2）
proxy_temp_file_write_size 2048k;#设定缓存文件夹大小，大于这个值，将从upstream服务器传

# 定义共享内存字典，用于缓存配置/令牌等数据（可根据业务调整大小）
lua_shared_dict clear 12k;
lua_shared_dict path 50m;
lua_shared_dict token 50m;

# 允许的最大请求体大小
client_max_body_size 100M;

# 配置 Lua 脚本加载路径
lua_package_path "/usr/local/openresty/nginx/luas/?.lua;;";
```

### 路由核心逻辑配置（Server 节点内）
```nginx
# 根路径路由处理
location / {
    set $topath '';
    # 访问阶段执行认证/路由匹配逻辑
    access_by_lua_file luas/mylua/access.lua;
    # 响应头阶段处理跨域
    header_filter_by_lua_file luas/mylua/cors.lua;

    # 处理 OPTIONS 预检请求
    if ($request_method = 'OPTIONS') {
        return 204;
    }

    # 日志收集
    log_by_lua_file luas/mylua/log.lua;

    # 代理转发配置
    proxy_pass_request_body on;
    proxy_pass $topath$is_args$args;

    # 转发请求头配置
    proxy_set_header Host $host:$server_port;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header REMOTE-HOST $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header x-forwarded-for $remote_addr;   
}

# 路由配置重载接口
location = /reload {
    default_type 'text/html';
    content_by_lua_file luas/mylua/reload.lua;
    # 可选：限制访问来源
    # allow 127.0.0.1;
    # allow 10.19.97.0/24;
    # deny all;
}
```

## MySQL 连接配置
### 配置文件路径
`openresty/nginx/luas/mylua/myconfig.lua`

### 配置示例
```lua
local _M = {}

_M.dbprop = {
    host = "数据库地址",   -- 如：127.0.0.1
    port = 端口,          -- 如：3306
    database = "数据库名", -- 如：nginx_gateway
    user = "用户名",      -- 如：root
    password = "密码"     -- 如：123456
}

return _M
```

## 路由配置
### 1. 核心数据表说明
#### （1）路由规则表 `sys_nginx_path`
| 字段名    | 说明                                                                 |
|-----------|----------------------------------------------------------------------|
| path      | 网关接收的请求路径                                                   |
| topath    | 转发的目标服务路径                                                   |
| islogin   | 认证规则：-1=无需认证；1=必须认证；0=有Token则认证，无则不认证        |
| matchtype | 匹配规则：1=精确匹配；其他值=前缀匹配（最长匹配优先）                |
| sortid    | 排序字段（暂未使用）                                                 |
| roles     | 允许访问的角色（逗号分隔，为空时不校验角色）                         |
| areacode  | 区域编码（暂未使用）                                                 |
| keyname   | 认证用的密钥名称（关联 `sys_nginx_keys` 表的 `keyname`）             |
| keytype   | 密钥类型（填 1/0 或不填）                                            |
| format    | 错误返回格式：空/1={"code":-1,"errtext":"错误内容","message":数据}；0={"code":-1,"message":"错误内容","data":数据} |

#### （2）密钥配置表 `sys_nginx_keys`
| 字段名   | 说明               |
|----------|--------------------|
| keyname  | 密钥名称（唯一）   |
| secret   | JWT 认证的密钥内容 |

### 2. 配置示例
#### （1）直接映射（无需认证）
| 字段      | 值                          | 说明                     |
|-----------|-----------------------------|--------------------------|
| path      | /abc/test                   | 网关请求路径             |
| topath    | http://127.0.0.1:8001/test  | 转发到目标服务路径       |
| matchtype | 1                           | 精确匹配                 |
| islogin   | -1                          | 无需认证                 |

#### （2）前缀映射（无需认证）
| 字段      | 值                          | 说明                     |
|-----------|-----------------------------|--------------------------|
| path      | /api/                       | 网关请求前缀             |
| topath    | http://127.0.0.1:8002/      | 转发到目标服务前缀       |
| islogin   | -1                          | 无需认证                 |

#### （3）前缀映射（必须认证）
| 字段      | 值                          | 说明                     |
|-----------|-----------------------------|--------------------------|
| path      | /apiauth/                   | 网关请求前缀             |
| topath    | http://127.0.0.1:8003/      | 转发到目标服务前缀       |
| islogin   | 1                           | 必须认证                 |
| keyname   | tokenauth                   | 关联密钥表的密钥名称     |

#### （4）前缀映射（认证+角色校验）
| 字段      | 值                          | 说明                     |
|-----------|-----------------------------|--------------------------|
| path      | /apiauth/auth/              | 网关请求前缀             |
| topath    | http://127.0.0.1:8003/auth/ | 转发到目标服务前缀       |
| islogin   | 1                           | 必须认证                 |
| roles     | 角色1,角色2                 | 仅允许指定角色访问       |
| keyname   | tokenauth                   | 关联密钥表的密钥名称     |

#### （5）前缀映射（有Token则认证）
| 字段      | 值                          | 说明                     |
|-----------|-----------------------------|--------------------------|
| path      | /apiauth/authpass/          | 网关请求前缀             |
| topath    | http://127.0.0.1:8003/authpass/ | 转发到目标服务前缀   |
| islogin   | 0                           | 有Token则认证，无则不认证 |
| keyname   | tokenauth                   | 关联密钥表的密钥名称     |

#### （6）topath指向nginx的upstream
topath: http://backend/  表示转发路由为nginx中定义的名称为backend的upstream

### 3. 路由更新
地址（get） http://nginx地址/reload
当数据库修改后，路由并不会立即生效，需运行以上地址，路由才能生效


### 4. 自定义格式调整说明
 角色分隔符修改：编辑 `luas/mylua/util.lua` 的 `_M.judgeroles
- 如果想改成以别的符号分隔，请修改 luas/mylua/util.lua 的_M.judgeroles 函数
 
		local tusr=splitdou(userrole,",");
		local task=splitdou(askrole,",")
- 如果你的jwttoken不是以roles命名，请修改	luas/mylua/jwttoken.lua	的_M.judgetoken 函数
 
    util.judgeroles(format,roles,pathpara["roles"])	
