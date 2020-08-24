[ $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR ] || export CMDLINE_COMP_GEN_ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cmdline_comp_gen.zsh"
if [[ ! -e $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR ]]; then
    mkdir -p $CMDLINE_COMP_GEN_ZSH_CONFIG_DIR
fi
[ $CMDLINE_COMP_GEN_ZSH_CACHE_DIR ] || export CMDLINE_COMP_GEN_ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cmdline_comp_gen.zsh"
if [[ ! -e $CMDLINE_COMP_GEN_ZSH_CACHE_DIR ]]; then
    mkdir -p $CMDLINE_COMP_GEN_ZSH_CACHE_DIR
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
    local output_file=$CMDLINE_COMP_GEN_ZSH_CACHE_DIR/_$command_name
    cat <<EOF > $output_file
#compdef $command_name
_$command_name () {
if [[ -e \$CMDLINE_COMP_GEN_ZSH_CONFIG_DIR/$command_name ]]; then
    local overwride_args=(\$(cat \$CMDLINE_COMP_GEN_ZSH_CONFIG_DIR/$command_name))
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
    if (( $+functions[$function_name] )) ; then
        unfunction _$command_name
    fi
    autoload -Uz +X _$command_name
    compinit
}

fpath=($CMDLINE_COMP_GEN_ZSH_CACHE_DIR $fpath)
