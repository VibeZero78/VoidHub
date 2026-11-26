local src = game:HttpGet("https://raw.smokingscripts.org/" .. "Library")
src = src:gsub("VERTEX", "VOID"):gsub("Vertex", "Void"):gsub("vertex", "void")
return loadstring(src)()
