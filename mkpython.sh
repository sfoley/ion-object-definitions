#!/bin/bash

echo "Compile .proto classes to python"
protofiles=`find net -name \*.proto`

for f in $protofiles; do 
    protoc --python_out=python $f;
    if [ $? -ne 0 ]
    then
        echo 'failed to compile...exiting'
        exit 1
    fi
done

echo "Add '__init__.py' files to directories"
dirs=`find python/net -type d`
for d in $dirs; do
    pushd $d > /dev/null

    # Wipe the last build
    rm __init__.py >& /dev/null
    touch __init__.py

    popd > /dev/null
done

# Store a list of all proto packages
echo "Store a list of the proto packages"
pkglist=""
pushd python/net > /dev/null
protopkgs=`find . -name \*_pb2.py | sed 's#^\./\(.*_pb2\)\.py$#\1#' | sed 's#/#.#g'`
for pkg in $protopkgs; do
    pkglist="$pkglist
    , '$pkg'"
done
echo "protos = [
      ${pkglist:7}
]" >> __init__.py
popd > /dev/null

#pushd python
#python setup.py sdist
#cp dist/* ../dist

