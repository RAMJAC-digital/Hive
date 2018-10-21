// NOTE: The contents of this file will only be executed if
// you uncomment its entry in 'assets/js/app.js'.

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in 'lib/web/endpoint.ex':
import { Socket } from 'phoenix';


const socket = new Socket('/hive');
// This is your plugin object. It can be exported to be used anywhere.
const HiveSocket = {
  // The install method is all that needs to exist on the plugin object.
  // It takes the global Vue object as well as user-defined options.
  install(Vue, options) {
    // We call Vue.mixin() here to inject functionality into all components.
    Vue.mixin({
      // Anything added to a mixin will be injected into all components.
      // In this case, the mounted() method runs when the component is added to the DOM.
      mounted() {
        socket.connect();
        console.log(options);

        // Now that you are connected, you can join channels with a topic:
        const channel = socket.channel('bee:bee1', {});
        channel.join();
      },
    });
  },
};

export default HiveSocket;
