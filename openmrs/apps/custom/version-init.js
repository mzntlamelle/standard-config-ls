window.addEventListener("load", function () {
    let tries = 0;

    const interval = setInterval(function () {
      const loginBox =
        document.querySelector("form") ||
        document.body; // fallback so it's NEVER null

      if (!loginBox) return;

      if (window.BahmniVersionLabel?.mount) {
        const div = document.createElement("div");
        div.id = "bahmni-version-label-root";

        loginBox.appendChild(div);

        window.BahmniVersionLabel.mount(div);

        clearInterval(interval);
        console.log("Version label mounted");
      }

      tries++;
      if (tries > 20) clearInterval(interval);
    }, 500);
  });