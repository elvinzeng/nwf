# Database Access For Postgres
## Install Module  
* sh nwf_module_manage.sh -a               ##list available module  
* sh nwf_module_manage.sh -i db_postgres   ## install
## Config
Configure your db connection parameters in webserver.config.xml
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
## Create Mapper  
Create `mapper.lua` for each table, like table `grade` to `GradeMapper.lua`
```lua
local gradeMapper = commonlib.inherit(nwf.db.mapper, commonlib.gettable("mapper.gradeMapper"));
```

## Generate SQL
You can use sqlGenerator to create some simple sql script.
Before you create `INSERT` or `UPDATE` sql,you need to create a lua file for db entity in `mapper.lua` like this  
```lua
gradeMapper.entity = {
	tbName = "grade",
	fields = {
		grade_id = {prop = "gradeId", notNil = true, isPrimaryKey = true},
		grade_name = {prop = "gradeName", notNil = true}
	}
```
then
```lua
local tb = {gradeId="nextval('grade_id_seq')",gradeName="高一"};
local entity = commonlib.gettable("mapper.gradeMapper").entity;
local sqlGenerator = commonlib.gettable("nwf.db.sqlGenerator");
	
local sql = sqlGenerator:insert(entity)
			:value(tb)
			:get();
--update will ignore to set id with new value
sql = sqlGenerator:update(entity)
		  :value(tb)
		  :where("id = ",tb.id)
		  :_and(nil,"create_time = now()")
		  :get();

sql = sqlGenerator:select(" s.name , s.age ")
		  :append("FROM student s LEFT JOIN class c ON c.id = s.id")
		  :where(nil,"create_time = now()")
		  :get();
```  


##  Use DbTemplete
```lua
local dbTemplate = commonlib.gettable("nwf.db.dbTemplate");
```
### Basic Usage
```lua
local res = dbTemplate.execute(sql)
dbTemplate.executeWithTransaction(sql1,sql2,...)
```
res is a cursor object or the count of update rows

### Release Control For Connection Object
```lua
dbTemplate.executeWithReleaseCtrl(sql, conn, release ,openTransaction)

local openTransaction = true
local res, conn = dbTemplate.executeWithReleaseCtrl(sql1, nil, false, openTransaction)
dbTemplate.executeWithReleaseCtrl(sql2, conn, false, openTransaction)
...
--release conn until last execute
dbTemplate.executeWithReleaseCtrl(sqlN, conn, true, openTransaction)
```
### Query
Befor query, you need to code the relation between the fields of table and mapper to mapper.lua file
```lua
gradeMapper.selectGrade = {
	primaryKey = "grade_id", 				--primaryKey 
	grade_id = {prop = "gradeId", type = "field"},		--key is fieldName define in sql
	grade_name = {prop = "gradeName", type = "field"}	--prop is same to alias,to solve problem that the Postgres check out the field is lowercase 
};
``` 
then
```lua
-- 1.use execute
local cursor = dpTemplate.execute(sql);
for row in function() return cursor:fetch({}, "a"); end do
	--doSomthing...
end

-- 2.use query 
local res = dpTemplate:queryFirst(sql);
local list = dpTemplate:queryList(sql);
```
### Association
Code association relation to mapper.lua  
```lua
gradeMapper.prefix = "grade";	--main table prefix
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
	student = { mapper = gradeMapper.studentListForClass, type = "list"},   --type="list" means one to many	
	test = { mapper = gradeMapper.testObjForClass, type = "obj"}		--type="obj" means one to one
};

gradeMapper.selectGrade = {
	primaryKey = "grade_id", 					--primaryKey 
	grade_id = {prop = "gradeId", type = "field"},			--key is fieldName define in sql
	grade_name = {prop = "gradeName", type = "field"}		--prop is same to alias,to solve problem that the Postgres check out the field is lowercase 
	class = {mapper = gradeMapper.classListForGrade, type = "list"} 
};
```  
#### Tips
* set alias for field in this format [prefix_alias]
* must query primary key for each table

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
at last
```lua
local mapper = commonlib.gettable("mapper.gradeMapper");
mapper:setResMapper(mapper.selectGrade);
local res = dbTemplate:queryFirst(sql,  mapper);
```
### Pagination
#### Tips
* `countSql` can not be nil, `pageIndex` and `pageSize` must lager than 0
* use `LIMIT %d OFFSET %d` in your sql
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
