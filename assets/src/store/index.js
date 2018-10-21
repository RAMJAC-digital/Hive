import Vue from 'vue';
import Vuex from 'vuex';
import hive from './modules/hive';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    hive,
  },
  strict: false,
});
