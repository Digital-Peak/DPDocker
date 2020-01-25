<?php
/**
 * @author     Digital Peak http://www.digital-peak.com
 * @copyright  Copyright (C) 2007 - 2020 Digital Peak. All rights reserved.
 * @license    http://www.gnu.org/licenses/gpl.html GNU/GPL
 */
?>
<html>
<head>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.min.css">
	<style>
		body {
			max-width: 1000px;
			margin-right: auto;
			margin-left: auto;
		}
	</style>
</head>
<body>
<h1>Welcome to the Joomla extension development web server</h1>
<p>More information can be found on <a href="https://github.com/Digital-Peak/DPDocker/tree/initial/webserver">Github</a>.</p>
<p>Here is the list of available sites:</p>
<ul>
	<li><a href="j">Patch release Joomla site with local extensions linked</a></li>
	<li><a href="dev">Feature release Joomla site with dev extensions linked</a></li>
	<li><a href="dev">Feature release Joomla site with dev extensions linked</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:81">PHPMyAdmin installation</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:82">Mailcatcher installation</a></li>
</ul>
</body>
</html>
