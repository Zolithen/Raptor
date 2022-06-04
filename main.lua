require "trace"
require "raptor"

raptor.log("Executing task: ", trace.styles.green, 1);

function love.draw()
	love.graphics.clear(0.25, 0.25, 0.25)
	--love.graphics.print("y - Run project", love.graphics.getWidth()-200, 0);
	love.graphics.print("y - Run project", love.graphics.getWidth()-200, 0);
	love.graphics.print("t - Download remaining libraries", love.graphics.getWidth()-200, 16);
	love.graphics.print("r - Delete libraries", love.graphics.getWidth()-200, 32);
	love.graphics.print("u - Reload configuration file", love.graphics.getWidth()-200, 48);

	for i,v in ipairs(raptor.reqs) do
		love.graphics.print(v.link .. " - " .. v.branch, love.graphics.getWidth()-400, 200+(16*i));
	end
	trace.draw(0, 0)
end

function love.keypressed(key)
	if key == "t" then
		raptor.download_remaining()
	end
	if key == "r" then
		raptor.delete_libraries()
	end
	if key == "y" then
		os.execute("lovec ./proj")
	end
	if key == "u" then
		raptor.reload_conf();
	end
end

function love.update(dt)
	raptor.catch()
end