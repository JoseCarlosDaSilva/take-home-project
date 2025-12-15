# USPS Label Generator

Web application for generating and storing USPS shipping labels using the EasyPost API.

## About the Project

Web application developed to enable users to generate, view, and store USPS shipping labels. The system uses authentication via email/password or OAuth Google, with mandatory email verification for non-Google accounts.

## Tech Stack

- **Backend**: Laravel 12.x (PHP 8.2+)
- **Frontend**: Vue.js 3 + Inertia.js + TailwindCSS
- **Database**: MySQL 8.0+
- **Authentication**: Laravel Breeze + Laravel Socialite (OAuth Google)
- **External API**: EasyPost (label generation)

## Requirements

- PHP >= 8.2
- Composer
- Node.js >= 18.x
- MySQL >= 8.0
- NPM or Yarn

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd take-home-project
```

2. Install PHP dependencies:
```bash
composer install
```

3. Install Node dependencies:
```bash
npm install --legacy-peer-deps
```

4. Configure the environment:
```bash
cp .env.sample .env
php artisan key:generate
```

5. Configure the `.env` file with your credentials:
   - Remote MySQL connection
   - Google OAuth credentials (see `INSTRUCOES_GOOGLE_OAUTH.md`)
   - EasyPost API Key
   - Email settings

6. Run migrations:
```bash
php artisan migrate
```

7. Build assets:
```bash
npm run build
```

8. Start the development server:
```bash
php artisan serve
npm run dev
```

## Development Progress

### ✅ Phase 1: Initial Setup and Configuration (COMPLETED)

- ✅ Laravel 12 installed and configured
- ✅ Laravel Breeze with Vue.js installed (Inertia.js)
- ✅ Laravel Socialite installed for Google OAuth
- ✅ NPM dependencies installed
- ✅ `.env.sample` file created with all necessary configurations
- ✅ Google OAuth configuration documentation created (`INSTRUCOES_GOOGLE_OAUTH.md`)

### ✅ Phase 2: Complete Authentication System (COMPLETED)

- ✅ Email verification enabled (User model implements MustVerifyEmail)
- ✅ Google OAuth fully implemented with SocialAuthController
- ✅ Google login buttons added to Login and Register pages
- ✅ Automatic email verification for Google OAuth users
- ✅ Account linking: existing email accounts can be linked with Google
- ✅ Password recovery already included in Laravel Breeze
- ✅ Migration created for google_id column in users table
- ✅ Password field made nullable for Google OAuth users

### ✅ Phase 3: Label Creation Interface (COMPLETED)

- ✅ Create shipping label form with address inputs
- ✅ From and To address forms with US state dropdown
- ✅ Package attributes form (dimensions and weight)
- ✅ Form validation (frontend and backend)
- ✅ Responsive design with modern UI
- ✅ Integration with ShippingLabelController

### ✅ Phase 4: EasyPost API Integration (COMPLETED)

- ✅ EasyPost PHP SDK installed
- ✅ EasyPostService created for API interactions
- ✅ ShippingLabel model and migration created
- ✅ ShippingLabelController with CRUD operations
- ✅ Routes configured for shipping labels
- ✅ User isolation (users can only view their own labels)
- ✅ USPS-only validation (US addresses required)
- ✅ Integration with EasyPost API for label generation

- ⏳ Phase 5: Viewing and History
  - Label viewing
  - User-specific history

## Configuration

### Google OAuth Credentials

See the `docs/INSTRUCOES_GOOGLE_OAUTH.md` file for detailed instructions on how to obtain Google OAuth credentials.

### EasyPost API

1. Visit https://www.easypost.com/
2. Create an account (or use provided credentials)
3. Get your API Key (use test key during development)
4. Add to `.env`:
   ```
   EASYPOST_API_KEY=your_key_here
   ```

## Project Structure

```
take-home-project/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/
├── database/migrations/
├── resources/
│   ├── js/
│   │   ├── components/
│   │   └── Pages/
│   └── views/
├── routes/
└── tests/
```

## License

This project is open-source and available under the BSD-2-Clause license.
