# Nginx Gateway High-Concurrency API Gateway
[中文](./README.zh.md) | English

Current latest version: 0.1.0 (Release Date: 2026-03-01)

[![AUR](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/jeecgboot/JeecgBoot/blob/master/LICENSE)
[![](https://img.shields.io/badge/Author-FangJing-orange.svg)](https://jeecg.com)
[![](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jeecgboot/JeecgBoot)

## Project Introduction
A high-concurrency API gateway developed based on Nginx (OpenResty), designed to replace Spring Gateway to meet the high-concurrency gateway requirements in microservice scenarios.
Core Features:
- Authentication Mechanism: Role-based JWT Token authentication
- Development Language: Lua scripts embedded in Nginx
- Configuration Management: Routing parameters are stored in MySQL, and configurations are synchronized when Nginx loads/refreshes through efficient caching technology
- Core Purposes:
  1. Microservice API gateway, supporting role-based JWT Token authentication
  2. Unified management of Nginx routing configurations in MySQL data tables

## System Installation
1. Download and install OpenResty (an Nginx distribution with a built-in Lua environment):
   Download URL: [https://openresty.org/en/](https://openresty.org/en/)
2. Copy the project code to the `openresty/nginx/luas` path of the OpenResty installation directory
3. Execute the SQL script to create data tables related to routing configuration:
   - `sys_nginx_path`: Routing rule and role configuration table
   - `sys_nginx_keys`: JWT Token authentication key configuration table

## Nginx Initial Configuration
### Configuration File Path
`openresty/nginx/conf/nginx.conf`

### Core Configuration Items (inside the HTTP block, before the Server block)
```nginx
proxy_buffer_size 1024k; # Set the buffer size for the proxy server (nginx) to store user header information
proxy_buffers 16 1024k; # Proxy_buffers buffer, set for web pages with an average size below 32k
proxy_busy_buffers_size 2048k; # Buffer size under high load (proxy_buffers*2)
proxy_temp_file_write_size 2048k; # Set the size of the cache folder; if exceeded, data will be transferred from the upstream server

# Define shared memory dictionaries for caching configurations/tokens and other data (adjust size according to business needs)
lua_shared_dict clear 12k;
lua_shared_dict path 50m;
lua_shared_dict token 50m;

# Maximum allowed request body size
client_max_body_size 100M;

# Configure Lua script loading path
lua_package_path "/usr/local/openresty/nginx/luas/?.lua;;";
```

### Routing Core Logic Configuration (inside the Server block)
```nginx
# Root path routing processing
location / {
    set $topath '';
    # Execute authentication/routing matching logic during the access phase
    access_by_lua_file luas/mylua/access.lua;
    # Handle cross-origin during the response header phase
    header_filter_by_lua_file luas/mylua/cors.lua;

    # Handle OPTIONS preflight requests
    if ($request_method = 'OPTIONS') {
        return 204;
    }

    # Log collection
    log_by_lua_file luas/mylua/log.lua;

    # Proxy forwarding configuration
    proxy_pass_request_body on;
    proxy_pass $topath$is_args$args;

    # Forwarded request header configuration
    proxy_set_header Host $host:$server_port;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header REMOTE-HOST $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header x-forwarded-for $remote_addr;   
}

# Routing configuration reload interface
location = /reload {
    default_type 'text/html';
    content_by_lua_file luas/mylua/reload.lua;
    # Optional: Restrict access sources
    # allow 127.0.0.1;
    # allow 10.19.97.0/24;
    # deny all;
}
```

## MySQL Connection Configuration
### Configuration File Path
`openresty/nginx/luas/mylua/myconfig.lua` (Note: The original document does not specify the file name; standardized naming is recommended)

### Configuration Example
```lua
local _M = {}

_M.dbprop = {
    host = "Database Address",   -- e.g.: 127.0.0.1
    port = Port,          -- e.g.: 3306
    database = "Database Name", -- e.g.: nginx_gateway
    user = "Username",      -- e.g.: root
    password = "Password"     -- e.g.: 123456
}

return _M
```

## Routing Configuration
### 1. Core Data Table Description
#### (1) Routing Rule Table `sys_nginx_path`
| Field Name | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| path       | Request path received by the gateway                                        |
| topath     | Target service path to forward to                                           |
| islogin    | Authentication rule: -1=No authentication required; 1=Authentication required; 0=Authenticate if Token exists, skip if not |
| matchtype  | Matching rule: 1=Exact match; Other values=Prefix match (longest match first) |
| sortid     | Sort field (not used yet)                                                   |
| roles      | Allowed access roles (comma-separated; no role check if empty)              |
| areacode   | Area code (not used yet)                                                    |
| keyname    | Key name for authentication (associated with `keyname` in `sys_nginx_keys` table) |
| keytype    | Key type (fill in 1/0 or leave blank)                                       |
| format     | Error return format: Empty/1={"code":-1,"errtext":"Error content","message":Data}; 0={"code":-1,"message":"Error content","data":Data} |

#### (2) Key Configuration Table `sys_nginx_keys`
| Field Name | Description               |
|------------|---------------------------|
| keyname    | Key name (unique)         |
| secret     | Secret key content for JWT authentication |

### 2. Configuration Examples
#### (1) Direct Mapping (No Authentication Required)
| Field      | Value                      | Description                     |
|------------|----------------------------|---------------------------------|
| path       | /abc/test                  | Gateway request path            |
| topath     | http://127.0.0.1:8001/test | Forward to target service path  |
| matchtype  | 1                          | Exact match                     |
| islogin    | -1                         | No authentication required      |

#### (2) Prefix Mapping (No Authentication Required)
| Field      | Value                      | Description                     |
|------------|----------------------------|---------------------------------|
| path       | /api/                      | Gateway request prefix          |
| topath     | http://127.0.0.1:8002/     | Forward to target service prefix|
| islogin    | -1                         | No authentication required      |

#### (3) Prefix Mapping (Authentication Required)
| Field      | Value                      | Description                     |
|------------|----------------------------|---------------------------------|
| path       | /apiauth/                  | Gateway request prefix          |
| topath     | http://127.0.0.1:8003/     | Forward to target service prefix|
| islogin    | 1                          | Authentication required         |
| keyname    | tokenauth                  | Key name associated with the key table |

#### (4) Prefix Mapping (Authentication + Role Verification)
| Field      | Value                      | Description                     |
|------------|----------------------------|---------------------------------|
| path       | /apiauth/auth/             | Gateway request prefix          |
| topath     | http://127.0.0.1:8003/auth/ | Forward to target service prefix |
| islogin    | 1                          | Authentication required         |
| roles      | role1,role2                | Only specified roles allowed access |
| keyname    | tokenauth                  | Key name associated with the key table |

#### (5) Prefix Mapping (Authenticate if Token Exists)
| Field      | Value                      | Description                     |
|------------|----------------------------|---------------------------------|
| path       | /apiauth/authpass/         | Gateway request prefix          |
| topath     | http://127.0.0.1:8003/authpass/ | Forward to target service prefix |
| islogin    | 0                          | Authenticate if Token exists, skip if not |
| keyname    | tokenauth                  | Key name associated with the key table |
#### （6）topath points to an Nginx upstream
topath: http://backend/    means the request is forwarded to the Nginx upstream named backend.

### 3. Route Update
url(get): http://nginx_address/reload
When the database is modified, the route will not take effect immediately. You need to access the above address to activate the route.


### 4. Custom Format Adjustment Instructions
  Modify role separator: Edit the `_M.judgeroles` function in `luas/mylua/util.lua`
- To change to another separator, modify the following lines in the `_M.judgeroles` function of `luas/mylua/util.lua`:
		local tusr=splitdou(userrole,",");
		local task=splitdou(askrole,",")
- If your JWT token does not use "roles" as the field name, modify the `_M.judgetoken` function in `luas/mylua/jwttoken.lua`:
    util.judgeroles(format,roles,pathpara["roles"])	