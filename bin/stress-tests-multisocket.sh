#!/bin/bash

CORES_PER_CPU=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
PAIRS_OF_CORES=$CORES_PER_CPU # The are 2 CPUs with CORES_PER_CPU cores each

# Start tests
START=$(date +%s%N)

sleep 30 # Initial wait

#run_experiment <NAME> <CORES_PER_CPU> <TOTAL_PAIRS> <PAIR_OFFSET> <INCREMENT> <CPU_SWITCH>
################################################################################################
# Group_P: First CPU0 physical cores, then CPU1 physical cores
################################################################################################
TIMESTAMPS_FILE=${LOG_DIR}/Group_P.timestamps
run_experiment "Group_P" $CORES_PER_CPU $PAIRS_OF_CORES 1 2 0 "stress_cpu"

################################################################################################
# Spread_P: Switching CPU cores, 2 cores from CPU0, then 2 cores from CPU1, then 2 from CPU0...
################################################################################################
TIMESTAMPS_FILE=${LOG_DIR}/Spread_P.timestamps
run_experiment "Spread_P" $CORES_PER_CPU $PAIRS_OF_CORES 1 2 1 "stress_cpu"

################################################################################################
# Group_P&L: Load by pairs of physical and logical cores, first CPU0, then CPU1.
################################################################################################
TIMESTAMPS_FILE=${LOG_DIR}/Group_P_and_L.timestamps
run_experiment "Group_P&L" $CORES_PER_CPU $(($PAIRS_OF_CORES * 2)) $((CORES_PER_CPU * 2)) 1 0 "stress_cpu"

################################################################################################
# Group_1P_2L: First physical cores, then logical cores. First load CPU0 until all physical and 
# logical cores are loaded at 100%, then do the same with CPU1.
################################################################################################
TIMESTAMPS_FILE=${LOG_DIR}/Group_1P_2L.timestamps
run_experiment "Group_1P_2L" $CORES_PER_CPU $(($PAIRS_OF_CORES * 2)) 1 2 $(($CORES_PER_CPU / 2)) "stress_cpu"

################################################################################################
# Spread_P&L: Load by pairs switching CPUs. One pair (physical core + logical core) from CPU0, 
# then from CPU1, then from CPU0...
################################################################################################
TIMESTAMPS_FILE=${LOG_DIR}/Spread_P_and_L.timestamps
run_experiment "Spread_P&L" $CORES_PER_CPU $(($PAIRS_OF_CORES * 2)) $(($CORES_PER_CPU * 2)) 1 1 "stress_cpu"

################################################################################################
END=$(date +%s%N)
NAME="TOTAL"
print_time START END