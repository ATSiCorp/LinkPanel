<!DOCTYPE html>
<html>
<head>
    <title>{{ $domain }}</title>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
        }
    </style>
</head>
<body>
	<center>
		<h4>{{ strtoupper(__('linkpanel.site')) }}</h4>
		<h1>{{ $domain }}</h1>
    </center>
	<br>
    <h3>SSH/SFTP</h3>
	<ul>
		<li><b>{{ __('linkpanel.host') }}</b> {{$ip}}</li>
		<li><b>{{ __('linkpanel.port') }}</b> 22</li>
		<li><b>{{ __('linkpanel.username') }}</b> {{$username}}</li>
        <li><b>{{ __('linkpanel.password') }}</b> {{$password}}</li>
        <li><b>{{ __('linkpanel.path') }}</b> /home/{{ $username }}/web/{{ $path }}</li>
	</ul>
	<br>
	<hr>
	<br>
	<h3>{{ __('linkpanel.database') }}</h3>
	<ul>
		<li><b>{{ __('linkpanel.host') }}</b> 127.0.0.1</li>
		<li><b>{{ __('linkpanel.port') }}</b> 3306</li>
		<li><b>{{ __('linkpanel.username') }}</b> {{$username}}</li>
		<li><b>{{ __('linkpanel.password') }}</b> {{$dbpass}}</li>
		<li><b>{{ __('linkpanel.name') }}</b> {{$username}}</li>
    </ul>
    <br>
	<hr>
    <br>
    <center>
        <p>{!! __('linkpanel.pdf_site_php_version', ['domain' => $domain, 'php' => $php]) !!}</p>
    </center>
    <br>
	<center>
		<p>{{ __('linkpanel.pdf_take_care') }}</p>
	</center>
    <br>
    <br>
	<br>
	<center>
		<h5>{{ config('linkpanel.name') }}<br>({{ config('linkpanel.website') }})</h5>
	</center>
</body>
</html>
