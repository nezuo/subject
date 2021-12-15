--[=[
	@class Subject

	Here is some description of what a subject object is!
]=]
local Subject = {}
Subject.__index = Subject

--[=[
	@return Subject

	```lua
	local subject = Subject.new()
	```
]=]
function Subject.new()
	return setmetatable({
		_subscribers = {},
	}, Subject)
end

--[=[
	@param ... any

	Calls all subscribers with `task.spawn` with the arguments.

	```lua
	subject:notify("a", 1, true)
	```
]=]
function Subject:notify(...)
	for _, subscriber in pairs(self._subscribers) do
		task.spawn(subscriber, ...)
	end
end

--[=[
	@param subscriber (...: any) -> ...any | thread
	@return () -> ()

	Adds a subscriber to the subject and returns a function to unsubscribe it.

	```lua
	local unsubscribe = subject:subscribe(function() end)

	unsubscribe()
	```
]=]
function Subject:subscribe(subscriber)
	local function unsubscribe()
		self._subscribers[unsubscribe] = nil
	end

	self._subscribers[unsubscribe] = subscriber

	return unsubscribe
end

return Subject
