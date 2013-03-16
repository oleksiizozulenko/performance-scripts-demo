#!/bin/bash

DIRNAME=`dirname 0`

_USERS=1
#15 mins
_DURATION=1800

_RAMPUP=1
_START_DELAY=0
_SCENARIOS=""
_IS_SEND_EMAIL=1
_RUN_ENV_ID=""
TMP_DATE=`date +%s`
_RESULTS_DIR="${HOME}/performace-results/"

ANT_CMD="$DIRNAME/tools/ant/bin/ant"

_PERF_HOST="nis1-dev2.srvlan.local"
_PERF_PORT=4545
IS_PERFMON=true
IS_LOADOSOPHIA=false

#Enable for showing current cmd during debug
#echo ${*}

for i in $*
do
	case $i in
		--results-dir=*)
			_RESULTS_DIR_TMP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`

			if [[ -n $_RESULTS_DIR_TMP ]]; then
				_RESULTS_DIR=$_RESULTS_DIR_TMP
			fi
		;; 
		--perfmon=*)
			_PERFMON_TMP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`

			if [[ -n $_PERFMON_TMP ]]; then
				IS_PERFMON=$_PERFMON_TMP
			fi
		;; 
		--loadosophia=*)  
			_LOADOSOPHIA_TMP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`

			if [[ -n $_LOADOSOPHIA_TMP ]]; then
				IS_LOADOSOPHIA=$_LOADOSOPHIA_TMP
			fi
		;;  	
		--no-email*)
			_IS_SEND_EMAIL=0
			;;		
    	--users=*)
			_USERS=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
    	--duration=*)
			_DURATION=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
    	--rampup=*)
			_RAMPUP=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
		--delay=*)
			_START_DELAY=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
		--perf-host=*)
			_PERF_HOST=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
		--perf-port=*)
			_PERF_PORT=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
		--scenarios=*)
			_SCENARIOS=`echo $i | sed 's/[-a-zA-Z0-9]*=//' | sed 's/[,]/ /'`
		;;
		--env-id=*)
			_RUN_ENV_ID=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
		;;
		  	
  	esac
done

if [[ -z $_RUN_ENV_ID ]]; then
	echo "You should set env id for perform testing. Please choose one from config.properties"
	cat config.properties
	exit 1;
fi

chmod 775 $DIRNAME/tools/jmeter/bin/jmeter*

if [[ ! -d $_RESULTS_DIR ]]; then
		_RESULTS_DIR="${DIRNAME}/results_$TMP_DATE"
fi

mkdir ${_RESULTS_DIR}
cp -r ${DIRNAME}/jmeter.properties ${_RESULTS_DIR}/jmeter.properties

#Remove user properties
PROPERTY_FILE=system.properties
touch ${_RESULTS_DIR}/${PROPERTY_FILE}

echo "user.count=$_USERS" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "run.duration=$_DURATION" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "rampup.period=$_RAMPUP" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "perf.monitor.server=$_PERF_HOST" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "perf.monitor.port=$_PERF_PORT" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "startup.delay=$_START_DELAY" >> $_RESULTS_DIR/$PROPERTY_FILE

echo "is.enable.perf.monitor=$IS_PERFMON" >> $_RESULTS_DIR/$PROPERTY_FILE
echo "is.upload.loadosophia=$IS_LOADOSOPHIA" >> $_RESULTS_DIR/$PROPERTY_FILE


echo "This is current scenario properties:"
tail $_RESULTS_DIR/$PROPERTY_FILE

#------------------------------
function run_scenarios {
	echo "I run scenario $1"

	$ANT_CMD -DANT_OPTS="$JAVA_OPTS" -Drun.env.id=$_RUN_ENV_ID -Dresults.dir=$_RESULTS_DIR -f ${DIRNAME}/build.xml $1
}
#------------------------------

if [[ -z $_SCENARIOS ]]; then
	run_scenarios run-all
else
 	run_scenarios "${_SCENARIOS}"
fi

cd ${DIRNAME}
TIMESTAMP=`date +%s`

LAST_RESULTS_DIR=`ls -lrtR  $_RESULTS_DIR | grep 'results' | grep 'html' | awk 'END{ sub(":", "", $NF); print }'`

if [[ $_IS_SEND_EMAIL -eq 1 ]]; then
    #FIXME: Use better path to resutls because this one can return permission denied
	HTML_BODY_FILE="$LAST_RESULTS_DIR/../html.message.body.$TIMESTAMP.txt"
	rm -f $HTML_BODY_FILE
	cat $_RESULTS_DIR/$PROPERTY_FILE >> $HTML_BODY_FILE
	echo "" >> $HTML_BODY_FILE
	
	REPORT_FOR_SEND=""
	LAST_REPORTS_DIR="$LAST_RESULTS_DIR/"
	HTML_REPORTS=`ls -R $LAST_REPORTS_DIR`
	for html_report in $HTML_REPORTS; do
		echo " $LAST_REPORTS_DIR/$html_report" >> $HTML_BODY_FILE
		#echo "See directly: http://ciserver:8080/performance/$LAST_RESULTS_DIR/$html_report" >> $HTML_BODY_FILE
		echo "" >> $HTML_BODY_FILE

		if [[ $html_report==fullreport-* ]]; then
			REPORT_FOR_SEND=$html_report
		fi

	done

	echo "Also see last results on https://loadosophia.org/" >> $HTML_BODY_FILE

	EMAIL_RECIPIENTS="mymail@example.com -c mysecondmail@example.com"

	mutt -s "[Project][HTML] Quick report" $EMAIL_RECIPIENTS -a $LAST_REPORTS_DIR/$REPORT_FOR_SEND < $HTML_BODY_FILE
	rm -f $HTML_BODY_FILE
fi
