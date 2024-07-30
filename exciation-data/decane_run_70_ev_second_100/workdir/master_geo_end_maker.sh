home_path=$(pwd)

rm master_geo_end.gen
touch master_geo_end.gen
mkdir geo_end_xyz_dir
for dir in sim*
do
cd $dir
echo $dir
#cd continuation_run || pwd
#echo $(pwd) >> $home_path/master_geo_end.gen
cp geo_end.xyz "$home_path/geo_end_xyz_dir/geo_end_$dir.xyz"
#cat geo_end.gen >> $home_path/master_geo_end.gen
cd $home_path
done

