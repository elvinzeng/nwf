@echo off
rem run in development mode
rem npl -d bootstrapper="www/webapp.lua" port="8099" root="www/"  dev="%~dp0" servermode="true"
SET cwd=%~dp0
SET PATH=%PATH%;%cwd%lib\dll\;
rem npls -d bootstrapper="www/webapp.lua" dev="%~dp0"
npl servermode="true" bootstrapper="www/webapp.lua" dev="%~dp0"