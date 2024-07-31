Data is split into multiple directories, where eV energy is in the label. The data inside these directories will be enough to recreate the dataset from scratch.

Each directory contains the following information:

    1) Information about the initial setup and scripts.
    2) work.dir directories where excited frames were set up.
    3) Each work.dir directory contains simulation numbers and has information on each excited frame: the picked atom, geo_end.gen (final frame after excitation), dftb_in.hsd and dftb_in_pin.hsd (files that can be used to run the simulations), system.gen (input positions), and md.out (thermal energy of the system for a whole trajectory).

These contain the last frame and overall data for each simulation excitation without the intermediate frames due to being too large. They can be rerun if you use 8 threads for about 7 days if you wish to recreate the data.
