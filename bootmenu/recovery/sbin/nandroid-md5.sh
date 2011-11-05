#!/sbin/sh

cd $1
rm -f /tmp/nandroid.md5

if [ -n "$2" ] ; then
  find -name "$2*" -exec md5sum {} \; > /tmp/nandroid.md5
  cat /tmp/nandroid.md5 >> ./nandroid.md5
else
  md5sum * .* | grep -v "md5" > /tmp/nandroid.md5
  cp /tmp/nandroid.md5 .
fi

# need this because wildcard seems to cause md5sum to return 1
if [ -f nandroid.md5 ]
then
  return 0
else
  return 1
fi
