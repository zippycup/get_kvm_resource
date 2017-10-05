#!/bin/bash

all_host=`virsh list --all | egrep 'running|off' | awk '{print $2}'`
running_host=`virsh list --all | grep 'running' | awk '{print $2}'`

running_cpu=0
running_memory=0
all_cpu=0
all_memory=0

echo 'Running CPU'
for i in $running_host
do
  current_cpu=`virsh dominfo $i | grep 'CPU(s)' | awk '{print $2}'`
  echo "$i : ${current_cpu}"
  ((running_cpu=$running_cpu + $current_cpu))
done
echo

echo 'Allocated CPU'
for i in $all_host
do
  current_cpu=`virsh dominfo $i | grep 'CPU(s)' | awk '{print $2}'`
  echo "$i : ${current_cpu}"
  ((all_cpu=$all_cpu + $current_cpu))
done
echo

echo 'Running memory'
for i in $running_host
do
  current_memory=`virsh dominfo $i | grep 'Used memory' | awk '{print $3}'`
  echo "$i : ${current_memory}"
  ((running_memory=$running_memory + $current_memory))
done
echo


echo 'Allocated memory'
for i in $all_host
do
  current_memory=`virsh dominfo $i | grep 'Max memory' | awk '{print $3}'`
  echo "$i : ${current_memory}"
  ((all_memory=$all_memory + $current_memory))
done
echo

echo "Host summary"
virsh nodeinfo

host_cpu=`virsh nodeinfo | grep 'CPU(s)' | awk '{print $2}'`
host_memory=`virsh nodeinfo | grep 'Memory size' | awk '{print $3}'`

((reserve_memory=($host_memory - $running_memory) / 1000000 ))

echo "all_cpu        : ${all_cpu}"
echo "running_cpu    : ${running_cpu}"
echo "host_cpu       : ${host_cpu}"
echo
echo "all_memory     : ${all_memory} KiB"
echo "running_memory : ${running_memory} KiB"
echo "host_memory    : ${host_memory} KiB"
echo
echo "reserve memory : ${reserve_memory} Gb"
