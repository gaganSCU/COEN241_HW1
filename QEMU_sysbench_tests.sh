outputFile=$1
sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
touch $outputFile
> $outputFile
runCPU(){
	number=$1
	shift
	for i in {1..5}; do
		sysbench --test=cpu --cpu-max-prime=$number run | tail -n 2 | head -n 1 >> $outputFile
	done
}

runFileIO(){
	size=$1
	mode=$2
	shift
	for i in {1..5}; do
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw prepare
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw run >> $outputFile
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw cleanup
		sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
	done
}

echo "CPU Core Count" >> $outputFile
sudo lshw -c cpu | grep configuration >> $outputFile
echo "RAM Amount" >> $outputFile
sudo lshw -c memory | grep capacity >> $outputFile
echo "---CPU Tests---" >> $outputFile
echo "-----5000" >> $outputFile
runCPU 5000
echo "-----10000" >> $outputFile
runCPU 10000
echo "-----20000" >> $outputFile
runCPU 20000

echo "---------------------------------------------" >> $outputFile

echo "---File IO Tests---" >> $outputFile
echo "-----2G 128Files 16Threads" >> $outputFile
runFileIO 2G
echo "-----4G 128Files 16Threads" >> $outputFile
runFileIO 4G

