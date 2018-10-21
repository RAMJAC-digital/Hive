import {
  CONNECT,
  TAKEOFF,
  LAND,
} from '../actions.type';

import {
  SET_BEE,
  SET_ERROR,
} from '../mutations.type';

const state = {
  flightData: null,
  message: null,
};
// getters
const getters = {
};

// actions
const actions = {
  [CONNECT](context, data) {
    context.commit(SET_BEE, data);
  },
  [TAKEOFF](context, data) {
    context.commit(SET_BEE, data);
  },
  [LAND](context, data) {
    context.commit(SET_BEE, data);
  },
};
// mutations
const mutations = {
  [SET_ERROR](state, error) {
    state.errors = error;
  },
  [SET_BEE](state, bee) {
    state.flightData = bee.flightData;
    state.errors = {};
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
