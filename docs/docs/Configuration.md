---
id: configuration
title: Configuring Jest
---
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration)

The Jest Roblox philosophy is to work great by default, but sometimes you just need more configuration power.

![Deviation](/img/deviation.svg)

The configuration should be defined in a `jest.config.lua` file.

The configuration file should simply export a table:
```lua
return {
	verbose = true,
}
```

Or an async function returning an object:
```lua
return Promise.resolve():andThen(function()
	return {
		verbose = true,
	}
end)
```

## Options

import TOCInline from "@theme/TOCInline";

<TOCInline toc={
	toc.filter((node) => node.level === 3)
}/>

## Reference

### `clearmocks` \[boolean]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#clearmocks-boolean)  ![Aligned](/img/aligned.svg)

Default: `false`

Automatically clear mock calls, instances, contexts and results before every test. Equivalent to calling [`jest.clearAllMocks()`](jest-object#jestclearallmocks) before each test. This does not remove any mock implementation that may have been provided.

### `displayName` \[string, table]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#displayname-string-object)  ![API Change](/img/apichange.svg)

Default: `nil`

Allows for a label to be printed alongside a test while it is running. This becomes more useful in multi-project repositories where there can be many jest configuration files. This visually tells which project a test belongs to.

```lua
return {
	displayName = 'CLIENT',
}
```

Alternatively, a table with the keys `name` and `color` can be passed. This allows for a custom configuration of the background color of the displayName. `displayName` defaults to white when its value is a string. Jest Roblox uses [`chalk-lua`](https://github.com/Roblox/chalk-lua) to provide the color. As such, all of the valid options for colors supported by `chalk-lua` are also supported by Jest Roblox.

```lua
return {
	displayName = {
		name = 'CLIENT',
		color = 'blue',
	}
}
```

### `oldFunctionSpying` \[boolean]
![Roblox only](/img/roblox-only.svg)

Changes how [`jest.spyOn()`](jest-object#jestspyonobject-methodname) overwrites
methods in the spied object, making it behave like older versions of Jest.

* When `oldFunctionSpying = true`, it will overwrite the spied method with a
  *mock object*. (old behaviour)
* When `oldFunctionSpying = false`, it will overwrite the spied method with a
  *regular Lua function*. (new behaviour)

Regardless of the value of `oldFunctionSpying`, the `spyOn()` function will
always return a mock object.

```lua
-- when `oldFunctionSpying = false` (old behaviour)

local guineaPig = {
	foo = function() end
}

local mockObj = jest.spyOn(guineaPig, "foo")
mockObj.mockReturnValue(25)

print(typeof(guineaPig.foo)) --> table
print(typeof(mockObj)) --> table
print(guineaPig.foo == mockObj) --> true
```

```lua
-- when `oldFunctionSpying = true` (new behaviour)

local guineaPig = {
	foo = function() end
}

local mockObj = jest.spyOn(guineaPig, "foo")

print(typeof(guineaPig.foo)) --> function
print(typeof(mockObj)) --> table
print(guineaPig.foo == mockObj) --> false
```

### `projects` \[array&lt;Instance&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#projects-arraystring--projectconfig)  ![API Change](/img/apichange.svg)

Default: `nil`

When the `projects` configuration is provided with an array of instances, Jest Roblox will run tests in all of the specified projects at the same time. This is great for monorepos or when working on multiple projects at the same time.

```lua
return {
	projects = { Workspace.ProjectB, Workspace.ProjectB },
}
```

This example configuration will run Jest Roblox in the `ProjectA` as well as the `ProjectB` directories. You can have an unlimited amount of projects running in the same Jest Roblox instance.

:::tip

When using multi-project runner, it's recommended to add a `displayName` for each project. This will show the `displayName` of a project next to its tests.

:::

### `mockDataModel` \[boolean]
![Roblox only](/img/roblox-only.svg)

Turns on instance mocking features in Jest.  This allows *whitelisted* instances to be used
with Jest functions such as [`jest.spyOn()`](jest-object#spying-on-instances).

Currently, the following instances are whitelisted for use:
* `game`

:::warning

Jest does not fully emulate the behaviour of mocked instances at this time. You
may need to modify your code to be compatible with instance mocks:

* Mocked instances appear as table types rather than real `Instance` types, so
  you can't pass them to functions expecting `Instance` types.
  * In particular, this breaks code patterns such as `x:IsDescendantOf(game)`.
* The hierarchy is not modelled; accessing an instance via `.Parent`,
  `:FindFirstChild()` or other similar methods will return the original
  instance, not the mocked instance.
  * This breaks some expectations, for example `workspace.Parent ~= game`.

In general, you should only enable instance mocks if you are taking advantage of
the feature. Otherwise, you should leave them disabled for best compatibility.

The Jest Lua team is aware of ways this can be mitigated, but they require much
more engineering effort. If you are interested in emulating more behaviours of
the data model, please reach out so we're aware of the interest.

:::

<!-- ### `restoreMocks` \[boolean]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#restoremocks-boolean)  ![Aligned](/img/aligned.svg)

Default: `false`

Automatically restore mock state and implementation before every test. Equivalent to calling [`jest.restoreAllMocks()`](jest-object#jestrestoreallmocks) before each test. This will lead to any mocks having their fake implementations removed and restores their initial implementation. -->

### `rootDir` \[Instance]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#rootdir-string)  ![API Change](/img/apichange.svg)

Default: The root of the directory containing your Jest Roblox [config file](#).

The root directory that Jest Roblox should scan for tests and modules within.

Oftentimes, you'll want to set this to your main workspace, corresponding to where in your repository the code is stored.

<!-- The root directory that Jest Roblox should scan for tests and modules within. If you put your Jest config inside your `package.json` and want the root directory to be the root of your repo, the value for this config param will default to the directory of the `package.json`.

Oftentimes, you'll want to set this to `'src'` or `'lib'`, corresponding to where in your repository the code is stored.

:::tip

Using `'<rootDir>'` as a string token in any other path-based configuration settings will refer back to this value. For example, if you want a [`setupFiles`](#setupfiles-array) entry to point at the `some-setup.js` file at the root of the project, set its value to: `'<rootDir>/some-setup.js'`.

::: -->

### `reporters` \[array&ltInstance|string|table&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#reporters-arraymodulename--modulename-options)  ![API Change](/img/apichange.svg)

Default: `nil`

Use this configuration option to add reporters to Jest Roblox. It must be a list of ModuleScripts, additional options can be passed to a reporter by passing in a table:
```lua
reporters = {
	"default",
	{ reporter = Workspace.customReporter, options = { banana = "yes", pineapple = "no" }}
}
```

#### Default Reporter
If custom reporters are specified, the default Jest reporter will be overridden. If you wish to keep it, `"default"` must be passed as a reporters name:
```lua
reporters = {
	"default",
	{ reporter = Workspace.jestJunit, options = { outputDirectory = "reports", outputName = "report.xml" }}
}
```

#### GitHub Actions Reporter
If included in the list, the built-in GitHub Actions Reporter will annotate changed files with test failure messages:
```lua
reporters = {
	"default",
	"github-actions"
}
```

#### Summary Reporter
Summary reporter prints out summary of all tests. It is a part of default reporter, hence it will be enabled if `"default"` is included in the list. For instance, you might want to use it as stand-alone reporter instead of the default one.
```lua
reporters = {
	"summary"
}
```

#### Custom Reporters

Custom reporters module must export a class that takes `globalConfig`, `reporterOptions` and `reporterContext` as constructor arguments in a `.new` method and implements at least the `onRunComplete()` method (for the full list of methods and argument types see the `Reporter` interface in [jest-reporters/src/types.lua](https://github.com/Roblox/jest-roblox-internal/blob/master/src/jest-reporters/src/types.lua)).

```lua title="CustomReporter.lua"
local CustomReporter = {}
CustomReporter.__index = CustomReporter

function CustomReporter.new(globalConfig, reporterOptions, reporterContext)
	local self = setmetatable({}, CustomReporter)
	self._globalConfig = globalConfig
	self._options = reporterOptions
	self._context = reporterContext
	return self
end

function CustomReporter:onRunComplete(textContexts, results)
	print("Custom reporter output:")
	print("global config:", print(self._globalConfig))
	print("options for this reporter from Jest config:", print(self._options))
	print("reporter context passed from test scheduler:", print(self._context))
end

-- Optionally, reporters can force Jest to exit with non zero code by returning
-- a LuauPolyfill `Error` from `getLastError()` method.
-- https://roblox.github.io/jest-roblox-internal/expect#error
function CustomReporter:getLastError()
	if self._shouldFail then
		return Error.new("Custom reporter error!")
	end
end

return CustomReporter
```

### `roots` \[array&lt;Instance&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#roots-arraystring)  ![API Change](/img/apichange.svg)

Default: `{<rootDir>}`

A list of paths to directories that Jest Roblox should use to search for files in.

There are times where you only want Jest Roblox to search in a single sub-directory (such as cases where you have a `src/` directory in your repo), but prevent it from accessing the rest of the repo.

### `setupFiles` \[array&lt;ModuleScript&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#setupfiles-array)  ![API Change](/img/apichange.svg)

Default: `{}`

A list of ModuleScripts that run some code to configure or set up the testing environment. Each setupFile will be run once per test file. Since every test runs in its own environment, these scripts will be executed in the testing environment before executing [`setupFilesAfterEnv`](#setupfilesafterenv-array) and before the test code itself.

### `setupFilesAfterEnv` \[array&lt;ModuleScript&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#setupfilesafterenv-array)  ![API Change](/img/apichange.svg)

Default: `{}`

A list of ModuleScripts that run some code to configure or set up the testing framework before each test file in the suite is executed. Since [`setupFiles`](#setupfiles-arraymodulescript) executes before the test framework is installed in the environment, this script file presents you the opportunity of running some code immediately after the test framework has been installed in the environment but before the test code itself.

In other words, `setupFilesAfterEnv` modules are meant for code which is repeating in each test file. Having the test framework installed makes Jest [globals](api), [`jest` object](jest-object) and [`expect`](expect) accessible in the modules. For example, you can add [extra matchers](expect#expectextendmatchers) or call [setup and teardown](setup-teardown) hooks:
```lua title="setupJest.lua"
local JestGlobals = require(Packages.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local afterEach = JestGlobals.afterEach

expect.extend({
	newMatcher = function(self, received, expected)
		-- ...
	end)
})

afterEach(function()
	jest.useRealTimers()
end)
```

```lua title="jest.config.lua"
return {
	setupFilesAfterEnv = { Workspace.setupJest },
}
```

### `slowTestThreshold` \[number]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#slowtestthreshold-number)  ![Aligned](/img/aligned.svg)

Default: `5`

The number of seconds after which a test is considered as slow and reported as such in the results.

### `snapshotFormat` \[table]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#snapshotformat-object)  ![Aligned](/img/aligned.svg)

Default: `nil`

Allows overriding specific snapshot formatting options documented in the [pretty-format readme](https://github.com/facebook/jest/blob/main/packages/pretty-format/README.md#usage-with-options), with the exceptions of `compareKeys` and `plugins`.

![Deviation](/img/deviation.svg)

`pretty-format` also supports the formatting option `printInstanceDefaults` (default: `true`) which can be set to `false` to only print properties of a Roblox `Instance` that have been changed.

For example, this config would have the snapshot formatter not print out any unmodified values of `TextLabel`.
```lua title="jest.config.lua"
return {
	testMatch = { "**/*.spec" },
	snapshotFormat = { printInstanceDefaults = false }
}
```
```lua title="test.spec.lua"
test('printInstanceDefaults', function()
	local label = Instance.new("TextLabel")
	label.Text = "Hello"
	expect(label).toMatchSnapshot()
end)
```
```lua title="test.spec.snap.lua"
exports[ [=[printInstanceDefaults 1]=] ] = [=[

TextLabel {
  "Text": "Hello",
}
]=]
```

`pretty-format` further supports redacting stack traces from error logs via the
`RedactStackTraces` plugin. By default, this only attempts to redact the
contents of `Error` objects, but can be configured to search through strings
with the `redactStackTracesInStrings` boolean (default: `false`).

For example, this lets you save snapshots that contain stack traces, without
those stack traces depending on the actual code structure of the repository.
This reduces the chance of the snapshot test breaking due to unrelated changes
in far-away parts of the code.

```lua title="jest.config.lua"
return {
	testMatch = { "**/*.spec" },
	snapshotFormat = { redactStackTracesInStrings = true }
}
```
```lua title="test.spec.lua"
test('print stack trace', function()
	expect(debug.traceback()).toMatchSnapshot()
end)
```
```lua title="test.spec.snap.lua"
exports[ [=[print stack trace 1]=] ] = [=[
Redacted.Stack.Trace:1337 function epicDuck
Redacted.Stack.Trace:1337 function epicDuck
Redacted.Stack.Trace:1337 function epicDuck
Redacted.Stack.Trace:1337 function epicDuck
]=]
```


### `snapshotSerializers` \[array&lt;serializer&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#snapshotserializers-arraystring)  ![API Change](/img/apichange.svg)

Default: `{}`

A list of snapshot serializers Jest Roblox should use for snapshot testing.

Jest Roblox has default serializers for built-in Lua types, Roblox types and Instances, and React Roblox elements.

```lua title="customSerializer.lua"
local function serialize(val, config, indentation, depth, refs, printer)
	return "Pretty foo: "
		.. printer(val.foo, config, indentation, depth, refs, printer)
end

local function test(val)
	return typeof(val) == "table" and val.foo ~= nil
end

return {
	serialize = serialize,
	test = test,
}
```

`printer` is a function that serializes a value using existing plugins.

Add `customSerializer` to your Jest Roblox configuration:
```lua
return {
	snapshotSerializers = { Workspace.customSerializer }
}
```

Finally tests would look as follows:
```lua
test('uses custom serializer', function()
	local bar = {
		foo = {
			x = 1,
			y = 2,
		}
	}
	expect(bar).toMatchSnapshot()
end)
```

Rendered snapshot:
```lua
Pretty foo: Table {
  "x": 1,
  "y": 2,
}
```

To make a dependency explicit instead of implicit, you can call [`expect.addSnapshotSerializer`](expect#expectaddsnapshotserializerserializer) to add a module for an individual test file instead of adding its path to `snapshotSerializers` in Jest configuration.

More about serializers API can be found [here](https://github.com/facebook/jest/tree/main/packages/pretty-format/README.md#serialize).

### `testFailureExitCode` \[number]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#testfailureexitcode-number)  ![Aligned](/img/aligned.svg)

Default: `1`

The exit code Jest Roblox returns on test failure.

:::info

This does not change the exit code in the case of Jest Roblox errors (e.g. invalid configuration).

:::

### `testMatch` \[array&lt;string&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#testmatch-arraystring)  ![Aligned](/img/aligned.svg)

Default: `{ "**/__tests__/**/*", "**/?(*.)+(spec|test)?(.lua|.luau)" }`

The glob patterns Jest Roblox uses to detect test files. 
By default it looks for `.spec.lua` or `.test.lua` files inside of `__tests__` folders, as well as any files with a suffix of `.test.lua` or `.spec.lua` (e.g. `Component.test.lua` or `Component.spec.lua`). It will also find files called `test.lua` or `spec.lua`.

See the [micromatch](https://github.com/micromatch/micromatch) package for details of the patterns you can specify.

See also [`testRegex` [string | array&lt;string&gt;]](#testregex-string--arraystring), but note that you cannot specify both options.

:::tip

Each glob pattern is applied in the order they are specified in the config. For example `{"!**/__fixtures__/**", "**/__tests__/**/*.spec"}` will not exclude `__fixtures__` because the negation is overwritten with the second pattern. In order to make the negated glob work in this example it has to come after `**/__tests__/**/*.spec`.

:::

### `testPathIgnorePatterns` \[array&lt;string&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#testpathignorepatterns-arraystring)  ![Aligned](/img/aligned.svg)

Default: `{}`

An array of regexp pattern strings that are matched against all test paths before executing the test. If the test path matches any of the patterns, it will be skipped.

<!-- These pattern strings match against the full path. Use the `<rootDir>` string token to include the path to your project's root directory to prevent it from accidentally ignoring all of your files in different environments that may have different root directories. Example: `["<rootDir>/build/", "<rootDir>/node_modules/"]`. -->

### `testRegex` \[string | array&lt;string&gt;]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#testregex-string--arraystring)  ![Aligned](/img/aligned.svg)

Default: `{}`

The pattern or patterns Jest Roblox uses to detect test files. See also [`testMatch` [array&lt;string&gt;]](#testmatch-arraystring), but note that you cannot specify both options.

:::info

`testRegex` will try to detect test files using the **absolute file path**, therefore, having a folder with a name that matches it will run all the files as tests.

:::

### `testTimeout` \[number]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#testtimeout-number)  ![Aligned](/img/aligned.svg)

Default: `5000`

Default timeout of a test in milliseconds.

### `verbose` \[boolean]
[![Jest](/img/jestjs.svg)](https://jest-archive-august-2023.netlify.app/docs/27.x/configuration#verbose-boolean)  ![Aligned](/img/aligned.svg)

Default: `false`

Indicates whether each individual test should be reported during the run. All errors will also still be shown on the bottom after execution. Note that if there is only one test file being run it will default to `true`.
