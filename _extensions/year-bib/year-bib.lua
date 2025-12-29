function Div(el)
  if el.identifier == 'refs' then
    -- This will be processed after citations are resolved
    -- We'll add CSS to style it
    return el
  end
  return el
end

function Meta(meta)
  if meta['year-bibliography'] then
    -- Read bibliography file
    local bib_file = pandoc.utils.stringify(meta.bibliography)
    local f = io.open(bib_file, 'r')
    if not f then return meta end

    local content = f:read('*all')
    f:close()

    -- Parse years and IDs
    local refs_by_year = {}
    local current_id = nil

    for line in content:gmatch("[^\r\n]+") do
      local id_match = line:match("^%s*-%s*id:%s*(.+)")
      if id_match then
        current_id = id_match:match("^%s*(.-)%s*$")
      end

      local year_match = line:match("year:%s*(%d+)")
      if year_match and current_id then
        local year = tonumber(year_match)
        if not refs_by_year[year] then
          refs_by_year[year] = {}
        end
        table.insert(refs_by_year[year], current_id)
        current_id = nil
      end
    end

    -- Store in meta for later use
    meta['refs-by-year'] = refs_by_year
  end

  return meta
end
