<?php
function compileAllPackages(){
	$rootPath=get_cfg_var('jetendo_root_path');
	$jsPath=$rootPath."public/javascript/";
	
	$arrJetendo=glob($jsPath."jetendo/*");
	for($i=0;$i<count($arrJetendo);$i++){
		$arrJetendo[$i]=str_replace($jsPath, "", $arrJetendo[$i]);
	}
	// everything
	$a=array('jquery/balupton-history/scripts/uncompressed/json2.js', 'zAjaxCycle.js', 'zCart.js', 'zForm-src.js');
	$a=array_merge($a, $arrJetendo);
	for($i=0;$i<count($a);$i++){
		$a[$i]=$jsPath.$a[$i];
	}
	$isCompiled=compileJS($a, "jetendo-no-listing.js");
	if(!$isCompiled){
		return false;
	}
	
	// no listing
	$arrListing=array('zListing-src.js');
	for($i=0;$i<count($arrListing);$i++){
		$arrListing[$i]=$jsPath.$arrListing[$i];
	}
	$a=array_merge($a, $arrListing);
	$isCompiled=compileJS($a, "jetendo.js");
	if(!$isCompiled){
		return false;
	}
	return true;
}
function compileJS($arrFiles, $outputFileName){
	// manually list the files we want to compress
	$rootPath=get_cfg_var("jetendo_root_path");
	$sourcePath=$rootPath."public/javascript/";
	$compilePath=$rootPath."public/javascript-compiled/";
	$arrLog=array("compileJS started at ".date('l jS \of F Y h:i:s A'));
	
	$arrMD5=array();
	$logDir=get_cfg_var("jetendo_log_path");
	$jsMD5Path=$logDir."deploy/compile-md5-".$outputFileName.".txt";
	if(file_exists($jsMD5Path)){
		$oldMD5Hash=md5_file($jsMD5Path);
	}else{
		$oldMD5Hash="";
	}
	$arrCompile=array();
	$arrNewFile=array();
	for($i=0;$i<count($arrFiles);$i++){
		$currentSourcePath=$arrFiles[$i];
		array_push($arrCompile, escapeshellarg($currentSourcePath));
		array_push($arrNewFile, $currentSourcePath."\t".md5_file($currentSourcePath));
	}
	$fp=fopen($jsMD5Path, "w");
	fwrite($fp, implode("\n", $arrNewFile));
	fclose($fp);
	if(count($arrCompile)){
		if(md5_file($jsMD5Path) != $oldMD5Hash){
			if(file_exists($compilePath.$outputFileName)){
				$oldMd5=md5_file($compilePath.$outputFileName);
				unlink($compilePath.$outputFileName);
			}else{
				$oldMd5="";
			}
			$cmd="java -jar ".$rootPath."scripts/closure-compiler.jar  --js ".implode(" --js ", $arrCompile)." --create_source_map ".$compilePath.$outputFileName.".map --source_map_format=V3 --js_output_file ".$compilePath.$outputFileName." 2>&1";
			array_push($arrLog, $cmd."\n");
			echo $cmd."\n\n";
			$r=`$cmd`;
			array_push($arrLog, $r."\n\n");
			if(!file_exists($compilePath.$outputFileName)){
				array_push($arrLog, "Compilation failed and requires manual corrections to the javascript.");
				unlink($jsMD5Path);
				return false;
			}else{
				file_put_contents($compilePath.$outputFileName, $data="//# sourceMappingURL=".$outputFileName.".map\n".file_get_contents($compilePath.$outputFileName));
				file_put_contents($compilePath.$outputFileName.".map", str_replace($rootPath."public/", "/z/", file_get_contents($compilePath.$outputFileName.".map")));
			}
		}
	}
	$fp=fopen(get_cfg_var("jetendo_log_path")."deploy/compile-js-css-log.txt", "a");
	fwrite($fp, implode("\n", $arrLog)."\n");
	fclose($fp);
	return true;
}
?>