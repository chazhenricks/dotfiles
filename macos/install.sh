if test ! "$(uname)" = "Darwin"
  then
  exit 0
fi

echo "running software update"
sudo softwareupdate -i -a
echo "finished checking for updates"

echo "setting defaults"
/bin/bash ./set-defaults.sh
echo "done setting defaults"
