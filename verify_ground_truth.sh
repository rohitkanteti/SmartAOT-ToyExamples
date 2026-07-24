#!/bin/bash

# Define expected outcomes for A.myrun()V in SmartAOT for Example-2 scenarios
declare -A EXPECTED_SMARTAOT_LOADED
EXPECTED_SMARTAOT_LOADED["Escaping-To-Captured"]="false"
EXPECTED_SMARTAOT_LOADED["Captured-To-Escaping"]="false"
EXPECTED_SMARTAOT_LOADED["Escaping-To-Escaping"]="true"
EXPECTED_SMARTAOT_LOADED["Captured-To-Captured"]="true"
EXPECTED_SMARTAOT_LOADED["Captured-To-Captured-FieldMutation"]="true"

SCENARIOS_DIR="Example-2-Scenarios"
ALL_PASSED=true
CHECKED_ANY=false

bash clean_logs.sh > /dev/null 2>&1
bash run_scenarios.sh #> /dev/null 2>&1

for SCENARIO in "Escaping-To-Captured" "Captured-To-Escaping" "Escaping-To-Escaping" "Captured-To-Captured" "Captured-To-Captured-FieldMutation"; do
    DIR="${SCENARIOS_DIR}/${SCENARIO}"
    
    if [ ! -d "$DIR" ] || [ ! -f "$DIR/Baseline_methods_loaded.txt" ]; then
        continue
    fi

    CHECKED_ANY=true
    echo "Scenario: $SCENARIO"
    
    # 1. Baseline should ALWAYS fail to load A.myrun()V, C.bar()I, and C.<init>()V in these tests
    BASELINE_FAILED_ALL=true
    for method in "A.myrun()V" "C.bar()I" "C.<init>()V"; do
        if grep -q "$method" "$DIR/Baseline_methods_loaded.txt" 2>/dev/null; then
            echo "  [FAIL] Baseline incorrectly LOADED $method"
            ALL_PASSED=false
            BASELINE_FAILED_ALL=false
        elif ! grep -q "$method" "$DIR/Baseline_methods_failed.txt" 2>/dev/null; then
            echo "  [FAIL] Baseline didn't report $method as failed either (missing logs?)"
            ALL_PASSED=false
            BASELINE_FAILED_ALL=false
        fi
    done

    if [ "$BASELINE_FAILED_ALL" == "true" ]; then
        echo "  [PASS] Baseline failed to load A.myrun()V, C.bar()I, C.<init>()V (Expected)"
    fi

    # 2. SmartAOT behavior depends on the specific scenario logic
    EXPECTED_LOAD=${EXPECTED_SMARTAOT_LOADED[$SCENARIO]}
    
    IS_LOADED="false"
    if grep -q "A.myrun()V" "$DIR/SmartAOT_methods_loaded.txt" 2>/dev/null; then
        IS_LOADED="true"
    fi
    
    if [ "$EXPECTED_LOAD" == "$IS_LOADED" ]; then
        if [ "$EXPECTED_LOAD" == "true" ]; then
            echo "  [PASS] SmartAOT successfully LOADED A.myrun()V, C.bar()I, C.<init>()V (Expected - Safely Salvaged)"
        else
            echo "  [PASS] SmartAOT correctly DISCARDED A.myrun()V and LOADED C.bar()I, C.<init>()V (Expected - Recompilation Forced)"
        fi
    else
        echo "  [FAIL] SmartAOT loaded A.myrun()V: $IS_LOADED, but expected: $EXPECTED_LOAD"
        ALL_PASSED=false
    fi

    # 3. Check that other independent methods were ALWAYS salvaged by SmartAOT
    if ! grep -q "C.bar()I" "$DIR/SmartAOT_methods_loaded.txt" 2>/dev/null; then
        echo "  [FAIL] SmartAOT failed to load C.bar()I"
        ALL_PASSED=false
    fi
    if ! grep -q "C.<init>()V" "$DIR/SmartAOT_methods_loaded.txt" 2>/dev/null; then
        echo "  [FAIL] SmartAOT failed to load C.<init>()V"
        ALL_PASSED=false
    fi
done

if [ "$CHECKED_ANY" == "false" ]; then
    exit 1
fi

if [ "$ALL_PASSED" == "true" ]; then
    exit 0
else
    exit 1
fi
