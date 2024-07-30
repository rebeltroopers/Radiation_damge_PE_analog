
rm carbon_master_list.txt
touch carbon_master_list.txt
home=$(pwd)
for item in sim*
do
cd $item
echo $(pwd) >> ../carbon_master_list.txt
cat picked_atom.txt >> ../carbon_master_list.txt
cd $home

done
