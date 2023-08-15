local Promise = require(script.Parent.Promise)

--[=[
	@class Subject
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
		_onceSubscribers = {},
	}, Subject)
end

--[=[
	@param ... any

	Calls all subscribers in seperate threads with the arguments passed. The order in which each subscriber is called is undefined.

	```lua
	subject:notify("a", 1, true)
	```
]=]
function Subject:notify(...)
	local currentOnceSubscribers = self._onceSubscribers
	local currentSubscribers = table.clone(self._subscribers)

	self._onceSubscribers = {}

	for _, subscriber in currentSubscribers do
		task.spawn(subscriber, ...)
	end

	for _, subscriber in currentOnceSubscribers do
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

--[=[
	@param subscriber (...: any) -> ...any | thread
	@return () -> ()

	Adds a subscriber to the subject that is only notified once and returns a function to unsubscribe it.

	```lua
	local unsubscribe = subject:once(function() end)

	unsubscribe()
	```
]=]
function Subject:once(subscriber)
	local function unsubscribe()
		self._onceSubscribers[unsubscribe] = nil
	end

	self._onceSubscribers[unsubscribe] = subscriber

	return unsubscribe
end

--[=[
	@return Promise

	Returns a promise that resolves when the subject is notified. The promise can be canceled.

	```lua
	subject:promise():andThen(function(value)
		print(value) -- Hello!
	end)

	subject:notify("Hello!")
	```
]=]
function Subject:promise()
	return Promise.new(function(resolve, _, onCancel)
		local unsubscribe = self:once(resolve)

		onCancel(unsubscribe)
	end)
end

return Subject
