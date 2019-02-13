function getInBetween($start, $end, $source) {
	
	# if starting filter is longer than source string
	# then you cannot get the in between
	if ($source.Length < $start.Length){
		return -1
	}
	# find start position
	$dex=-1
	for ($i=0; $i < ($source.Length - $start.Length) ; $i++) {
		$tmp=$source.substring($i,$start.length)
		if ($tmp -eq $start){
			$dex=$i
			
			# end loop
			$i = $source.length
		}
	}
	$dex_end=-1
	for ($i=$dex; $i < ($source.Length - $end.Length) ; $i++) {
		$tmp=$source.substring($i,$end.length)
		if ($tmp -eq $end){
			$dex_end=$i
			
			return $source.substring($dex, $dex_end - $dex)
			
		}
	}
	# match not found
	return -1
}