--local getconfig = require ".conf.lua.getconfig"
local cjson = require "cjson"

--local util=require ".conf.lua.util"
local jwttoken=require "mylua.jwttoken"
local getconfig = require "mylua.getconfig"


local jwt = require "resty.jwt"



local path=ngx.var.uri
ngx.say("topath12="..path)


--jwt_obj = jwt:verify("mynone","eyJhbGciOiJIUzI1NiJ9.eyJhcmVhIjoiMDAxMDAxMDA3Iiwicm9sZSI6Iua1i-ivleWRmDvmtYvor5XlkZgyO215dGVzdCIsImFyZWFuYW1lIjoi5a6B5rOi5biCIiwicm9sZWlkIjpudWxsLCJtb2JpbGUiOm51bGwsImxvZ2luIjoibXl0ZXN0XzAwMTAwMTAwN18wMDEwMDEwMDIwMDMiLCJ0eXBlIjoxLCJkZXAiOiIwMDEwMDEwMDIwMDMiLCJ0eXVzZXJpZCI6InRpYW55aWlkIiwiZGluZ3VzZXIiOm51bGwsImRpbmdwaG9uZSI6bnVsbCwibmFtZSI6Iua1i-ivlSIsImRpbmdjb2RlIjpudWxsLCJkZXBuYW1lIjoi5rWL6K-V6YOo6ZeoIiwiZXhwIjoxNjc4MjY5NTYxfQ.X-MQUWM7vYW0GqYvA82xXWnCDlpjWNbBykY27g0lYJw")



