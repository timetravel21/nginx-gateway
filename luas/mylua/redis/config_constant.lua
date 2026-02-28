config = {}

config.redisConfig = {
    redis_a = { -- your connection name 
        --ip
        host = '1.1.1.1',
        --端口
        port = 6,
        --密码【如果没密码，可以不设置】
        -- pass = '',
        --超时时间，如果是测试环境debug的话，这个值可以给长一点；如果是正式环境，可以设置为200
        timeout = 120000,
        --redis的库
        database = 0,
    },
    }
return config
