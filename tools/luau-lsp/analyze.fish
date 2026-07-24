#!/usr/bin/env fish

set script_dir (dirname (status --current-filename))
exec bash "$script_dir/analyze.sh" $argv
