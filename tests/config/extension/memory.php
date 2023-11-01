<?php
ini_set('memory_limit', '32M');


# file_put_contents(ini_get('memprof.output_dir').'/tmp.txt','test');

// memprof_enable();

register_shutdown_function(function(){
	memprof_dump_callgrind(fopen(ini_get('memprof.output_dir').'/tmp.txt', "w"));
	memprof_dump_pprof(fopen(ini_get('memprof.output_dir').'/tmp.heap', "w"));
});
echo 'X';
$arr = [];
while(true){
    $arr[] = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
}

echo 'Y';
