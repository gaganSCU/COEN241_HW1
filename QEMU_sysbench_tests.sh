sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
touch test_log.txt
> test_log.txt
runCPU(){
	number=$1
	shift
	for i in {1..5}; do
		sysbench --test=cpu --cpu-max-prime=$number run | tail -n 2 | head -n 1 >> test_log.txt
	done
}

runFileIO(){
	size=$1
	mode=$2
	shift
	for i in {1..5}; do
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw prepare #| head -n 3 | tail -n 1 >> test_log.txt
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw run >> test_log.txt #| tee >(head -n 8 | tail -n 2) >(tail -n 12 | head -n 1) >(tail -n 2 | head -n 1) | tail -n 2 >> test_log.txt
		sysbench --num-threads=16 --test=fileio --file-total-size=$size --file-test-mode=rndrw cleanup
		sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
	done
}

echo "---CPU Tests---" >> test_log.txt
echo "-----5000" >> test_log.txt
runCPU 5000
echo "-----10000" >> test_log.txt
runCPU 10000
echo "-----20000" >> test_log.txt
runCPU 20000

echo "---File IO Tests---" >> test_log.txt
echo "-----2G 128Files 16Threads" >> test_log.txt
runFileIO 2G
echo "-----4G 128Files 16Threads" >> test_log.txt
runFileIO 4G

