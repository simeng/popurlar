local mysql = require "resty.mysql"
local redis = require "resty.redis"
local storage = {}

-- Archived views and admin settings
local archive = nil
-- Live views. Fast DB. Worker archives views from here
local live = nil

function storage.init(config)
    if config.archive.type == 'mysql' then
        local d, err = mysql:new()
        if not d then
            ngx.header['Content-Type'] = 'text/plain'
            ngx.print("Failed to initialize mysql: ", err)
            return
        end

        local ok, err, errno, sqlstate = d:connect(config.archive)
        if not ok then
            ngx.header['Content-Type'] = 'text/plain'
            ngx.print("Failed to connect: ", err, ": ", errno, " ", sqlstate)
            return
        end
        archive = d
    end

    if config.live.type == 'redis' then
        live = redis:new()
        local ok, err

        if config.live.socket then
            ok, err = live:connect(config.live.socket)
        elseif config.live.host then
            if config.live.port ~= nil then
                port = config.live.port
            else
                port = 6379
            end
            ok, err = live:connect(config.live.host, port)
        end

        if not ok then
            ngx.say("Failed to connect: ", err)
        end
    end
end

function storage.log_view(project_id, url)
    local view_id = live:incr('project:' .. project_id .. ':view_id')
    local view_key = 'view:' .. view_id
    local minute_key = 'date:' .. project_id .. ':' .. os.date("%Y-%m-%dT%H:%M", ngx.now())
    local hour_key = 'date:' .. project_id .. ':' .. os.date("%Y-%m-%dT%H", ngx.now())
    local data = {
        project_id = project_id,
        url = url
    }

    live:hmset(view_key, data)

    live:lpush(minute_key, view_id)
    live:lpush(hour_key, view_id)
end

function storage.get_projects()
    local sql = "SELECT id, title FROM projects"
    local projects = archive:query(sql)
    return projects
end

function storage.get_project_views_24h(project_id)
    local sql = "SELECT COUNT(*) views, url FROM views WHERE project_id = " .. ngx.quote_sql_str(project_id) .. " AND created > NOW() - INTERVAL 1 DAY GROUP BY url"
    local views = archive:query(sql)
    return views
end

return storage
