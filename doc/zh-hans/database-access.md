# 针对postgres的数据库访问层
## 安装模块  
* sh nwf_module_manage.sh -a 列出可用的module
* sh nwf_module_manage.sh -i db_postgres
## 配置
在webserver.config.xml中配置连接postgres数据库的参数
```xml
<config>
    <table name='db'>
      <string name='host'>127.0.0.1</string>
      <string name='user_name'>postgres</string>
      <string name='user_password'>123456</string>
      <string name='database'>test</string>
      <string name='port'>5432</string>
    </table>  
  </config>
```
## 创建Mapper  
为每个表创建mapper.lua文件,比如grade表对应GradeMapper.lua  
```lua
local gradeMapper = commonlib.inherit(nwf.modules.db_postgres.mapper, commonlib.gettable("mapper.gradeMapper"));
```
## 生成SQL脚本
可以使用sqlGenerator生成一些简单的脚本,在生成INSERT或者UPDATE语句之前,需要在对应mapper中创建与数据库表映射的实体, 
主要用于插入value和set value的时候使用,类似下面的写法
```lua
gradeMapper.entity = {
	tbName = "grade",
	fields = {
		grade_id = {prop = "gradeId", notNil = true, isPrimaryKey = true},
		grade_name = {prop = "gradeName", notNil = true}
	}
}
```
then
```lua
local tb = {gradeId="nextval('grade_id_seq')",gradeName="高一"};
local entity = commonlib.gettable("mapper.gradeMapper").entity;
local sqlGenerator = commonlib.gettable("nwf.modules.db_postgres.sqlGenerator");

local sql = sqlGenerator:insert(entity)
			:value(tb)
			:get();
--更新的时候会忽略tb中的id,即不更新id
sql = sqlGenerator:update(entity)
		  :value(tb)
		  :where("id =",tb.id)
		  :_and(nil,"create_time = now()")
		  :_or("name = ","xxx","yyy")
		  :get();

sql = sqlGenerator:select(" s.name , s.age ")
		  :append("FROM student s LEFT JOIN class c ON c.id = s.id")
		  :where(nil,"create_time = now()")
                  :_and("name = ?","'zhangsan'")
		  :get();
```  
其中where(field, value),一般情况下field传入条件的字段和比较符,比如 "id =","name LIKE",value为比较的值,方法内部会根据类型判断是否添加单引号,如果field中包含`?`,value将直接替换`?`,如果value为nil,这条语句将不会被追加进sql,某些特殊情况不希望对value做处理,或者有一些复杂的子句想要拼上去的可以将field设为nil,value会直接被拼接上sql。_and 和 _or 方法同理。
##  使用 DbTemplete
```lua
local dbTemplate = commonlib.gettable("nwf.modules.db_postgres.dbTemplate");
```
### 基本用法
```lua
local res = dbTemplate.execute(sql)
dbTemplate.executeWithTransaction(sql1,sql2,...)
```  
res 为游标对象或者更新的行数  

### 执行sql，同时控制连接对象的释放
```lua
dbTemplate.executeWithReleaseCtrl(sql, conn, release ,openTransaction)

local openTransaction = true
local res, conn = dbTemplate.executeWithReleaseCtrl(sql1, nil, false, openTransaction)
dbTemplate.executeWithReleaseCtrl(sql2, conn, false, openTransaction)
...
--在执行最后一条sql脚本的时候 设置release = true
dbTemplate.executeWithReleaseCtrl(sqlN, conn, true, openTransaction)
```  
### 查询  
查询之前,需要在表对应mapper中编写相应的结果集映射关系
```lua
gradeMapper.selectGrade = {
	primaryKey = "grade_id", 				--primaryKey 必填
	grade_id = {prop = "gradeId", type = "field"},		--key 为sql语句查出来的字段名，value 中的prop属性表示的是将查询结果映射到table中相对应的值
	grade_name = {prop = "gradeName", type = "field"}	--prop相当于别名，主要解决postgres查出来的字段全部为小写的问题
};
```  
然后调用dbTemplate中提供的方法  
```lua
-- 1.使用execute系列的方法  
local cursor = dpTemplate.execute(sql);
for row in function() return cursor:fetch({}, "a"); end do
	--doSomthing...
end

-- 2.使用query系列方法 
local res = dpTemplate:queryFirst(sql);
local list = dpTemplate:queryList(sql);
```
### 关联查询
mapper编写关联映射,这里要注意顺序  
```lua
gradeMapper.studentListForClass = {
	primaryKey = "student_id",
	student_id = {prop = "studentId", type = "field"},
	student_name = {prop = "studentName", type = "field"}
};

gradeMapper.testObjForClass = {
	primaryKey = "test_id",
	test_id = { prop = "testId", type = "field"},
	test_name = { prop = "testName", type = "field"}
}

gradeMapper.classListForGrade = {
	primaryKey = "class_id",
	class_id = { prop = "classId", type = "field"},
	class_name = { prop = "className", type = "field"},
	student = { mapper = gradeMapper.studentListForClass, type = "list"},   --type="list" 表示一对多	
	test = { mapper = gradeMapper.testObjForClass, type = "obj"}		--type="obj" 表示一对一
};

gradeMapper.selectGrade = {
	primaryKey = "grade_id", 					--primaryKey 必填
	grade_id = {prop = "gradeId", type = "field"},			--key 为sql语句查出来的字段名，value 中的prop属性表示的是将查询结果映射到table中相对应的值
	grade_name = {prop = "gradeName", type = "field"}		--prop相当于别名，主要解决postgres查出来的字段全部为小写的问题
	class = {mapper = gradeMapper.classListForGrade, type = "list"} 
};
```  
编写sql语句需要遵循以下规范
* 关联表查询的字段名不能相同
* 必须查询每个表的主键
```lua
local sql = sqlGenerator:select([[
				g.grade_id,
				g.grade_name,
				c.class_id,
				c.class_name,
				s.student_id,
				s.student_name,
				t.test_id,
                        	t.test_name]])
			:append([[
				FROM grade g
				LEFT JOIN class c ON g.grade_id = c.grade_id
				LEFT JOIN student s ON c.class_id = s.class_id
				LEFT JOIN test t ON c.class_id = t.class_id
			]])
			:get();
```  
最后
```lua
local mapper = commonlib.gettable("mapper.gradeMapper");
mapper:setResMapper(mapper.selectGrade);
local res = dbTemplate:queryFirst(sql,  mapper);
```

### 分页查询
#### Tips
* `countSql` 不能为nil, `pageIndex` 和 `pageSize` 必须大于0
* sql的分页子句: `LIMIT %d OFFSET %d`
```lua	
local sql = sqlGenerator:select([[
				g.grade_id,
				g.grade_name,
				c.class_id,
				c.class_name,
				s.student_id,
				s.student_name,
				t.test_id,
                        	t.test_name]])
			:append([[
				FROM (SELECT grade_id, grade_name FROM grade LIMIT %d OFFSET %d) g 
				LEFT JOIN class c ON g.grade_id = c.grade_id
				LEFT JOIN student s ON c.class_id = s.class_id
				LEFT JOIN test t ON c.class_id = t.class_id
			]])
			:get();
local data = dbTemplate:queryList(sql, mapper, " select count(1) from grade ", 1, 3);
```

