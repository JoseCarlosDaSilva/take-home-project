<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, useForm } from '@inertiajs/vue3';

const form = useForm({
    from_address: {
        name: '',
        street1: '',
        street2: '',
        city: '',
        state: '',
        zip: '',
        country: 'US',
        phone: '',
    },
    to_address: {
        name: '',
        street1: '',
        street2: '',
        city: '',
        state: '',
        zip: '',
        country: 'US',
        phone: '',
    },
    parcel_info: {
        length: '',
        width: '',
        height: '',
        weight: '',
    },
});

const submit = () => {
    form.post(route('shipping-labels.store'), {
        onSuccess: () => {
            // Redirect will be handled by Inertia automatically
        },
        onError: (errors) => {
            // Errors are automatically displayed by InputError components
            console.error('Form submission errors:', errors);
        },
    });
};

const usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY', 'DC'
];
</script>

<template>
    <Head title="Create Shipping Label" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-xl font-semibold leading-tight text-gray-800 dark:text-gray-200">
                Create Shipping Label
            </h2>
        </template>

        <div class="py-12">
            <div class="mx-auto max-w-7xl sm:px-6 lg:px-8">
                <div class="overflow-hidden bg-white shadow-sm sm:rounded-lg dark:bg-gray-800">
                    <div class="p-6 text-gray-900 dark:text-gray-100">
                        <!-- General error message -->
                        <div
                            v-if="form.errors.error || Object.keys(form.errors).length > 0 && !form.processing"
                            class="mb-6 rounded-md bg-red-50 p-4 dark:bg-red-900/20"
                        >
                            <p class="text-sm font-medium text-red-800 dark:text-red-200">
                                {{ form.errors.error || 'Please correct the errors below and try again.' }}
                            </p>
                        </div>

                        <form @submit.prevent="submit" class="space-y-8">
                            <!-- From Address -->
                            <div>
                                <h3 class="mb-4 text-lg font-medium text-gray-900 dark:text-gray-100">
                                    From Address
                                </h3>
                                <div class="grid gap-4 md:grid-cols-2">
                                    <div>
                                        <InputLabel for="from_name" value="Name *" />
                                        <TextInput
                                            id="from_name"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.name"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.name']" />
                                    </div>

                                    <div>
                                        <InputLabel for="from_phone" value="Phone" />
                                        <TextInput
                                            id="from_phone"
                                            type="tel"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.phone"
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.phone']" />
                                    </div>

                                    <div class="md:col-span-2">
                                        <InputLabel for="from_street1" value="Street Address 1 *" />
                                        <TextInput
                                            id="from_street1"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.street1"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.street1']" />
                                    </div>

                                    <div class="md:col-span-2">
                                        <InputLabel for="from_street2" value="Street Address 2" />
                                        <TextInput
                                            id="from_street2"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.street2"
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.street2']" />
                                    </div>

                                    <div>
                                        <InputLabel for="from_city" value="City *" />
                                        <TextInput
                                            id="from_city"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.city"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.city']" />
                                    </div>

                                    <div>
                                        <InputLabel for="from_state" value="State *" />
                                        <select
                                            id="from_state"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:focus:border-indigo-600 dark:focus:ring-indigo-600"
                                            v-model="form.from_address.state"
                                            required
                                        >
                                            <option value="">Select State</option>
                                            <option v-for="state in usStates" :key="state" :value="state">
                                                {{ state }}
                                            </option>
                                        </select>
                                        <InputError class="mt-2" :message="form.errors['from_address.state']" />
                                    </div>

                                    <div>
                                        <InputLabel for="from_zip" value="ZIP Code *" />
                                        <TextInput
                                            id="from_zip"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.from_address.zip"
                                            required
                                            maxlength="10"
                                        />
                                        <InputError class="mt-2" :message="form.errors['from_address.zip']" />
                                    </div>
                                </div>
                            </div>

                            <!-- To Address -->
                            <div class="border-t border-gray-200 pt-6 dark:border-gray-700">
                                <h3 class="mb-4 text-lg font-medium text-gray-900 dark:text-gray-100">
                                    To Address
                                </h3>
                                <div class="grid gap-4 md:grid-cols-2">
                                    <div>
                                        <InputLabel for="to_name" value="Name *" />
                                        <TextInput
                                            id="to_name"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.name"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.name']" />
                                    </div>

                                    <div>
                                        <InputLabel for="to_phone" value="Phone" />
                                        <TextInput
                                            id="to_phone"
                                            type="tel"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.phone"
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.phone']" />
                                    </div>

                                    <div class="md:col-span-2">
                                        <InputLabel for="to_street1" value="Street Address 1 *" />
                                        <TextInput
                                            id="to_street1"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.street1"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.street1']" />
                                    </div>

                                    <div class="md:col-span-2">
                                        <InputLabel for="to_street2" value="Street Address 2" />
                                        <TextInput
                                            id="to_street2"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.street2"
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.street2']" />
                                    </div>

                                    <div>
                                        <InputLabel for="to_city" value="City *" />
                                        <TextInput
                                            id="to_city"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.city"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.city']" />
                                    </div>

                                    <div>
                                        <InputLabel for="to_state" value="State *" />
                                        <select
                                            id="to_state"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:focus:border-indigo-600 dark:focus:ring-indigo-600"
                                            v-model="form.to_address.state"
                                            required
                                        >
                                            <option value="">Select State</option>
                                            <option v-for="state in usStates" :key="state" :value="state">
                                                {{ state }}
                                            </option>
                                        </select>
                                        <InputError class="mt-2" :message="form.errors['to_address.state']" />
                                    </div>

                                    <div>
                                        <InputLabel for="to_zip" value="ZIP Code *" />
                                        <TextInput
                                            id="to_zip"
                                            type="text"
                                            class="mt-1 block w-full"
                                            v-model="form.to_address.zip"
                                            required
                                            maxlength="10"
                                        />
                                        <InputError class="mt-2" :message="form.errors['to_address.zip']" />
                                    </div>
                                </div>
                            </div>

                            <!-- Parcel Info -->
                            <div class="border-t border-gray-200 pt-6 dark:border-gray-700">
                                <h3 class="mb-4 text-lg font-medium text-gray-900 dark:text-gray-100">
                                    Package Information
                                </h3>
                                <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                                    <div>
                                        <InputLabel for="length" value="Length (inches) *" />
                                        <TextInput
                                            id="length"
                                            type="number"
                                            step="0.1"
                                            min="0.1"
                                            class="mt-1 block w-full"
                                            v-model="form.parcel_info.length"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['parcel_info.length']" />
                                    </div>

                                    <div>
                                        <InputLabel for="width" value="Width (inches) *" />
                                        <TextInput
                                            id="width"
                                            type="number"
                                            step="0.1"
                                            min="0.1"
                                            class="mt-1 block w-full"
                                            v-model="form.parcel_info.width"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['parcel_info.width']" />
                                    </div>

                                    <div>
                                        <InputLabel for="height" value="Height (inches) *" />
                                        <TextInput
                                            id="height"
                                            type="number"
                                            step="0.1"
                                            min="0.1"
                                            class="mt-1 block w-full"
                                            v-model="form.parcel_info.height"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['parcel_info.height']" />
                                    </div>

                                    <div>
                                        <InputLabel for="weight" value="Weight (lbs) *" />
                                        <TextInput
                                            id="weight"
                                            type="number"
                                            step="0.1"
                                            min="0.1"
                                            class="mt-1 block w-full"
                                            v-model="form.parcel_info.weight"
                                            required
                                        />
                                        <InputError class="mt-2" :message="form.errors['parcel_info.weight']" />
                                    </div>
                                </div>
                            </div>

                            <div class="flex items-center justify-end space-x-4">
                                <a
                                    :href="route('shipping-labels.index')"
                                    class="rounded-md bg-gray-200 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-300 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
                                >
                                    Cancel
                                </a>
                                <PrimaryButton
                                    :class="{ 'opacity-25': form.processing }"
                                    :disabled="form.processing"
                                >
                                    Create Label
                                </PrimaryButton>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

