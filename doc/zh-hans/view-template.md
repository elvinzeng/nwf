## Hello World
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

-- http://localhost:8099/demo/sayHello
function demoController.sayHello(ctx)
	return "test", {message = "Hello, Elvin!"};
end
```
www/view/test.html
```html
<!DOCTYPE html>
<html>
<body>
  <h1>{{message}}</h1>
</body>
</html>
```
output
```html
<!DOCTYPE html>
<html>
<body>
  <h1>Hello, Elvin!</h1>
</body>
</html>
```
## Template Syntax

You may use the following tags in templates:

* `{{expression}}`, writes result of expression - html escaped
* `{*expression*}`, writes result of expression 
* `{% lua code %}`, executes Lua code
* `{(template)}`, includes `template` file, you may also supply context for include file `{(file.html, { message = "Hello, World" } )}`
* `{[expression]}`, includes `expression` file (the result of expression), you may also supply context for include file `{["file.html", { message = "Hello, World" } ]}`
* `{-block-}...{-block-}`, wraps inside of a `{-block-}` to a value stored in a `blocks` table with a key `block` (in this case), see [using blocks](https://github.com/bungle/lua-resty-template#using-blocks). Don't use predefined block names `verbatim` and `raw`.
* `{-verbatim-}...{-verbatim-}` and `{-raw-}...{-raw-}` are predefined blocks whose inside is not processed by the `lua-resty-template` but the content is outputted as is.
* `{# comments #}` everything between `{#` and `#}` is considered to be commented out (i.e. not outputted or executed)

From templates you may access everything in `context` table, and everything in `template` table. In templates you can also access `context` and `template` by prefixing keys.

```html
<h1>{{message}}</h1> == <h1>{{context.message}}</h1>
```

##### Short Escaping Syntax

If you don't want a particular template tag to be processed you may escape the starting tag with backslash `\`:

```html
<h1>\{{message}}</h1>
```

This will output (instead of evaluating the message):

```html
<h1>{{message}}</h1>
```

If you want to add backslash char just before template tag, you need to escape that as well:

```html
<h1>\\{{message}}</h1>
```

This will output:

```html
<h1>\[message-variables-content-here]</h1>
```

##### A Word About HTML Escaping

Only strings are escaped, functions are called without arguments (recursively) and results are returned as is, other types are `tostring`ified. `nil`s will be convert to empty strings `""`.

Escaped HTML characters:

* `&` becomes `&amp;`
* `<` becomes `&lt;`
* `>` becomes `&gt;`
* `"` becomes `&quot;`
* `'` becomes `&#39;`
* `/` becomes `&#47;`

#### Example
##### Lua
```lua
return "view.html", {
  title   = "test title",
  message = "Hello, World!",
  names   = { "Elvin", "Links", "God" },
  jquery  = '<script src="static/js/jquery.min.js"></script>' 
}
```

##### view.html
```html
{(header.html)}
<h1>{{message}}</h1>
<ul>
{% for _, name in ipairs(names) do %}
    <li>{{name}}</li>
{% end %}
</ul>
{(footer.html)}
```

##### header.html
```html
<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
  {*jquery*}
</head>
<body>
```

##### footer.html
```html
</body>
</html>
```

#### Reserved Context Keys and Remarks

It is adviced that you do not use these keys in your model tables:

* `___`, holds the compiled template, if set you need to use `{{context.___}}`
* `context`, holds the current context, if set you need to use `{{context.context}}`
* `include`, holds the include helper function, if set you need to use `{{context.include}}`
* `layout`, holds the layout by which the view will be decorated, if set you need to use `{{context.layout}}`
* `blocks`, holds the blocks, if set you need to use `{{context.blocks}}` (see: [using blocks](#using-blocks))
* `template`, holds the template table, if set you need to use `{{context.template}}`
* `render`, the function that renders a view, obviously ;-)

You should also not `{(view.html)}` recursively:

##### Lua
```lua
return "view.html"
```

##### view.html
```html
{(view.html)}
```

You can load templates from "sub-directories" as well with `{(syntax)}`:

##### view.html
```html
{(users/list.html)}
```
## details
All template syntax is resty-template view syntax, you can find more details at [resty-template document](https://github.com/bungle/lua-resty-template/blob/master/README.md).