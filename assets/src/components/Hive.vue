<template>
  <div class='hive'>
    <h1>{{ hey }}</h1>
  </div>
</template>

<script>
import 'game-controller';

export default {
  props: ['hey'],
  name: 'Hive',
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
