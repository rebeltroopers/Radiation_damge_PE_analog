home_dir=$(pwd)
num_sim=100
start_value=1
len_x=0.1532620600E+02
for j in $(seq $start_value $num_sim);
do
echo $j
cd "sim.$j"
#cp ../bonds.dat .
#~/bin/./molanal.new full_geo_end.gen > bonds.out
#perl ~/bin/findmolecules.pl bonds.out > final_bonds.out
#python3 "/usr/workspace/troup1/second_set/python_scripts/bond_check.py"
#python3 "/usr/workspace/troup1/second_set/python_scripts/bond_count.py" > error_check.txt

#bash stuff
grep 'Total E' output.txt | awk '{print($5)}' > energy_file.txt
grep 'Total MD' output.txt | awk '{print($6)}' > total_energy_file.txt
#grep 'MD T' output.txt | awk '{print($5)}' > temperature_file.txt

#simulation stuff
#python3 "/usr/workspace/troup1/second_set/python_scripts/molecule_group.py" > test.txt

#mkdir molanal_files
#cd molanal_files
#cp ../geo_end.xyz .
#python3 "/usr/workspace/troup1/second_set/python_scripts/gen_maker.py"  full_geo_end.gen > useless.txt

#cp ../../bonds.dat .
#cp ../../findmolecules.cfg .
#~/bin/./molanal.new full_geo_end.gen > bonds.out
#perl ~/bin/findmolecules.pl bonds.out > final_bonds.out
#rm geo_end.xyz

cd $home_dir

done

#now for gathering simultion information first round just the simulation amount contains everything
#target_find='COM Coordinates for frame 10001:\n'
#python3 "/usr/workspace/troup1/second_set/python_scripts/molecule_group.py"  > chemical_information.txt

