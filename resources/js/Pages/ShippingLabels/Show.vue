<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    label: {
        type: Object,
        required: true,
    },
});

const printLabel = () => {
    window.print();
};
</script>

<template>
    <Head title="Shipping Label" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-xl font-semibold leading-tight text-gray-800 dark:text-gray-200">
                Shipping Label
            </h2>
        </template>

        <div class="py-12">
            <div class="mx-auto max-w-7xl sm:px-6 lg:px-8">
                <div
                    v-if="successMessage"
                    class="mb-4 rounded-md bg-green-50 p-4 dark:bg-green-900/20"
                >
                    <p class="text-sm font-medium text-green-800 dark:text-green-200">
                        {{ successMessage }}
                    </p>
                </div>

                <div class="mb-4 flex items-center justify-between">
                    <Link
                        :href="route('shipping-labels.index')"
                        class="text-sm text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100"
                    >
                        ← Back to Labels
                    </Link>
                    <div class="space-x-2">
                        <PrimaryButton @click="printLabel">
                            Print Label
                        </PrimaryButton>
                    </div>
                </div>

                <div class="overflow-hidden bg-white shadow-sm sm:rounded-lg dark:bg-gray-800">
                    <div class="p-6">
                        <!-- Label Image -->
                        <div class="mb-6 flex justify-center print:block">
                            <img
                                :src="label.label_url"
                                alt="Shipping Label"
                                class="max-w-full border border-gray-300 dark:border-gray-700"
                            />
                        </div>

                        <!-- Label Details -->
                        <div class="grid gap-6 md:grid-cols-2 print:hidden">
                            <div>
                                <h3 class="mb-3 text-lg font-semibold text-gray-900 dark:text-gray-100">
                                    From Address
                                </h3>
                                <div class="space-y-1 text-gray-700 dark:text-gray-300">
                                    <p class="font-medium">{{ label.from_address.name }}</p>
                                    <p>{{ label.from_address.street1 }}</p>
                                    <p v-if="label.from_address.street2">{{ label.from_address.street2 }}</p>
                                    <p>
                                        {{ label.from_address.city }}, {{ label.from_address.state }}
                                        {{ label.from_address.zip }}
                                    </p>
                                    <p v-if="label.from_address.phone">{{ label.from_address.phone }}</p>
                                </div>
                            </div>

                            <div>
                                <h3 class="mb-3 text-lg font-semibold text-gray-900 dark:text-gray-100">
                                    To Address
                                </h3>
                                <div class="space-y-1 text-gray-700 dark:text-gray-300">
                                    <p class="font-medium">{{ label.to_address.name }}</p>
                                    <p>{{ label.to_address.street1 }}</p>
                                    <p v-if="label.to_address.street2">{{ label.to_address.street2 }}</p>
                                    <p>
                                        {{ label.to_address.city }}, {{ label.to_address.state }}
                                        {{ label.to_address.zip }}
                                    </p>
                                    <p v-if="label.to_address.phone">{{ label.to_address.phone }}</p>
                                </div>
                            </div>
                        </div>

                        <!-- Package Info -->
                        <div class="mt-6 border-t border-gray-200 pt-6 dark:border-gray-700 print:hidden">
                            <h3 class="mb-3 text-lg font-semibold text-gray-900 dark:text-gray-100">
                                Package Information
                            </h3>
                            <div class="grid gap-4 md:grid-cols-4">
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Dimensions</p>
                                    <p class="text-gray-900 dark:text-gray-100">
                                        {{ label.parcel_info.length }}" × {{ label.parcel_info.width }}" ×
                                        {{ label.parcel_info.height }}"
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Weight</p>
                                    <p class="text-gray-900 dark:text-gray-100">
                                        {{ label.parcel_info.weight }} lbs
                                    </p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Carrier</p>
                                    <p class="text-gray-900 dark:text-gray-100">{{ label.carrier }}</p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">Tracking</p>
                                    <p class="text-gray-900 dark:text-gray-100">
                                        {{ label.tracking_number || 'N/A' }}
                                    </p>
                                </div>
                            </div>
                            <div v-if="label.rate" class="mt-4">
                                <p class="text-sm text-gray-500 dark:text-gray-400">Shipping Rate</p>
                                <p class="text-lg font-semibold text-gray-900 dark:text-gray-100">
                                    ${{ parseFloat(label.rate).toFixed(2) }}
                                </p>
                            </div>
                        </div>

                        <!-- Created Date -->
                        <div class="mt-4 text-sm text-gray-500 dark:text-gray-400 print:hidden">
                            Created: {{ new Date(label.created_at).toLocaleString() }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style>
@media print {
    /* Hide navigation, header, and other non-essential elements */
    header,
    nav,
    .print\:hidden {
        display: none !important;
    }
    
    .print\:block {
        display: block !important;
    }
    
    /* Reset body and container styles for printing */
    body {
        margin: 0 !important;
        padding: 0 !important;
    }
    
    /* Remove padding and margins from main container */
    .py-12,
    .max-w-7xl,
    .sm\:px-6,
    .lg\:px-8,
    .p-6 {
        padding: 0 !important;
        margin: 0 !important;
    }
    
    /* Make the label container fill the page */
    .overflow-hidden,
    .shadow-sm,
    .sm\:rounded-lg {
        box-shadow: none !important;
        border-radius: 0 !important;
        overflow: visible !important;
    }
    
    /* Center the label image on the page */
    .mb-6 {
        margin-bottom: 0 !important;
    }
    
    /* Ensure label image is properly sized for printing */
    img {
        max-width: 100% !important;
        height: auto !important;
        page-break-after: avoid !important;
        page-break-inside: avoid !important;
    }
    
    /* Only show the label image when printing */
    .flex.justify-center.print\:block {
        display: flex !important;
        justify-content: center !important;
        align-items: center !important;
        min-height: 100vh !important;
    }
}
</style>

