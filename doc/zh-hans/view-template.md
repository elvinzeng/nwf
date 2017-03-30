本文来自resty的官方文档，稍作修改然后翻译了一下。如果发现有什么错误或问题，可以给我提个issue。
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
## 视图模板的语法

你可以在模板中使用以下标签:

* `{{expression}}`, 输出指定表达式的值到占位符所在位置，该标签会自动对表达式的值进行html编码。
* `{*expression*}`, 输出指定表达式的值到占位符所在位置
* `{% lua code %}`, 执行lua脚本
* `{(template)}`, 包含另一个页面, 你还可以给这个页面提供一个模型table，像这样 `{(file.html, { message = "Hello, World" } )}`
* `{[expression]}`, 包含另一个页面，被包含的页面为表达式expression的值所指示的页面, 你还可以给这个页面提供一个模型table，像这样 `{(file.html, { message = "Hello, World" } )}`
* `{-block-}...{-block-}`, wraps inside of a `{-block-}` to a value stored in a `blocks` table with a key `block` (in this case), see [using blocks](https://github.com/bungle/lua-resty-template#using-blocks). Don't use predefined block names `verbatim` and `raw`.
* `{-verbatim-}...{-verbatim-}` and `{-raw-}...{-raw-}` 包含在内的代码将会直接被输出
* `{# comments #}` 注释，所有被放在 `{#` and `#}` 标签中的内容将被视为注释，并且不会输出。

在模板中，你可以直接访问模型对象中的任何属性，也可以加上context前缀。

```html
<h1>{{message}}</h1> == <h1>{{context.message}}</h1>
```

##### 输出标签文本

如果你想输出类似标签的文本，你需要通过一个反斜线来转义。如下：

```html
<h1>\{{message}}</h1>
```

上面的代码会输出下面这样的内容到页面上

```html
<h1>{{message}}</h1>
```

如果你想输出反斜线，则需要用两个反斜线。

```html
<h1>\\{{message}}</h1>
```

上面的代码将会输出下面这样的标记到页面中

```html
<h1>\[message-variables-content-here]</h1>
```

##### 实体编码

所有的字符串都有被编码，函数则会被不带任何参数的直接调用然后取返回值。其他类型则会被tostring。如果值为nil则会输出空字符串。  
会被编码的特殊字符

* `&` becomes `&amp;`
* `<` becomes `&lt;`
* `>` becomes `&gt;`
* `"` becomes `&quot;`
* `'` becomes `&#39;`
* `/` becomes `&#47;`

#### 例子
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

#### 被保留的关键字

强烈建议不要在你的模型对象中使用以下属性名，这些属性名为保留的名称，如果模型中定义了这些东西，容易与框架内部的一些对象相互覆盖。

* `___`, holds the compiled template, if set you need to use `{{context.___}}`
* `context`, holds the current context, if set you need to use `{{context.context}}`
* `include`, holds the include helper function, if set you need to use `{{context.include}}`
* `layout`, holds the layout by which the view will be decorated, if set you need to use `{{context.layout}}`
* `blocks`, holds the blocks, if set you need to use `{{context.blocks}}` (see: [using blocks](#using-blocks))
* `template`, holds the template table, if set you need to use `{{context.template}}`
* `render`, the function that renders a view, obviously ;-)

另外，注意不要递归包含视图本身 `{(view.html)}`，像这样:

##### Lua
```lua
return "view.html"
```

##### view.html
```html
{(view.html)}
```

你也可以包含子目录下的视图文件:

##### view.html
```html
{(users/list.html)}
```
## 其他
通常情况下，上面介绍的这些语法已经够用了。如果想了解更详细的语法，可以参考 [resty-template document](https://github.com/bungle/lua-resty-template/blob/master/README.md)
