--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]
--!strict
-- ROBLOX NOTE: no upstream

local CurrentModule = script.Parent.Parent
local Packages = CurrentModule.Parent

local LuauPolyfill = require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object

local exports = require(CurrentModule)
local ModuleMocker = exports.ModuleMocker
local JestGlobals = require(Packages.Dev.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local it = JestGlobals.it
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach

local JestConfig = require(Packages.Dev.JestConfig)

local moduleMocker
beforeEach(function()
	moduleMocker = ModuleMocker.new(JestConfig.projectDefaults)
end)

it("mock return chaining", function()
	local myMock = moduleMocker:fn()
	expect(myMock()).toBeNil()

	myMock.mockReturnValueOnce(10).mockReturnValueOnce("x").mockReturnValue(true)
	expect(myMock()).toBe(10)
	expect(myMock()).toBe("x")
	expect(myMock()).toBe(true)
	expect(myMock()).toBe(true)
end)

it("default mock function name is jest.fn()", function()
	local myMock = moduleMocker:fn()
	expect(myMock.getMockName()).toBe("jest.fn()")
end)

it("returns a function as the second return value", function()
	local mock, mockFn = moduleMocker:fn()
	mock.mockImplementationOnce(function(a: string, b: string)
		return a .. b
	end)
	mock.mockReturnValue(true)

	expect(typeof(mockFn)).toBe("function")

	expect(mockFn("a", "b")).toBe("ab")
	expect(mock).toHaveBeenLastCalledWith("a", "b")
	expect(mock).toHaveLastReturnedWith("ab")

	expect(mockFn()).toBe(true)
	expect(mock).toHaveLastReturnedWith(true)
end)

-- These tests are placed here rather than in JestMockGenv because they require
-- use of the ModuleMocker functions.
describe("global mocking & spying", function()
	it("globalEnv can spy on top-level global functions", function()
		local mockPrint = moduleMocker:spyOn(jest.globalEnv, "print")
		mockPrint.mockReturnValueOnce("abcde")

		local print2 = print :: any -- satisfy the type checker
		local returnValue = print2("This is an intentional print from a unit test")
		local callsAfter = #mockPrint.mock.calls

		expect(callsAfter).toBe(1)
		expect(returnValue).toBe("abcde")

		mockPrint.mockReset()
	end)

	it("globalEnv can spy on nested global functions", function()
		local mockRand = moduleMocker:spyOn(jest.globalEnv.math, "random")
		mockRand.mockReturnValueOnce("abcde")

		local random2 = math.random :: any -- satisfy the type checker
		local returnValue = random2()
		local callsAfter = #mockRand.mock.calls

		expect(callsAfter).toBe(1)
		expect(returnValue).toBe("abcde")

		mockRand.mockReset()
	end)

	it("globalEnv unmocked functions bypass mock impls", function()
		local mockRand = moduleMocker:spyOn(jest.globalEnv.math, "random")
		mockRand.mockReturnValueOnce("abcde")

		local returnValue = jest.globalEnv.math.random()
		local callsAfter = #mockRand.mock.calls

		expect(callsAfter).toBe(0)
		expect(returnValue).never.toBe("abcde")
		expect(returnValue).toEqual(expect.any("number"))

		mockRand.mockReset()
	end)

	it("globalEnv mocks do not persist beyond restoration", function()
		local mockRand = moduleMocker:spyOn(jest.globalEnv.math, "random")
		mockRand.mockReturnValueOnce("abcde")
		mockRand.mockRestore()

		local returnValue = math.random()

		expect(returnValue).never.toBe("abcde")
		expect(returnValue).toEqual(expect.any("number"))
	end)

	it("globalEnv can still be mocked after restoration", function()
		local mockRand = moduleMocker:spyOn(jest.globalEnv.math, "random")
		mockRand.mockReturnValueOnce("abcde")
		mockRand.mockRestore()
		mockRand.mockReturnValueOnce("vwxyz")

		local returnValue = math.random()

		expect(returnValue).toBe("vwxyz")
	end)

	it("resetAllMocks resets Lua globals back to their default behavior", function()
		expect(math.random()).never.toBeNil()
		jest.resetAllMocks()
		expect(math.random()).never.toBeNil()
	end)
end)

describe("oldFunctionSpying", function()
	it("oldFunctionSpying = true injects mock objects", function()
		local config = table.clone(JestConfig.projectDefaults)
		config.oldFunctionSpying = true
		local configuredMocker = ModuleMocker.new(config)

		local guineaPig = {
			foo = function() end,
		}
		local mockObj = configuredMocker:spyOn(guineaPig, "foo")

		expect(mockObj).toEqual(expect.any("table"))
		expect(guineaPig.foo).toEqual(expect.any("table"))
		expect(guineaPig.foo).toEqual(mockObj)
	end)

	it("oldFunctionSpying = false injects alike types", function()
		local config = table.clone(JestConfig.projectDefaults)
		config.oldFunctionSpying = false
		local configuredMocker = ModuleMocker.new(config)

		local guineaPig = {
			foo = function() end,
		}
		local mockObj = configuredMocker:spyOn(guineaPig, "foo")

		expect(mockObj).toEqual(expect.any("table"))
		expect(guineaPig.foo).toEqual(expect.any("function"))
		expect(guineaPig.foo).never.toEqual(mockObj)
	end)

	it("defaults to backwards compatibile behaviour", function()
		local guineaPig = {
			foo = function() end,
		}
		local mockObj = moduleMocker:spyOn(guineaPig, "foo")

		expect(mockObj).toEqual(expect.any("table"))
		expect(guineaPig.foo).toEqual(expect.any("table"))
		expect(guineaPig.foo).toEqual(mockObj)
	end)
end)

describe("spyOn supported types", function()
	it("allows functions", function()
		local guineaPig = {
			foo = function() end,
		}

		expect(function()
			moduleMocker:spyOn(guineaPig, "foo")
		end).never.toThrow()
	end)

	it("allows callable tables", function()
		local guineaPig = {
			foo = setmetatable({}, { __call = function() end }),
		}

		expect(function()
			moduleMocker:spyOn(guineaPig, "foo")
		end).never.toThrow()
	end)

	it("disallows non-callable tables", function()
		local guineaPig = {
			foo = {},
			bar = setmetatable({}, { __index = function() end }),
		}

		expect(function()
			moduleMocker:spyOn(guineaPig, "foo")
		end).toThrow()

		expect(function()
			moduleMocker:spyOn(guineaPig, "bar")
		end).toThrow()
	end)

	it("does not allow tables with locked callable metatables", function()
		local guineaPig = {
			foo = setmetatable({}, { __metatable = { __call = function() end } }),
		}

		expect(function()
			moduleMocker:spyOn(guineaPig, "foo")
		end).toThrowErrorMatchingSnapshot()
	end)

	it("disallows other kinds of value", function()
		local guineaPig = {
			foo = newproxy(true),
			bar = 25,
		}

		expect(function()
			moduleMocker:spyOn(guineaPig, "foo")
		end).toThrow()

		expect(function()
			moduleMocker:spyOn(guineaPig, "bar")
		end).toThrow()
	end)
end)

describe("callable table spying", function()
	local guineaPig
	local callable
	local mock: exports.Mock
	beforeEach(function()
		callable = setmetatable({
			red = 1,
			blue = 2,
		}, {
			florb = true,
			__call = function(self, ...)
				return {
					42 :: any,
					{ if self == callable then "original" else "mock", ... },
				}
			end,
		})
		guineaPig = {
			foo = callable,
		}
		mock = moduleMocker:spyOn(guineaPig, "foo")
	end)

	it("does not change default behaviour", function()
		local result = guineaPig.foo("one", "two", "three")
		expect(result[1]).toBe(42)
		expect(result[2]).toEqual({ "mock", "one", "two", "three" })
	end)
	it("supports the usual mocking facilities", function()
		mock.mockReturnValue(25)
		expect(guineaPig.foo()).toBe(25)
	end)
	it("passes correct parameters to mock implementation", function()
		mock.mockImplementation(function(self: any, ...)
			return { if self == callable then "original" else "mock", ... }
		end)
		expect(guineaPig.foo("foo", "bar", "baz")).toEqual({ "mock", "foo", "bar", "baz" })
	end)
	it("uses a cloned metatable", function()
		local original = getmetatable(callable)
		local mock = getmetatable(guineaPig.foo)
		expect(mock).never.toBe(original)
		expect(mock.florb).toBe(true)
	end)
	it("uses a cloned table", function()
		local original = callable
		local mock = guineaPig.foo
		expect(mock).never.toBe(original)
		expect(mock.red).toBe(original.red)
	end)
end)

describe("instance mocking", function()
	local configuredMocker
	local exampleIns, spy
	beforeEach(function()
		local config = table.clone(JestConfig.projectDefaults)
		config.mockDataModel = true
		configuredMocker = ModuleMocker.new(config)

		exampleIns = Instance.new("TextLabel")
		exampleIns.Name = "The Example Instance"
		exampleIns.BackgroundColor3 = Color3.new(1, 1, 1)
		exampleIns.Size = UDim2.fromOffset(200, 50)
		exampleIns.Text = "I am a good example!"
		exampleIns.TextColor3 = Color3.new(0, 0, 0)
		exampleIns.Font = Enum.Font.BuilderSans

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 16)
		corner.Parent = exampleIns

		spy = configuredMocker.dataModelMocker:mockInstance(exampleIns).spy
	end)

	it("mockDataModel = true enables spyOn for instances", function()
		expect(function()
			configuredMocker:spyOn(exampleIns, "IsA")
		end).never.toThrow()
	end)

	it("mockDataModel = false disables spyOn for instances", function()
		local config = table.clone(JestConfig.projectDefaults)
		config.mockDataModel = false
		configuredMocker = ModuleMocker.new(config)

		expect(function()
			configuredMocker:spyOn(exampleIns, "IsA")
		end).toThrow("the `mockDataModel` setting is not enabled")
	end)

	it("defaults to backwards compatibile behaviour", function()
		expect(function()
			moduleMocker:spyOn(exampleIns, "IsA")
		end).toThrow("the `mockDataModel` setting is not enabled")
	end)

	it("limits spyOn to previously mocked instances", function()
		expect(function()
			configuredMocker:spyOn(Instance.new("TextLabel"), "IsA")
		end).toThrow("not mockable")
	end)

	it("limits spyOn to unprotected instance methods", function()
		configuredMocker:protectDataModel(function(instance, method)
			return instance == exampleIns and method == "IsA"
		end)
		expect(function()
			configuredMocker:spyOn(Instance.new("TextLabel"), "IsA")
		end).toThrow("not mockable")

		expect(function()
			configuredMocker:spyOn(exampleIns, "GetFullName")
		end).toThrow("not mockable")

		expect(function()
			configuredMocker:spyOn(exampleIns, "IsA")
		end).never.toThrow()
	end)

	it("works with both instances and spies", function()
		expect(function()
			configuredMocker:spyOn(exampleIns, "IsA")
		end).never.toThrow()
		expect(function()
			configuredMocker:spyOn(spy, "IsA")
		end).never.toThrow()
	end)

	describe("given Instance", function()
		it("preserves behaviour by default", function()
			configuredMocker:spyOn(exampleIns, "FindFirstChildOfClass")
			expect(exampleIns:FindFirstChildOfClass("UICorner")).toEqual(expect.any("Instance"))
			expect(spy:FindFirstChildOfClass("UICorner")).toEqual(expect.any("Instance"))
		end)

		it("allows changing API", function()
			local mock = configuredMocker:spyOn(exampleIns, "FindFirstChildOfClass")
			mock.mockImplementation(function()
				return 42
			end)
			expect(spy:FindFirstChildOfClass("UICorner")).toEqual(42)
		end)

		it("allows extending API", function()
			local mock = configuredMocker:spyOn(exampleIns, "Cinnamon")
			mock.mockImplementation(function()
				return 42
			end)
			expect((spy :: any):Cinnamon()).toEqual(42)
		end)

		it("uses correct self", function()
			local mock = configuredMocker:spyOn(exampleIns, "GetFullName")
			mock.mockImplementation(function(self)
				return self
			end)
			expect((spy :: any):GetFullName()).toEqual(spy)
		end)

		it("correctly handles calling spyOn multiple times", function()
			local mockA, mockB
			expect(function()
				mockA = configuredMocker:spyOn(exampleIns, "GetFullName")
				mockB = configuredMocker:spyOn(exampleIns, "GetFullName")
			end).never.toThrow()
			expect(mockA).toEqual(mockB)
		end)
	end)

	describe("given spy", function()
		it("preserves behaviour by default", function()
			configuredMocker:spyOn(spy, "FindFirstChildOfClass")
			expect(exampleIns:FindFirstChildOfClass("UICorner")).toEqual(expect.any("Instance"))
			expect(spy:FindFirstChildOfClass("UICorner")).toEqual(expect.any("Instance"))
		end)

		it("allows changing API", function()
			local mock = configuredMocker:spyOn(spy, "FindFirstChildOfClass")
			mock.mockImplementation(function()
				return 42
			end)
			expect(spy:FindFirstChildOfClass("UICorner")).toEqual(42)
		end)

		it("allows extending API", function()
			local mock = configuredMocker:spyOn(spy, "Cinnamon")
			mock.mockImplementation(function()
				return 42
			end)
			expect((spy :: any):Cinnamon()).toEqual(42)
		end)

		it("uses correct self", function()
			local mock = configuredMocker:spyOn(spy, "GetFullName")
			mock.mockImplementation(function(self)
				return self
			end)
			expect((spy :: any):GetFullName()).toEqual(spy)
		end)

		it("correctly handles calling spyOn multiple times", function()
			local mockA, mockB
			expect(function()
				mockA = configuredMocker:spyOn(spy, "GetFullName")
				mockB = configuredMocker:spyOn(spy, "GetFullName")
			end).never.toThrow()
			expect(mockA).toEqual(mockB)
		end)
	end)
end)
