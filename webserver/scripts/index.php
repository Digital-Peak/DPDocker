<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
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
<p>More information can be found on <a href="https://github.com/Digital-Peak/DPDocker/tree/main/webserver">Github</a>.</p>
<p>Here is the list of available sites:</p>
<ul>
	<li><a href="j3">Patch release Joomla 3 site with local extensions linked</a> <a href="j3/administrator">(admin)</a>.</li>
	<li><a href="dev3">Feature release Joomla 3 site with dev extensions linked</a> <a href="dev3/administrator">(admin)</a>.</li>
	<li><a href="j4">Patch release Joomla 4 site with local extensions linked</a> <a href="j4/administrator">(admin)</a>.</li>
	<li><a href="dev4">Feature release Joomla 4 site with dev extensions linked</a> <a href="dev4/administrator">(admin)</a>.</li>
	<li><a href="j5">Patch release Joomla 5 site with local extensions linked</a> <a href="j5/administrator">(admin)</a>.</li>
	<li><a href="dev5">Feature release Joomla 5 site with dev extensions linked</a> <a href="dev5/administrator">(admin)</a>.</li>
	<li><a href="play3">Joomla 3 playground</a> <a href="play3/administrator">(admin)</a>.</li>
	<li><a href="play4">Joomla 4 playground</a> <a href="play4/administrator">(admin)</a>.</li>
	<li><a href="play5">Joomla 5 playground</a> <a href="play5/administrator">(admin)</a>.</li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:81">PHPMyAdmin installation</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:82">PostgresAdmin installation</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:83">Mailcatcher installation</a></li>
</ul>
</body>
</html>
