<script setup>
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    canLogin: {
        type: Boolean,
    },
    canRegister: {
        type: Boolean,
    },
});
</script>

<template>
    <Head title="Welcome" />
    
    <div class="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-100 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <!-- Header Navigation -->
        <header class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pt-6">
            <nav class="flex items-center justify-between">
                <div class="flex items-center space-x-2">
                    <svg
                        class="h-8 w-8 text-indigo-600 dark:text-indigo-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
                        />
                    </svg>
                    <span class="text-xl font-bold text-gray-900 dark:text-white">
                        USPS Label Generator
                    </span>
                </div>
                
                <div v-if="canLogin" class="flex items-center space-x-4">
                    <Link
                        :href="route('login')"
                        class="px-4 py-2 text-sm font-medium text-gray-700 hover:text-indigo-600 dark:text-gray-300 dark:hover:text-indigo-400 transition-colors"
                    >
                        Log in
                    </Link>
                    <Link
                        v-if="canRegister"
                        :href="route('register')"
                        class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-md transition-colors shadow-sm"
                    >
                        Get Started
                    </Link>
                </div>
            </nav>
        </header>

        <!-- Hero Section -->
        <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
            <div class="text-center">
                <!-- Main Heading -->
                <h1 class="text-4xl font-extrabold tracking-tight text-gray-900 sm:text-5xl md:text-6xl dark:text-white">
                    <span class="block">Generate USPS</span>
                    <span class="block text-indigo-600 dark:text-indigo-400">Shipping Labels</span>
                    <span class="block">with Ease</span>
                </h1>
                
                <p class="mt-6 max-w-2xl mx-auto text-xl text-gray-600 dark:text-gray-300">
                    Create, manage, and print USPS shipping labels in minutes. 
                    Simple, secure, and designed for your shipping needs.
                </p>

                <!-- CTA Buttons -->
                <div v-if="canLogin" class="mt-10 flex flex-col sm:flex-row gap-4 justify-center items-center">
                    <Link
                        :href="route('register')"
                        class="w-full sm:w-auto px-8 py-3 text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-md shadow-lg hover:shadow-xl transition-all duration-200 transform hover:-translate-y-0.5"
                    >
                        Create Account
                    </Link>
                    <Link
                        :href="route('login')"
                        class="w-full sm:w-auto px-8 py-3 text-base font-medium text-indigo-600 bg-white hover:bg-gray-50 border-2 border-indigo-600 rounded-md transition-all duration-200 dark:text-indigo-400 dark:bg-gray-800 dark:border-indigo-400 dark:hover:bg-gray-700"
                    >
                        Sign In
                    </Link>
                </div>
            </div>

            <!-- Features Section -->
            <div class="mt-24">
                <div class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
                    <!-- Feature 1: Easy Label Creation -->
                    <div class="relative bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow dark:bg-gray-800">
                        <div class="flex items-center justify-center w-12 h-12 bg-indigo-100 rounded-lg dark:bg-indigo-900">
                            <svg
                                class="w-6 h-6 text-indigo-600 dark:text-indigo-400"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M12 4v16m8-8H4"
                                />
                            </svg>
                        </div>
                        <h3 class="mt-4 text-lg font-semibold text-gray-900 dark:text-white">
                            Easy Label Creation
                        </h3>
                        <p class="mt-2 text-sm text-gray-600 dark:text-gray-300">
                            Quickly generate USPS shipping labels with our intuitive interface. 
                            Just enter your addresses and package details.
                        </p>
                    </div>

                    <!-- Feature 2: Secure Storage -->
                    <div class="relative bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow dark:bg-gray-800">
                        <div class="flex items-center justify-center w-12 h-12 bg-indigo-100 rounded-lg dark:bg-indigo-900">
                            <svg
                                class="w-6 h-6 text-indigo-600 dark:text-indigo-400"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                                />
                            </svg>
                        </div>
                        <h3 class="mt-4 text-lg font-semibold text-gray-900 dark:text-white">
                            Secure & Private
                        </h3>
                        <p class="mt-2 text-sm text-gray-600 dark:text-gray-300">
                            Your shipping labels are securely stored and accessible only by you. 
                            View and print your labels anytime.
                        </p>
                    </div>

                    <!-- Feature 3: Label History -->
                    <div class="relative bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow dark:bg-gray-800">
                        <div class="flex items-center justify-center w-12 h-12 bg-indigo-100 rounded-lg dark:bg-indigo-900">
                            <svg
                                class="w-6 h-6 text-indigo-600 dark:text-indigo-400"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                                />
                            </svg>
                        </div>
                        <h3 class="mt-4 text-lg font-semibold text-gray-900 dark:text-white">
                            Complete History
                        </h3>
                        <p class="mt-2 text-sm text-gray-600 dark:text-gray-300">
                            Access your complete shipping label history. 
                            Track, view, and reprint labels whenever you need them.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Additional Info -->
            <div class="mt-20 bg-indigo-50 dark:bg-indigo-900/20 rounded-xl p-8 sm:p-12">
                <div class="max-w-3xl mx-auto text-center">
                    <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                        Ready to start shipping?
                    </h2>
                    <p class="mt-4 text-lg text-gray-600 dark:text-gray-300">
                        Join today and experience the simplest way to create and manage USPS shipping labels. 
                        All your shipping needs in one place.
                    </p>
                    <div v-if="canLogin && canRegister" class="mt-8">
                        <Link
                            :href="route('register')"
                            class="inline-block px-8 py-3 text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-md shadow-lg hover:shadow-xl transition-all duration-200"
                        >
                            Get Started Free
                        </Link>
                    </div>
                </div>
            </div>
        </main>

        <!-- Footer -->
        <footer class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8 border-t border-gray-200 dark:border-gray-700">
            <div class="text-center text-sm text-gray-600 dark:text-gray-400">
                <p>&copy; {{ new Date().getFullYear() }} USPS Label Generator. All rights reserved.</p>
            </div>
        </footer>
    </div>
</template>
