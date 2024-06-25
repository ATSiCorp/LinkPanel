@extends('template')


@section('title')
    {{ __('linkpanel.titles.settings') }}
@endsection



@section('content')
<div class="row">
    <div class="col-xl-6">
        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-user fs-fw mr-1"></i>
                {{ __('linkpanel.change_username') }}
            </div>
            <div class="card-body">
                <p>{{ __('linkpanel.current_username') }}: <b><span id="currentuser"></span></b></p>
                <div class="input-group">
                    <input class="form-control" type="text" placeholder="{{ __('linkpanel.change_username_placeholder') }}" id="newuser" autocomplete="off" />
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="button" id="changeuser"><i class="fas fa-edit"></i></button>
                    </div>
                </div>
                <div class="space"></div>
            </div>
        </div>
    </div>
    <div class="col-xl-6">
        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-key fs-fw mr-1"></i>
                {{ __('linkpanel.change_password') }}
            </div>
            <div class="card-body">
                <p>{{ __('linkpanel.update_password') }}</p>
                <div class="input-group">
                    <input class="form-control" type="text" placeholder="{{ __('linkpanel.change_password_placeholder') }}" id="newpass" autocomplete="off" />
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="button" id="changepass"><i class="fas fa-edit"></i></button>
                    </div>
                </div>
                <div class="space"></div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-xl-6">
        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-globe fs-fw mr-1"></i>
                {{ __('linkpanel.panel_url') }}
            </div>
            <div class="card-body">
                <p>{{ __('linkpanel.panel_url_text') }}</p>
                <div class="input-group">
                    <input class="form-control" type="text" placeholder="panel.domain.ltd" id="panelurl" autocomplete="off" />
                    <div class="input-group-append">
                        <button class="btn btn-warning" type="button" id="panelurlssl" data-toggle="tooltip" data-placement="top" title="{{ __('linkpanel.panel_url_force_ssl') }}"><i class="fas fa-lock"></i></button>
                    </div>
                    <div class="input-group-append">
                        <button class="btn btn-primary" type="button" id="panelurlsubmit"><i class="fas fa-edit"></i></button>
                    </div>
                </div>
                <div class="space"></div>
            </div>
        </div>
    </div>
    <div class="col-xl-6">
        <div class="card mb-4">
            <div class="card-header">
                <i class="fas fa-code fs-fw mr-1"></i>
                {{ __('linkpanel.panel_api') }}
            </div>
            <div class="card-body">
                <p>{{ __('linkpanel.panel_api_endpoint') }}:  <b>{{ URL::to('/api/') }}</b></p>
                <div class="text-center">
                    <button class="btn btn-primary mr-3" type="button" id="newapikey">{{ __('linkpanel.renew_api_key') }}</button>
                    <a href="/api/docs" target="_blank">
                        <button class="btn btn-warning" type="button">{{ __('linkpanel.documentation') }}</button>
                    </a>
                </div>
                <div class="space"></div>
            </div>
        </div>
    </div>
</div>
@endsection



@section('extra')
<div class="modal fade" id="authorizeModal" tabindex="-1" role="dialog" aria-labelledby="authorizeModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="authorizeModalLabel">{{ __('linkpanel.action_authorization_modal_title') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>{{ __('linkpanel.action_authorization_modal_text') }}:</p>
                <div class="input-group">
                    <input class="form-control" type="password" id="currentpass" />
                </div>
                <div class="space"></div>
                <div class="text-center">
                    <button class="btn btn-primary" type="button" id="submit">{{ __('linkpanel.submit') }} <i class="fas fa-circle-notch fa-spin d-none" id="loading"></i></button>
                </div>
                <div class="space"></div>
            </div>
        </div>
    </div>
</div>
@endsection



@section('css')

@endsection



