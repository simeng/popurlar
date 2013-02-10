local mysql = require "resty.mysql"
local storage = {}
local db = nil

function storage.init(config)
    local d, err = mysql:new()
    if not d then
        ngx.header['Content-Type'] = 'text/plain'
        ngx.print("Failed to initialize mysql: ", err)
        return
    end

    local ok, err, errno, sqlstate = d:connect(config)
    if not ok then
        ngx.header['Content-Type'] = 'text/plain'
        ngx.print("Failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    db = d
end

function storage.log_view(project_id, url)
    local sql = "INSERT INTO views SET project_id = " .. ngx.quote_sql_str(project_id)
    if url then
        sql = sql .. ", url = " .. ngx.quote_sql_str(url)
    end
    db:query(sql)
end

return storage
