<?php

    return [

        // Panel Credential
        'username'          => env('LINKPANEL_USERNAME', 'atsilinkpanel'),
        'password'          => env('LINKPANEL_PASSWORD', 'adminpass-1230'),

        // JWT Settings
        'jwt_secret'        => env('JWT_SECRET', env('APP_KEY')),
        'jwt_access'        => env('JWT_ACCESS', 900),
        'jwt_refresh'       => env('JWT_REFRESH', 7200),

        // Custom Vars
        'name'              => env('LINKPANEL_NAME', 'LinkPanel Control Panel'),
        'website'           => env('LINKPANEL_WEBSITE', 'https://linkpanel.atsi.cloud'),
        'activesetupcount'  => env('LINKPANEL_ACTIVESETUPCOUNT', 'https://service.linkpanel.atsi.cloud/setupcount'),
        'documentation'     => env('LINKPANEL_DOCUMENTATION', 'https://linkpanel.atsi.cloud/docs.html'),
        'app'               => env('LINKPANEL_APP', 'https://play.google.com/store/apps/details?id=atsidev.linkpanel'),

        // Global Settings
        'users_prefix'      => env('LINKPANEL_USERS_PREFIX', 'cp'),
        'phpvers'           => ['8.3','8.2','8.1','8.0','7.4'],
        'services'          => ['nginx','php','mysql','redis','supervisor'],
        'default_php'       => '8.3',

    ];
