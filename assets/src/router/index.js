import Vue from 'vue';
import Router from 'vue-router';
import Hive from '@/components/Hive';

Vue.use(Router);

const hive = JSON.parse(document.getElementById('app').getAttribute('phoenix_data'));

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Hive',
      component: Hive,
      props: hive,
    },
  ],
});
