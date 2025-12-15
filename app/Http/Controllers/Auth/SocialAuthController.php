<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialAuthController extends Controller
{
    /**
     * Redirect the user to the Google authentication page.
     */
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->redirect();
    }

    /**
     * Obtain the user information from Google.
     */
    public function handleGoogleCallback()
    {
        try {
            $googleUser = Socialite::driver('google')->user();

            // Check if user already exists by google_id
            $user = User::where('google_id', $googleUser->id)->first();

            if ($user) {
                // User exists with Google account, ensure email is verified
                if (!$user->hasVerifiedEmail()) {
                    $user->email_verified_at = now();
                    $user->save();
                }
                Auth::login($user, true);
                return redirect()->route('dashboard');
            }

            // Check if user exists by email (for accounts created with email/password)
            $user = User::where('email', $googleUser->email)->first();

            if ($user) {
                // User exists with email but no google_id, link the accounts
                $user->google_id = $googleUser->id;
                $user->email_verified_at = now(); // Mark as verified when using Google
                $user->save();
                
                Auth::login($user, true);
                return redirect()->route('dashboard');
            }

            // User doesn't exist, create new account
            $user = User::create([
                'name' => $googleUser->name,
                'email' => $googleUser->email,
                'google_id' => $googleUser->id,
                'email_verified_at' => now(), // Google accounts are automatically verified
                'password' => null, // No password for Google OAuth users
            ]);

            Auth::login($user, true);

            return redirect()->route('dashboard');
        } catch (\Exception $e) {
            \Log::error('Google OAuth error: ' . $e->getMessage());
            return redirect('/login')->with('error', 'Unable to login with Google. Please try again.');
        }
    }
}
