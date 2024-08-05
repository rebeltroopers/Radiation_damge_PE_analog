0.
Only works with python2 so that will need to be setup first.


1. setup_analysis_components.sh

Make sure to set user inputs at top of script. 

If frameperjob < total number of frames, this will
create mulitple workers to identify connected components. 

__________________________

2. run individual workers or submit_analysis_components.sh 

Identifies connected components. 

If there is only a single worker, it makes more sense to go
to dir.components.work/worker.1 and execute the following

./run_analysis_components.sh 

___________________________

3. collect_descriptors.sh 

Run this after all individual worker jobs are done.

Make sure to set user inputs at top of script. 

Will process all connected components identified in
previous step and compute descriptors for these components.
This does not work with graphs, as those are quite expensive
and liable to make the isomorphism check hang. 

This uses desciptors that are like those in molanal, but better. 

Molanal uses as a descriptor a molecule's atom and bond count
For Instance: D = (Na Nb Na-a Nb-b Na-b)

This code also enumerates unique angle types and considers those too. 
For Instance: D = (Na Nb Na-a Nb-b Na-b Na-a-a Na-a-b N-a-b-a ... )

___________________________

4. final_cleanup.sh

This does some final analysis and identifies reaction states,
or combinations of structures. Each frame is in a reaction state of
a particular type, which is indexed automatically. 

Two files of interest in "outputs"

rxnstates.txt: This gives the reaction state of each frame, along 
               with the component IDs that comprise it. These IDs
               follow the numbering scheme in lib.structures/configs


unique.rxnstates.txt: Similar to above, but only the unique states are listed	      

___________________________

5. sort_library.sh 

Applies an optional sort on the identified structures to put them in order
of increasing mass, which is useful for finding small products. 

Generates a mapping in "sort_output.txt" between the auto-generated
structure type indexing (in second column) and a mass-ordered list.

Also makes a complementary directory in outputs/lib.structures/sorted_configs
for easy visualization of the mass-ordered set of products. 
