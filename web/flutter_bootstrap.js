// Configuration Flutter pour le Web
window.flutterConfiguration = {
  apiBaseUrl: 'http://localhost:8080',
  enableCorsProxy: true,
  debugMode: true
};

// Initialiser Flutter
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine({
        hostElement: document.querySelector('body'),
        renderer: 'canvaskit', // ou 'html' pour de meilleures performances
      });
      await appRunner.runApp();
    } catch (error) {
      console.error('❌ Flutter initialization failed:', error);
    }
  }
});