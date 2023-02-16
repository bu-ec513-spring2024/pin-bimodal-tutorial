#!/bin/bash
export PATH=`pwd`/scripts:$PATH # must be run from the root of the train harness with scripts directory
export PIN_ROOT="/projectnb/ec513/students/ffayza/PIN/pin-3.26-98690-g1fc9d60e6-gcc-linux" #CHANGEME to your pin kit directory
export PINTOOL="/projectnb/ec513/students/ffayza/PIN/pintool_bimodal/obj-intel64/branch-predictor.so" #CHANGEME to your built pintool (so file)
export OUT_DIR="/projectnb/ec513/students/ffayza/PIN/pintool_tutorial/qsubresults/" #CHANGEME to your desired output directory


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
  while [ $i -le $n ]; 
  do
    if [ -e base.exe ]; then
      if [ ! -e $bm.$i.bimodal.out ]; then
        echo "#!/bin/bash -l" > run.$bm.$i.qsub.sh
        echo "PIN_ROOT=$PIN_ROOT" >> run.$bm.$i.qsub.sh
        echo "PINTOOL=$PINTOOL" >> run.$bm.$i.qsub.sh
		echo "OUT_DIR=$OUT_DIR" >> run.$bm.$i.qsub.sh
    	  echo "ulimit -s unlimited" >> run.$bm.$i.qsub.sh
#native run
    	  echo "export PREFIX=\"\""  >> run.$bm.$i.qsub.sh
        echo "echo \"PREFIX=\$PREFIX\" > $bm.$i.time.out"  >> run.$bm.$i.qsub.sh
    	  echo "time (./run.$b.$i.sh) >> $OUT_DIR/$bm.$i.time.out 2>&1"  >> run.$bm.$i.qsub.sh
    	  echo "echo >> $bm.$i.time.out 2>&1 # empty line as a separator"  >> run.$bm.$i.qsub.sh
#PINTOOL run
    	  echo "export PREFIX=\"\$PIN_ROOT/pin -t \$PINTOOL  -statfile $bm.$i.bimodal.out  -- \"" >> run.$bm.$i.qsub.sh
        echo "echo \"PREFIX=\$PREFIX\" >> $bm.$i.time.out" >> run.$bm.$i.qsub.sh
    	  echo "time (./run.$b.$i.sh) >> $OUT_DIR/$bm.$i.time.out 2>&1"  >> run.$bm.$i.qsub.sh
        chmod +x  run.$bm.$i.qsub.sh
        qsub run.$bm.$i.qsub.sh
      fi
    fi
    let i=i+1
  done
  cd ..
done
