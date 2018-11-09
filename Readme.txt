


文件说明：

all_files里写入补丁修改的文件相对路径。参照本文件夹的all_files文件。注意需要linux文件格式。不能有windows的回车换行。
irips_inc_path.p_a是QAC检证时的需要的一个文件的模板，不需要改动，和src_helper.sh放在同级目录。
example.patch是个示例的补丁文件，实际使用时，替换为本次代码修正使用的补丁。
src_helper.sh是工具脚本。



使用说明：

这四个文件放在linux server上，代码路径下（比如LATEST文件夹）

  执行./src_helper backup （生成.orig文件）
  执行./src_helper patch <patch name> (打补丁)
  执行./src_helper diff (生成.diff文件)
  执行./src_helper file (把需要review的代码，取出打包)

  执行./src_helper copyfile (生成QAC检测需要的CopyFile.tar.gz压缩包)
  放在个人目录的QAC文件夹下面。
  
