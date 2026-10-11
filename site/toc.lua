-- Moves the first H1 of README.md into the page title block.
-- The title is then shown above the table of contents and is not listed in it.
local title

function Header(h)
  if h.level == 1 and not title then
    title = h.content
    return {}
  end
  return h
end

function Meta(meta)
  if title then
    meta.title = pandoc.MetaInlines(title)
  end
  return meta
end
