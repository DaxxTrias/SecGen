#!/bin/zsh
SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | cut -c 1-8`
    cat program.c.template | sed s/AAAAAA/0x$AA/ >! program.c
    gcc -std=gnu99 -Wl,-z,norelro -mno-align-double -o obj/$USER/$BINNAME program.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi

