-- Cache for arXiv data to avoid duplicate fetches
local arxiv_cache = {}

local function fetch_arxiv_data(arxiv_id)
  if arxiv_cache[arxiv_id] then
    return arxiv_cache[arxiv_id]
  end

  local api_url = "https://export.arxiv.org/api/query?id_list=" .. arxiv_id
  local success, result = pcall(pandoc.pipe, "curl", {"-s", "-L", api_url}, "")

  if not success then
    quarto.log.warning("Failed to fetch arXiv data for " .. arxiv_id)
    return nil
  end

  local entry = result:match("<entry>(.-)</entry>")
  if not entry then
    quarto.log.warning("No entry found in arXiv response for " .. arxiv_id)
    return nil
  end

  local data = {}

  -- Extract title (skip the feed-level <title>)
  local raw_title = entry:match("<title>(.-)</title>")
  if raw_title then
    raw_title = raw_title:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    -- Split on ": " to separate title and subtitle
    local main, sub = raw_title:match("^(.-):%s+(.+)$")
    if main then
      data.title = main
      data.subtitle = sub
    else
      data.title = raw_title
    end
  end

  -- Extract abstract
  local abstract = entry:match("<summary>(.-)</summary>")
  if abstract then
    data.abstract = abstract:gsub("^%s+", ""):gsub("%s+$", "")
  end

  arxiv_cache[arxiv_id] = data
  return data
end

return {
  ["arxiv-abstract"] = function(args, kwargs)
    local arxiv_id = pandoc.utils.stringify(args[1])
    arxiv_id = arxiv_id:match("arxiv%.org/abs/(.+)") or arxiv_id

    local data = fetch_arxiv_data(arxiv_id)
    if data and data.abstract then
      local doc = pandoc.read(data.abstract, "markdown")
      return doc.blocks
    else
      return pandoc.Blocks({pandoc.Para({pandoc.Str("[Abstract not available]")})})
    end
  end
}
