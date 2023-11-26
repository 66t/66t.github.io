//=============================================================================
// main.js
//=============================================================================



window.onload =  function () {
   Scene.run(Stage)
   init()
};
var sp
function init(){

   if(Scene.scene) {
      World.app.view.style.display="block"
      World.resize()

      let sp = new Shape(ImageManager.loadBitmap("img","back"+3))
      Scene.scene.addChild(sp);
   }
   else  
      setTimeout(()=>{init()},300)
}




