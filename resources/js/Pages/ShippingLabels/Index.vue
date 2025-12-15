<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    labels: {
        type: Object,
        required: true,
    },
});
</script>

<template>
    <Head title="Shipping Labels" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h2 class="text-xl font-semibold leading-tight text-gray-800 dark:text-gray-200">
                    Shipping Labels
                </h2>
                <Link :href="route('shipping-labels.create')">
                    <PrimaryButton>Create New Label</PrimaryButton>
                </Link>
            </div>
        </template>

        <div class="py-12">
            <div class="mx-auto max-w-7xl sm:px-6 lg:px-8">
                <div
                    v-if="labels.data.length === 0"
                    class="overflow-hidden bg-white shadow-sm sm:rounded-lg dark:bg-gray-800"
                >
                    <div class="p-6 text-center text-gray-900 dark:text-gray-100">
                        <p class="mb-4">No shipping labels created yet.</p>
                        <Link :href="route('shipping-labels.create')">
                            <PrimaryButton>Create Your First Label</PrimaryButton>
                        </Link>
                    </div>
                </div>

                <div v-else class="space-y-4">
                    <div
                        v-for="label in labels.data"
                        :key="label.id"
                        class="overflow-hidden bg-white shadow-sm transition hover:shadow-md sm:rounded-lg dark:bg-gray-800"
                    >
                        <div class="p-6">
                            <div class="flex items-start justify-between">
                                <div class="flex-1">
                                    <Link
                                        :href="route('shipping-labels.show', label.id)"
                                        class="block"
                                    >
                                        <div class="flex items-center space-x-4">
                                            <div class="flex-1">
                                                <div class="flex items-center space-x-2">
                                                    <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100">
                                                        {{ label.to_address.name }}
                                                    </h3>
                                                    <span
                                                        class="rounded-full bg-blue-100 px-2 py-1 text-xs font-medium text-blue-800 dark:bg-blue-900 dark:text-blue-200"
                                                    >
                                                        {{ label.carrier }}
                                                    </span>
                                                </div>
                                                <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                                                    {{ label.to_address.city }}, {{ label.to_address.state }}
                                                    {{ label.to_address.zip }}
                                                </p>
                                                <div class="mt-2 flex items-center space-x-4 text-xs text-gray-500 dark:text-gray-400">
                                                    <span v-if="label.tracking_number">
                                                        Tracking: {{ label.tracking_number }}
                                                    </span>
                                                    <span v-if="label.rate">
                                                        Rate: ${{ parseFloat(label.rate).toFixed(2) }}
                                                    </span>
                                                    <span>
                                                        Created: {{ new Date(label.created_at).toLocaleDateString() }}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </Link>
                                </div>
                                <div class="ml-4">
                                    <Link
                                        :href="route('shipping-labels.show', label.id)"
                                        class="text-indigo-600 hover:text-indigo-900 dark:text-indigo-400 dark:hover:text-indigo-300"
                                    >
                                        View →
                                    </Link>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Pagination -->
                    <div
                        v-if="labels.links && labels.links.length > 3"
                        class="mt-6 flex items-center justify-center space-x-2"
                    >
                        <template v-for="(link, index) in labels.links" :key="index">
                            <Link
                                v-if="link.url"
                                :href="link.url"
                                v-html="link.label"
                                :class="[
                                    'rounded-md px-3 py-2 text-sm font-medium',
                                    link.active
                                        ? 'bg-indigo-600 text-white'
                                        : 'bg-white text-gray-700 hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700',
                                ]"
                            />
                            <span
                                v-else
                                v-html="link.label"
                                class="rounded-md px-3 py-2 text-sm font-medium text-gray-500 dark:text-gray-400"
                            />
                        </template>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
