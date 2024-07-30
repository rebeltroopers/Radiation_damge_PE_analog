home_path=$(pwd)

rm master_geo_end.gen
touch master_geo_end.gen

for dir in sim*
do
cd $dir
#cd continuation_run || pwd
#echo $(pwd) >> $home_path/master_geo_end.gen
cat geo_end.gen >> $home_path/master_geo_end.gen
cd $home_path
done

