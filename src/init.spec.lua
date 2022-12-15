local Promise = require(script.Parent.Parent.Promise)
local Subject = require(script.Parent)

return function()
	local subject
	beforeEach(function()
		subject = Subject.new()
	end)

	it("should notify subscribers", function()
		local wasFirstNotified = false
		local wasSecondNotified = false

		subject:subscribe(function()
			wasFirstNotified = true
		end)
		subject:subscribe(coroutine.create(function()
			wasSecondNotified = true
		end))

		subject:notify()

		expect(wasFirstNotified and wasSecondNotified).to.equal(true)
	end)

	it("should notify subscriber with arguments", function()
		local arguments
		subject:subscribe(function(...)
			arguments = { ... }
		end)

		subject:notify(true, "hello", 3)

		expect(arguments[1]).to.equal(true)
		expect(arguments[2]).to.equal("hello")
		expect(arguments[3]).to.equal(3)
	end)

	it("should not notify unsubscribed subscriber", function()
		local wasFirstNotified = false
		local wasSecondNotified = false
		local wasThirdNotified = false

		subject:subscribe(function()
			wasFirstNotified = true
		end)

		subject:subscribe(function()
			wasSecondNotified = true
		end)()

		subject:once(function()
			wasThirdNotified = true
		end)()

		subject:notify()

		expect(wasFirstNotified).to.equal(true)
		expect(wasSecondNotified).to.equal(false)
		expect(wasThirdNotified).to.equal(false)
	end)

	it("should only unsubscribe first duplicate subscriber", function()
		local wasNotified = false
		local function subscriber()
			wasNotified = true
		end

		subject:subscribe(subscriber)
		subject:subscribe(subscriber)()

		subject:notify()

		expect(wasNotified).to.equal(true)
	end)

	it("should only notify subscribers once", function()
		local notifiedCount = 0
		local function subscriber()
			notifiedCount += 1
		end

		subject:once(subscriber)

		subject:notify()
		subject:notify()

		expect(notifiedCount).to.equal(1)
	end)

	it("should resolve promise", function()
		local promise = subject:promise()

		expect(promise:getStatus()).to.equal(Promise.Status.Started)

		subject:notify("hello")

		local value

		expect(function()
			value = promise:now():expect()
		end).never.to.throw()

		expect(value).to.equal("hello")
	end)
end
