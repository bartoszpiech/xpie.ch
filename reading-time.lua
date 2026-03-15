local words = 0

return {
  { Str = function(el) words = words + 1 end },
  { Pandoc = function(doc)
      local mins = math.max(1, math.ceil(words / 200))
      doc.meta['reading-time'] = pandoc.MetaInlines{ pandoc.Str(mins .. ' min read') }
      return doc
    end
  }
}
