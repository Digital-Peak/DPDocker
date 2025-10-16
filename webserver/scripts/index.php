<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */
?>
<html>
<head>
	<style>
		/*! normalize.css v8.0.1 | MIT License | github.com/necolas/normalize.css */
		html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{display:list-item}template{display:none}[hidden]{display:none}
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
	<li><a href="j5">Patch release Joomla 5 site with local extensions linked</a> <a href="j5/administrator">(admin)</a>.</li>
	<li><a href="dev5">Feature release Joomla 5 site with dev extensions linked</a> <a href="dev5/administrator">(admin)</a>.</li>
	<li><a href="j6">Patch release Joomla 6 site with local extensions linked</a> <a href="j6/administrator">(admin)</a>.</li>
	<li><a href="dev6">Feature release Joomla 6 site with dev extensions linked</a> <a href="dev6/administrator">(admin)</a>.</li>
	<li><a href="play5">Joomla 5 playground</a> <a href="play5/administrator">(admin)</a>.</li>
	<li><a href="play6">Joomla 6 playground</a> <a href="play6/administrator">(admin)</a>.</li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:81">PHPMyAdmin installation</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:82">PostgresAdmin installation</a></li>
	<li><a href="//<?php echo $_SERVER['SERVER_NAME']; ?>:83">Mailcatcher installation</a></li>
</ul>
</body>
</html>
