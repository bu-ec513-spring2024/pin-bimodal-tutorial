#!/bin/bash
export PATH=`pwd`/scripts/:$PATH
export SUFFIX="bimodal.out" # CHANGEME for branch predictor stats
#Icount: 64118977872 Mispredicts: 1417332797 MPKI: 22.104732
#References: 9909576197 Predicts: 8492243400

export OUT_DIR="/projectnb/ec513/students/ffayza/PIN/results/" #CHANGEME to your desired output directory

header_bimodal_stats() # CHANGEME for branch predictor stats
{
  echo "Benchmark.input Icount References Predicts MPKI native_time tool_time"
}

real2sec()
{
	hh=`echo $1 | sed '/h.*/s///'`
	if [ $hh == $1 ]; then
 		hh=0
	fi
	mm1=`echo $1 | sed '/m.*/s///'`
	mm=`echo $mm1 | sed '/.*h/s///'`
	if [ $mm == $1 ]; then
 		mm=0
	fi
	ss1=`echo $1 | sed '/s.*/s///'`
	ss=`echo $ss1 | sed '/.*m/s///'`
	echo "$hh*3600+$mm*60+$ss" | bc
}

parse_bimodal_stat() # CHANGEME for branch predictor stats
{
  icount=`grep Icount $1 | awk '{print $2}'`
  refs=`grep References $1 | awk '{print $2}'`
  preds=`grep Predicts $1 | awk '{print $4}'`
  MPKI=`grep MPKI $1 | awk '{print $6}'`
  echo -n " $icount $refs $preds $MPKI"
}

parse_time.out() 
{
  tnat=`grep real $1 | head -1 | awk '{print $2}'`
  ttool=`grep real $1 | tail -1 | awk '{print $2}'`
  rnat=`real2sec $tnat`
  rtool=`real2sec $ttool`
  echo " $rnat $rtool"
}


header_bimodal_stats


for b in `specrate.list`
do
  cd $b
  bm=`echo $b | awk -F"." '{print $2}'`
  n=`specratetrain_numinputs.sh $b` # using 'train' script here specratetrain_numinputs.sh
  let i=1
  while [ $i -le $n ]; 
  do
    if [ -e $OUT_DIR/$bm.$i.$SUFFIX ]; then 
      echo -n $bm.$i
      parse_bimodal_stat $OUT_DIR/$bm.$i.$SUFFIX
      parse_time.out $OUT_DIR/$bm.$i.time.out
    fi
    let i=i+1
  done
  cd ..
 done