@section('js')
<script>
    //Username in Card
    $('#currentuser').html(localStorage.username);

    //Panel URL info
    $.ajax({
        url: '/api/servers/panel',
        type: 'GET',
        success: function(data) {
            $('#panelurl').val(data.domain);
        },
    });

    //Panel URL change
    $('#panelurlsubmit').click(function() {
        $.ajax({
            url: '/api/servers/panel/domain',
            type: 'PATCH',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify({
                'domain': $('#panelurl').val(),
            }),
            beforeSend: function() {
                $('#panelurlsubmit').html('<i class="fas fa-circle-notch fa-spin"></i>');
            },
            complete: function(data) {
                $('#panelurlsubmit').empty();
                $('#panelurlsubmit').html('<i class="fas fas fa-edit"></i>');
            },
        });
    });

    //Panel URL change
    $('#panelurlssl').click(function() {
        $.ajax({
            url: '/api/servers/panel/ssl',
            type: 'POST',
            beforeSend: function() {
                $('#panelurlssl').html('<i class="fas fa-circle-notch fa-spin"></i>');
            },
            complete: function(data) {
                $('#panelurlssl').empty();
                $('#panelurlssl').html('<i class="fas fas fa-lock"></i>');
            },
        });
    });

    //Username Patch
    $('#newuser').keyup(function() {
        $('#newuser').removeClass('is-invalid');
    });
    $('#changeuser').click(function() {
        userval = $('#newuser').val();
        if(!userval || userval.length < 6 || userval == localStorage.username) {
            $('#newuser').addClass('is-invalid');
        } else {
            $('#authorizeModal').modal();
            patchcall = 'changeuser';
        }
    });

    //Password Patch
    $('#newpass').keyup(function() {
        $('#newpass').removeClass('is-invalid');
    });
    $('#changepass').click(function() {
        passval = $('#newpass').val();
        if(!passval || passval.length < 8) {
            $('#newpass').addClass('is-invalid');
        } else {
            $('#authorizeModal').modal();
            patchcall = 'changepass';
        }
    });

    //API Key Renew
    $('#newapikey').click(function() {
        $('#authorizeModal').modal();
        patchcall = 'newapikey';
    });

    //Submit
    $('#submit').click(function() {
        oldpassval = $('#currentpass').val();
        if(!oldpassval || oldpassval.length < 8) {
            $('#newpass').addClass('is-invalid');
        } else {
            if(patchcall == 'changeuser') {
                calldata = {
                    username: localStorage.username,
                    password: $('#currentpass').val(),
                    newusername: $('#newuser').val()
                }
            }
            if(patchcall == 'changepass') {
                calldata = {
                    username: localStorage.username,
                    password: $('#currentpass').val(),
                    newpassword: $('#newpass').val()
                }
            }
            if(patchcall == 'newapikey') {
                calldata = {
                    username: localStorage.username,
                    password: $('#currentpass').val(),
                    apikey: true
                }
            }
            $.ajax({
                url: '/auth',
                type: 'PATCH',
                headers: {
                    'x-csrf-token': $('meta[name="csrf-token"]').attr('content'),
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                data: calldata,
                beforeSend: function() {
                    $('#loading').removeClass('d-none');
                },
                complete: function() {
                    $('#loading').addClass('d-none');
                },
                success: function(data) {
                    $('#newuser').val('');
                    $('#newpass').val('');
                    $('#currentpass').val('');
                    localStorage.access_token=data.access_token;
                    localStorage.refresh_token=data.refresh_token;
                    localStorage.username=data.username;
                    if(patchcall == 'changeuser') {
                        success('{{ __('linkpanel.username_updated_success') }}');
                        $('#currentuser').html(localStorage.username);
                        $('#username').html(localStorage.username);
                    }
                    if(patchcall == 'changepass') {
                        success('{{ __('linkpanel.password_updated_success') }}');
                    }
                    if(patchcall == 'newapikey') {
                        success('{{ __('linkpanel.new_api_key_success') }}:<br><b>'+data.apikey+'</b>');
                    }
                    $('#authorizeModal').modal("hide");
                    $(window).scrollTop(0);
                },
                error: function(error) {
                    if(error.status == 401) {
                        $('#currentpass').addClass('is-invalid');
                    } else {
                        $('#newuser').val('');
                        $('#newpass').val('');
                        $('#currentpass').val('');
                        fail('{{ __('linkpanel.unknown_error') }}');
                        $('#authorizeModal').modal("hide");
                    }
                }
            });
        }
    });

    //Old password validation reset
    $('#currentpass').keyup(function() {
        $('#currentpass').removeClass('is-invalid');
    });
</script>
@endsection
