#!/bin/bash

echo db_postgres module delete...

cd ../../../
rm lib/so/luasql/postgres.so
cd lib/dll
rm libeay32.dll
rm libiconv-2.dll
rm libintl-8.dll
rm libmysql.dll
rm libpq.dll
rm luasql.dll
rm ssleay32.dll