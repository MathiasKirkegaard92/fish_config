# Set theme
set -g theme_use_abbreviated_branch_name no
set -g fish_prompt_pwd_dir_length 5

# Package manager paths
set -x PATH $PATH /opt/local/bin # macports
set -x PATH $PATH /opt/local/sbin # macports
set -x PATH $PATH $HOME/.local/bin
set -g fish_user_paths "/usr/local/opt/llvm/bin" $fish_user_paths

# # Init pyenev
status --is-interactive; and source (pyenv init -|psub)
pyenv global 3.7.3 # set global python environment

# Esp-idf paths
bass . $HOME/esp/esp-idf/export.sh # exports all esp-idf paths

# Esp-adf path
set -x ADF_PATH $HOME/esp/esp-adf

# export qmake-homebrew path
set -g fish_user_paths "/usr/local/opt/qt/bin" $fish_user_paths
set -x QMAKE_PATH /usr/local/opt/qt/bin

# Export llvm-homebrew path
# set -g fish_user_paths "/usr/local/opt/llvm/bin" $fish_user_paths

function get_rootname
	set rootname (echo $argv[1] | sed 's/\.[^.]*$//')
	echo $rootname
end

function svg2pdf
	if test (count $argv) -lt 1;
		printf "Supply an svg file to proccess"
	else if test (count $argv) -eq 1;
		set root (get_rootname "$argv[1]");
		inkscape --file="$PWD"/"$argv[1]"  --export-area-drawing --without-gui --export-pdf="$PWD"/"$root".pdf --without-gui
	else if test (count $argv) -eq 2;
		inkscape --file="$PWD"/"$argv[1]"  --export-area-drawing --without-gui --export-pdf="$PWD"/"$argv[2]" --without-gui
	end
end

function dsptopdf
	if test (count $argv) -gt 0;
			faust -svg "$PWD"/"$argv[1]";
			set root (get_rootname "$argv[1]");
			mv "$root"-svg/process.svg "$root".svg;
			rm -rf "$root"-svg/
		if test (count $argv) -eq 1;
			svgtopdf "$root".svg
		else if test (count $argv) -eq 2;
			svgtopdf "$root".svg "$argv[2]";
		end
		rm -rf "$root".svg
	end
end

function for_file
	for file in $argv
		echo "entry: $file"
	end
end

function dsp2esp
	set root (get_rootname "$argv[1]"); 
	faust2esp32 -lib -hapticdev  torquetuner -zip -es8388 $argv[1];
	mkdir -p espdir
	mv "$root".zip espdir/"$root".zip # move zip file into espdir/
	unzip -uo espdir/"$root".zip -d espdir/ # unzip on quietly replace into espdir/
	rm -rf "$root".zip # delete zip container 
	idf.py -p "/dev/cu.SLAB_USBtoUART" -C espdir/"$root" build # build, flash	and open serial monitor	
end

function dsp2esp_upload
	set root (get_rootname "$argv[1]"); 
	faust2esp32 -lib -hapticdev  torquetuner -zip -es8388 $argv[1];
	mkdir -p espdir
	mv "$root".zip espdir/"$root".zip # move zip file into espdir/
	unzip -uo espdir/"$root".zip -d espdir/ # unzip on quietly replace into espdir/
	rm -rf "$root".zip # delete zip container 
	idf.py -p "/dev/cu.SLAB_USBtoUART" -C espdir/"$root" flash monitor # build, flash	and open serial monitor	
end


function heic2jpg

	set -l files # empty list
	getopts $argv | while read -l key value
        switch $key
        case f 
        	set folder $value
        	echo $folder
        case \* 
        	set files $files $value
        end
    end

	for file in $files
		set root (get_rootname "$file");
		if  set -q folder 
        	magick convert "$root".HEIC "$folder"/"$root".jpg;
        	echo converting "$root".HEIC to "$folder"/"$root".jpg
        else 
        	magick convert "$root".HEIC "$root".jpg
        	echo converting "$root".HEIC to "$root".jpg;
        end
		
	end
end

function is_file
	if test -e ~/.foobar
	    return 1;
	else 
		return 0;
	end
end

function is_directory
	if test -d ~/.hello
	    return 1;
	else
		return 0;
	end
end

function getopts_test 

	set -l files # empty list
	getopts $argv | while read -l key value
        switch $key
        case b 
        	set folder $value
        case \*
        	set files $files $value
        end
    end
	if set -q folder 
        	echo "folder: $folder"
    end
        for x in $files
        	echo "file: $x	 "
    end
end


