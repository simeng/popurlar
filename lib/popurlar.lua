local json = require "cjson"
local mysql = require "resty.mysql"

if not config then
    local f = assert(io.open(ngx.var.document_root .. "/../etc/config.json", "r"))
    local c = f:read("*all")
    f:close()

    config = cjson.decode(c)
end

local db, err = mysql:new()
if not db then
    ngx.header['Content-Type'] = 'text/plain'
    ngx.print("Failed to initialize mysql: ", err)
    return
end

local ok, err, errno, sqlstate = db:connect(config.db)
if not ok then
    ngx.header['Content-Type'] = 'text/plain'
    ngx.print("Failed to connect: ", err, ": ", errno, " ", sqlstate)
    return
end

ngx.req.read_body()
local args = ngx.req.get_post_args()
local project_id_quoted = ngx.quote_sql_str(ngx.unescape_uri(args.project_id))

local url_quoted = nil
if ngx.var.http_referer then
    url_quoted = ngx.quote_sql_str(ngx.var.http_referer)
elseif args.url then
    url_quoted = ngx.quote_sql_str(args.url)
end

local sql = "INSERT INTO views SET project_id = " .. project_id_quoted
if url_quoted then
    sql = sql .. ", url = " .. url_quoted
end
db:query(sql)

ngx.header['Content-Type'] = 'application/json'

ngx.print(json.encode({ status = 'ok' }))
