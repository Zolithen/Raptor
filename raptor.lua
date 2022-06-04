raptor = {
	reqs = {},
	threads = {},
	proj_dir = "./proj"
}

function locate(strr)
	return raptor.proj_dir .. "/" .. strr
end

raptor.levels = {
	"MAIN",
	"TASK"
}

function lines_from(file)
  lines = ""
  for line in io.lines(file) do 
    lines = lines .. line
  end
  return lines
end


--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

function raptor.log(t,s,l)
	local ti = os.date("%c",os.time());
	local th = raptor.levels[l or 1];
	trace.print("["..th.."][".. ti .."]"..t,s);
end

function raptor.add(repo, branch)
	table.insert(raptor.reqs, {link=repo, branch=branch})
end

function raptor.reset_list()
	for i,v in ipairs(raptor.reqs) do
		table.remove(raptor.reqs, i)
	end
end

function raptor.reload_conf()
	raptor.reset_list();
	
	loadstring(lines_from(locate"raptor_conf.lua"))()
end

function raptor.catch()
	for i,b in ipairs(raptor.threads) do
		local v = b.thread;
		local e = v:getError()
		if e then
			raptor.log("Error catched from thread download-"..b.name..":", trace.styles.red);
			raptor.log(e, trace.styles.red)
		end
		if not v:isRunning() then
			raptor.log("Library " .. b.name .. " finished downloading.", trace.styles.green)
			table.remove(raptor.threads, i)
		end
	end
end

function raptor.download(link, branch)
	print("os.execute('git clone --single-branch --branch " .. branch .. " \"https://github.com/" .. link .. "\" \""..raptor.proj_dir.."/"..link.."\"')")
	table.insert(raptor.threads, {
		name = link,
		thread = love.thread.newThread("\nos.execute('git clone --depth 1 --single-branch --branch " .. branch .. " \"https://github.com/" .. link .. "\" \""..raptor.proj_dir.."/"..link.."\"')")
	})
	raptor.threads[#raptor.threads].thread:start()
end

function raptor.download_all()
	for i,v in ipairs(raptor.reqs) do
		raptor.download(v.link, v.branch)
	end
end

function raptor.download_remaining()
	for i,v in ipairs(raptor.reqs) do
		if not isdir(raptor.proj_dir..v.link) then
			raptor.download(v.link, v.branch)
		end
	end
end

function raptor.delete_cached(link)
	os.execute("rmdir /Q /S \"" .. locate(link).."\"")
end

function raptor.delete_libraries()
	raptor.log("Deleting every library in cache...", trace.styles.green)
	for i,v in ipairs(raptor.reqs) do
		raptor.delete_cached(v.link)
	end
end

--os.execute("git " .. "clone --single-branch --branch " .. v.branch .. " \"" .. v.path .. "\" \"" .. locate"libs" .. "\\" .. v.name.. "\"")