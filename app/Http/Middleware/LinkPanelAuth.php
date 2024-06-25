<?php

namespace App\Http\Middleware;

use Closure;
use Exception;
use App\Models\Auth;
use Firebase\JWT\JWT;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Firebase\JWT\ExpiredException;

class LinkPanel
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        if($request->path() == 'api/login') {
            return $next($request);
        }

        $auth   = $request->header('Authorization');
        $token  = null;
        $apikey = null;

        if (Str::startsWith($auth, 'Bearer ')) {
            $token = Str::substr($auth, 7);
        }

        if (Str::startsWith($auth, 'Apikey ')) {
            $apikey = Str::substr($auth, 7);
        }

        if (!$token && !$apikey) {
            return response()->json([
                'message' => 'Authorization header missed in payload.',
                'errors' => 'Missing Authorization.'
            ], 422);
        }

        if ($token) {
            try {
                JWT::decode($token, config('linkpanel.jwt_secret').'-Acs', ['HS256']);
            } catch (ExpiredException $e) {
                return response()->json([
                    'message' => 'Given token is expired.',
                    'errors' => 'Expired token.'
                ], 401);
            } catch (Exception $e) {
                return response()->json([
                    'message' => 'Given token is invalid.',
                    'errors' => 'Invalid token.'
                ], 401);
            }
        }

        if ($apikey) {
            if (!Auth::where('apikey', $apikey)->first()) {
                return response()->json([
                    'message' => 'Given API Key is invalid.',
                    'errors' => 'Invalid API Key.'
                ], 401);
            }
        }

        return $next($request);
    }
}
