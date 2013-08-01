if !exists(':Tabularize')
  finish
endif

AddTabularPipeline! spaces /\s/ map(a:lines, "substitute(v:val, '  *', ' ', 'g')") | tabular#TabularizeStrings(a:lines, '\s', 'l0')
