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

--
-- Views
--
local function admin_api_views(project_id) 
    local tmp = storage.get_project_views_24h(project_id)

    ngx.header['Content-Type'] = 'application/json'
    ngx.print(cjson.encode(tmp))
    ngx.exit(ngx.OK)
end

local function admin() 
    local t = tpl.loadfile(ROOT .. "templates/admin.html", "#{", "}")
    local tmp = storage.get_projects()

    ngx.header['Content-Type'] = 'text/html'
    ngx.print(tpl.render(t, { projects = tmp }))
    ngx.exit(ngx.OK)
end

local function admin_project(project_id) 
    local t = tpl.loadfile(ROOT .. "templates/admin_project.html", "#{", "}")
    local tmp = storage.get_project_views_24h(project_id)

    ngx.header['Content-Type'] = 'text/html'
    ngx.print(tpl.render(t, { views = tmp, project_id = project_id }))
    ngx.exit(ngx.OK)
end

local function track()
    local args = ngx.req.get_post_args()
    if args.project_id == nil then
        ngx.print("Bad Wolf")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
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
    ngx.exit(ngx.OK)
end

storage.init(config.db)

ngx.req.read_body()

ngx.header['Content-Type'] = 'text/plain'


--
-- Router
--
local routes = {
    ['/track/?$'] = track,
    ['/track/admin/?$'] = admin,
    ['/track/admin/project/([0-9]+)/?$'] = admin_project,
    ['/track/admin/api/views/project/([0-9]+)/?$'] = admin_api_views
}

for path, view in pairs(routes) do
    local match = string.match(ngx.var.request_uri, path)
    if match then
        view(match)
    end
end

-- 
-- 404 no routes matched
--
ngx.print("404 Not found")
ngx.exit(ngx.HTTP_NOT_FOUND)

