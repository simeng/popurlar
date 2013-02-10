local json = require "cjson"
local tpl = require "slt2"

local storage = require "storage"

local ROOT = ngx.var.document_root .. "/../"

if not config then
    local f = assert(io.open(ROOT .. "etc/config.json", "r"))
    local c = f:read("*all")
    f:close()

    config = cjson.decode(c)
end

local function admin() 
    local t = tpl.loadfile(ROOT .. "templates/admin.html", "#{", "}")
    ngx.print(tpl.render(t))
end

local function track(args)
    local args = ngx.req.get_post_args()
    local project_id = ngx.unescape_uri(args.project_id)
    local url = nil
    if ngx.var.http_referer then
        url = ngx.var.http_referer
    elseif args.url then
        url = args.url
    end

    storage.log_view(project_id, url)

    ngx.header['Content-Type'] = 'application/json'
    ngx.print(json.encode({ status = 'ok' }))
end

storage.init(config.db)

ngx.req.read_body()
ngx.header['Content-Type'] = 'text/html'

local routes = {
    ['/track/?$'] = track,
    ['/track/admin/?$'] = admin
}

for path, view in pairs(routes) do
    local match = string.match(ngx.var.request_uri, path)
    if match then
        view(match)
    end
end


-- track(args)

