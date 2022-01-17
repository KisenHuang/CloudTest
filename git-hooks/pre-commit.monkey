#!/bin/sh
#author shenbingkai@100tal.com

# git commit时拦截提交的png图片，压缩后添加到暂存区

# 0 -- png质量压缩；
# 1 -- 转webp
MODE=1
BACKUP=.git/_images
SUCC=1

echo "mac pre-commit"

#压缩
function compress(){
	# echo "正在压缩图片 " $1
	#jpeg效果比较明显，png整体一般，应该是无损压缩
	convert -quality 75 $1 $1
	git add $1
}

# 转webp
function webp(){
	# echo "转webp"
	pic_name=$1
	new_name="${pic_name%.*}.webp"
	# convert $pic_name $new_name
	# cwebp $pic_name -o $new_name&>/dev/null
    java -jar libwebp.jar $pic_name $new_name&>/dev/null

	# 检查目标文件是否存在，存在则转码成功，删除源文件
	if [ -e $new_name ]; then
		rm -rf $pic_name
		echo "===webp转换成功==="   $new_name
		git add $pic_name
		git add $new_name
	else
		echo "===webp转换失败,请尝试手动转换==="   $1
		git reset HEAD $pic_name
		SUCC=0
	fi
}

#过滤器
function filter(){
	local file=$1
	local sub_dir=/"${file##*res/}"
	if [[ $sub_dir != *.9.png && ($sub_dir == /drawable* || $sub_dir == /mipmap*) ]]; then
		return 1
	else
		return 0
	fi
}

function run(){
	case $MODE in
		0)
		compress $1
			;;
		1)
		webp $1
			;;
		*)
		echo "unknow MODE"
		exit 1
			;;
	esac
}

# 获取提交的json配置文件
JSON_FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.json')
if test ${#JSON_FILES} -gt 0
then
	for FILE in $JSON_FILES
	do
		echo FILE
	done
	if [[ $SUCC == 0 ]]; then
		exit 1
	fi
fi

