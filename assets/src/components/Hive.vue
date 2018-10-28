<template>
  <div class="container">
    <div class='hive'>
      <h1>{{ hey }}</h1>
    </div>
  </div>
</template>

<script>
export default {
  props: ['hey'],
  name: 'Hive',
};
</script>
