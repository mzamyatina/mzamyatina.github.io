-- zamyatina-highlight.lua
-- Replaces auto-generated bibliography with custom one,
-- highlighting specific author names in bold using HTML.

local highlight_names = {
  ["Maria Zamyatina"] = true,
  ["M Zamyatina"] = true,
  ["M. Yu. Zamyatina"] = true
}

function escape_html(text)
  return text
    :gsub("&", "&amp;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")
end

function bold_if_match(name)
  return highlight_names[name] and "<strong>" .. name .. "</strong>" or name
end

function format_author(author)
  local given = author.given or ""
  local family = author.family or ""
  local full = given .. " " .. family
  return bold_if_match(full)
end

function format_authors(authors)
  local names = {}
  for i, author in ipairs(authors) do
    table.insert(names, format_author(author))
  end
  return table.concat(names, ", ")
end

function format_bib_entry(item, index)
  local authors = item.author and format_authors(item.author) or ""
  local year = item.issued and item.issued["date-parts"] and item.issued["date-parts"][1][1] or ""
  local title = item.title or ""
  local container = item["container-title"] or ""
  local volume = item.volume or ""
  local issue = item.issue or ""
  local pages = item.page or ""
  local doi = item.DOI and (" DOI: " .. item.DOI) or ""

  local parts = {
    string.format("<span class='bib-number'>%d.</span>", index),
    authors .. " (" .. year .. ").",
    "<em>" .. escape_html(title) .. "</em>.",
    escape_html(container),
    volume ~= "" and (", " .. volume) or "",
    issue ~= "" and ("(" .. issue .. ")") or "",
    pages ~= "" and (", " .. pages) or "",
    doi
  }

  return "<p class='bib-entry'>" .. table.concat(parts, " ") .. "</p>"
end

function Pandoc(doc)
  local bib_items = pandoc.utils.references or {}
  
  table.sort(bib_items, function(a, b)
    local a_year = a.issued and a.issued["date-parts"] and a.issued["date-parts"][1][1] or 0
    local b_year = b.issued and b.issued["date-parts"] and b.issued["date-parts"][1][1] or 0
    return a_year > b_year
  end)

  local bib_entries = {}
  for i, item in ipairs(bib_items) do
    table.insert(bib_entries, pandoc.RawBlock("html", format_bib_entry(item, i)))
  end

  for i, el in ipairs(doc.blocks) do
    if el.t == "Div" and el.identifier == "refs" then
      doc.blocks[i] = pandoc.Div(bib_entries, { id = "refs" })
    end
  end

  return doc
end

