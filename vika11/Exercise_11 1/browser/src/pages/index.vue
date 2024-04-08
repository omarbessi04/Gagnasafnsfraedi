<template>
  <Login @success="$router.push('/main')"/>
</template>

<script lang="ts" setup>
import Login from '@/components/Login.vue';

</script>
