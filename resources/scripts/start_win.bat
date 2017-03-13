@echo off
rem run in development mode
rem npl -d bootstrapper="www/webapp.lua" port="8099" root="www/"  dev="%~dp0" servermode="true"
npls -d bootstrapper="www/webapp.lua" dev="%~dp0"

