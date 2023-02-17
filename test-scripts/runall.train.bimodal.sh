#!/bin/bash
export PATH=`pwd`/scripts:$PATH # must be run from the root of the train harness with scripts directory
export PIN_ROOT="/projectnb/ec513/students/ffayza/PIN/pin-3.26-98690-g1fc9d60e6-gcc-linux" #CHANGEME to your pin kit directory
export PINTOOL="/projectnb/ec513/students/ffayza/PIN/pintool_bimodal/obj-intel64/branch-predictor.so" #CHANGEME to your built pintool (so file)
export OUT_DIR="/projectnb/ec513/students/ffayza/PIN/results" #CHANGEME to your desired output directory

module load gcc/12.2.0
gcc --version

if  [ ! -e $PIN_ROOT ]; then
	echo "PIN_ROOT ($PIN_ROOT) does not exist"
  exit 1
fi

if  [ ! -e $PINTOOL ]; then
	echo "PINTOOL ($PINTOOL) does not exist"
  exit 1
fi

for b in `specrate.list`
do
  cd $b
  bm=`echo $b | awk -F"." '{print $2}'`
  n=`specratetrain_numinputs.sh $b`  # 'train' used here "specratetrain_numinputs.sh"
  let i=1
  while [ $i -le $n ]; # for all the inputs
  do
    if [ -e base.exe ]; then
      if [ ! -e $OUT_DIR/$bm.$i.bimodal.out ]; then # if not already generated (clean your OUT_DIR before generating new results)
		echo "$bm.$i"
    	  ulimit -s unlimited
		  touch $OUT_DIR/$bm.$i.time.out
#native run
    	  export PREFIX=""
        echo "PREFIX=$PREFIX" > $OUT_DIR/$bm.$i.time.out
    	  time (./run.$b.$i.sh) >> $OUT_DIR/$bm.$i.time.out 2>&1 # run the benchmark and capture runtime
    	  echo >> $bm.$i.time.out 2>&1 # empty line as a separator
#PINTOOL run
    	  export PREFIX="$PIN_ROOT/pin -t $PINTOOL  -statfile $OUT_DIR/$bm.$i.bimodal.out  -- "
        echo "PREFIX=$PREFIX" >> $OUT_DIR/$bm.$i.time.out
    	  time (./run.$b.$i.sh) >> $OUT_DIR/$bm.$i.time.out 2>&1 # run the pintool on the benchmark and capture runtime
      fi
    fi
    let i=i+1
  done
  cd ..
done
