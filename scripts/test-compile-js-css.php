<?php
// run this script via command line to debug the javascript compilation process.
// php test-compile-js.css.php
require("library.php");
require("compile-js-css.php");
$isCompiled=compileAllPackages();
echo $isCompiled;
?>