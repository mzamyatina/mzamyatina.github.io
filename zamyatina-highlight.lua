-- zamyatina-highlight.lua
-- This Pandoc Lua filter bolds occurrences of specified author names in bibliography

local highlight_names = {
  "Maria Zamyatina",
  "M Zamyatina",
  "M. Yu. Zamyatina"
}

function bold_zamyatina_inlines(inlines)
  local text = pandoc.utils.stringify(inlines)
  for _, name in ipairs(highlight_names) do
    if text:find(name, 1, true) then
      text = text:gsub(name, "<b>" .. name .. "</b>")
    end
  end
  return pandoc.RawInline("html", text)
end

function Div(div)
  if div.identifier == "refs" then
    for i, elem in ipairs(div.content) do
      if elem.t == "Div" then
        for j, block in ipairs(elem.content) do
          if block.t == "Para" then
            elem.content[j] = pandoc.Para({bold_zamyatina_inlines(block.content)})
          end
        end
      end
    end
    return div
  end
end
