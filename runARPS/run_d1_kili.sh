#!/bin/bash 
# author Chris Reudenbach (2015)
# version 2015/05/31
# script to setup an arbitrary ARPS run using GFS boundary data

# executing shell scripts using . ./ will execute it in the current shell without forking a sub shell.

if [[ "$1" == '-h' ]]; then
    echo ""
    echo " Usage:	d1_kili.sh -h |  <sim type> <date-type> <YYYY-MM-DD> "
    echo ""
    echo "<sim type> :  pre     preprocessing of the whole dataset"
    echo "              sim     simulate an already preprocessed case study"
    echo "              presim  preprocessing and simulate the whole dataset (recommended)"
    echo ""
    echo "<date-type> : true    taking actual date from the system (forecast mode)"
    echo "              false   providing individual date"
    echo ""
    echo "<YYYY-MM-DD>  date (optional if <date-type>=false):      "
    echo "              date to start simulation (i.e. '2015-05-31')"    
    echo ""
    echo "example 1:~/arpsinput/d1/src/./run_d1_kili.sh presim true '' | tee ~/run_d1.log "
    echo "          starts a forecast run (pre&sim) with the current time "
    echo "          and logs the messages additionally ~/run_d1.log"
    echo " "
    echo "example 2:~/arpsinput/d1/src/./run_d1_kili.sh presim false '2015-05-03'"
    echo "          starts a preprocessing and analysis run for the 2015-05-03"
    echo " "
    echo "example 3:~/arpsinput/d1/src/./run_d1_kili.sh pre false '2015-05-03'"
    echo "          starts a data preprossing for the 2015-05-03"
    echo "NOTE      The general workflow is as follows: "
    echo "           1) Make a copy of the KILI_D1_01.sh setup file and adapt it"
    echo "           2) If necessary adapt the correaponding input templates"
    echo "           3) Make copy of this file and adapt it"
    echo "           4) Start simulation/preprossing as described above"    
    exit 0
elif [ "$#" -ne 3 ]; then
    echo "Usage: d1_kili.sh -h brief help <sim type> <date-type> <YYYY-MM-DD> "
    echo " "
    exit 0
fi

# source the .bashrc file for the env variables
source $HOME/.bashrc 

# source the simulation specific setup file


# execution part

if [[ $1 ==  presim ]] ; then #preprocessing and simulate
	# calculate date
	~/arpsinput/d1/src/datum.sh         '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' $2 $3 

	# preprocess boundary and setup data
	~/arpsinput/d1/src/pre_run.sh       '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' true

	# run simulation
	nohup ~/arpsinput/d1/src/run_sim.sh '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' & 

elif [[ $1 ==  pre ]] ; then #preprocessing only
	# calculate date
	~/arpsinput/d1/src/./datum.sh         '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' $2 $3 

	# preprocess boundary and setup data
	~/arpsinput/d1/src/pre_run.sh       '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' true

elif [[ $1 ==  sim ]] ; then # simulation run only
	# run simulation
	nohup ~/arpsinput/d1/src/run_sim.sh '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' & 
fi
