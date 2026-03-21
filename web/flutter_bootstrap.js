{{flutter_js}}
{{flutter_build_config}}

const splashElement = document.getElementById('app-splash');

function hideSplash() {
  if (!splashElement) {
    return;
  }
  splashElement.classList.add('app-splash--hidden');
  window.setTimeout(() => splashElement.remove(), 260);
}

window.addEventListener('flutter-first-frame', hideSplash, { once: true });

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    // 极端情况下如果 first-frame 事件没有触发，也确保 splash 会消失。
    window.setTimeout(hideSplash, 5000);
  }
});
