[ $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR ] || export CMDLINE_COMP_GEN_ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cmdline_comp_gen.zsh"
if [[ ! -e $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR ]]; then
    mkdir -p $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR
fi
[ $CMDLINE_COMP_GEN_ZSH_CACHE_DIR ] || export CMDLINE_COMP_GEN_ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cmdline_comp_gen.zsh"
if [[ ! -e $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/raw ]]; then
    mkdir -p $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/raw
fi

function __cmdline_comp_gen::getCompsyncArg () {
    option=$1
    desc=${@:2}
    desc=${desc:gs/"'"/}
    desc=${desc:gs/[/\\[}
    desc=${desc:gs/]/\\]}
    if [[ $desc ]]; then
        echo "'"$option'['$desc']'"' \\"
    else
        echo "'"$option"' \\"
    fi
}

function cmdline_comp_gen () {
    local command_name=$(basename $1)
    local output_file=$CMDLINE_COMP_GEN_ZSH_CACHE_DIR/raw/$command_name.zsh
    cat <<EOF > $output_file
compdef __cmdline_comp_gen::comp::$command_name $command_name
function __cmdline_comp_gen::comp::$command_name () {
if [[ -e \$CMDLINE_COMP_GEN_ZSH_CONFIG_DIR/$command_name ]]; then
    overwride_args=(\$(cat \$CMDLINE_COMP_GEN_ZSH_CONFIG_DIR/$command_name))
fi
_arguments : \$overwride_args \\
'*:argument:_files' \\
EOF
    $1 --help |& while read -r message; do
        if [[ "$message" =~ "^ *options:$" ]] || [[ "$message" =~ "^ *usage:.*$" ]]; then
            continue
        fi
        arr=($=message)
        if [[ $arr[1] =~ ",$" ]]; then
            __cmdline_comp_gen::getCompsyncArg ${arr[1]%,} ${arr:3} >> $output_file
            __cmdline_comp_gen::getCompsyncArg $arr[2] ${arr:3} >> $output_file
        else
            __cmdline_comp_gen::getCompsyncArg $arr[1] ${arr:2} >> $output_file
        fi
    done
    cat <<EOF >> $output_file

}
EOF
    echo '' > $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/cached_commands.zsh
    for file ($CMDLINE_COMP_GEN_ZSH_CACHE_DIR/raw/*) cat $file >> $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/cached_commands.zsh
    source $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/cached_commands.zsh
}

source $CMDLINE_COMP_GEN_ZSH_CACHE_DIR/cached_commands.zsh
