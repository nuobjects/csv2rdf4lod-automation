#!/bin/bash
#
#   Copyright 2012 Timothy Lebo
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#
#
# TODO: reconcile with bin/cr-pull-conversion-triggers.sh
#
#
#
# Synopsis:
#    Pull the conversion triggers in many conversion cockpits.
#
# Usage:

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set"
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

TEMP="_"`basename $0``date +%s`_$$.tmp

if [ "$1" == "--help" ]; then
   echo "usage: `basename $0` [-n]"
   echo "   -n:                    perform dry run only."
   echo "   --latest-version-only: only convert the latest version for each dataset (uses directory modification date)."
   exit 1
fi

dryRun="false"
if [[ "$1" == "-n" ]]; then
   dryRun="true"
   shift 
fi
#dryrun.sh $dryRun beginning

xargs="false"
if [[ "$1" == "-l" || "$1" == "--list" ]]; then
   xargs="true"
   shift 
fi

latest_version_only="no"
if [ "$1" == "--latest-version-only" ]; then
   latest_version_only="yes"
   shift
   # done before:
   #if [ "$latest_version_only" == "yes" ]; then
   #   versions=`cr-list-versions.sh | tail -1`
   #else
   #   versions=`cr-list-versions.sh`
   #fi
fi

# Find any script that looks like a conversion trigger.
for trigger in `find . -name "convert*.sh"`; do
   pushd `dirname $trigger` &> /dev/null
      # If the trigger is in a conversion cockpit
      if [[ `is-pwd-a.sh cr:conversion-cockpit` == "yes" ]]; then
         if [ "$dryRun" != "true" ]; then
            ./`basename $trigger`
         else
            if [ "$xargs" == "true" ]; then
               echo "`basename $trigger`"
            else
               echo "`cr-pwd.sh`: `basename $trigger`"
            fi
         fi
      fi
   popd &> /dev/null
done

#dryrun.sh $dryRun ending
