(function(){
  var url = "https://babakzarrinbal.github.io/scripts/downloadttzipfile.js"
  var script = document.createElement('script');
  script.setAttribute('src',url);
  script.id ="bz-script";
  if(document.querySelector('#bz-script')) return window.bzfunction();
  script.onload=()=>{document.querySelector('#bz-loader').style.display='none';window.bzfunction();}
  var loaderStyle = `.lds-dual-ring {display: inline-block;width: 100px;height: 100px;}.lds-dual-ring:after {content: " ";display: block;width: 100px;height: 100px;border-radius: 50%;border: 10px solid #fff;border-color: #fff transparent #fff transparent;animation: lds-dual-ring 1.2s linear infinite;}@keyframes lds-dual-ring {0% {transform: rotate(0deg);} 100% {transform: rotate(360deg);}}`;
  var style=document.createElement('style');
  style.innerHTML = loaderStyle;
  document.head.appendChild(style);
  var loader = document.createElement('div');
  loader.id = "bz-loader";
  loader.style.cssText = `background-color:#808080c9;display:flex;align-items:center;justify-content:center;position:fixed;width:100vw;height:100vh;z-index:99999;top:0;left:0`;
  var spinner = document.createElement('div');
  spinner.classList.add('lds-dual-ring');
  loader.appendChild(spinner);
  document.body.appendChild(loader);
  document.head.appendChild(script);

})()