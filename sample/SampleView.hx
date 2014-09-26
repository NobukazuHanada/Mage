package ;

import mage.CompileHTML;

@:build(mage.CompileHTML.generate(
'package sample.base;

<html lang="ja">
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" type="text/css" href="mage.css">
	<title>Mage Sample</title>
</head>
<body>
	<div mage-var="component"></div>	
</body>
</html>'
))
class BaseView{}

@:build(mage.CompileCSS.generate(
'package sample.view;

p { color : red; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view;

<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView{}


@:build(mage.CompileCSS.generate(
'package sample.view2;

p { color : blue; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view2;

<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView2{}