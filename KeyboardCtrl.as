package {
	import flash.events.*;
	import flash.display.*;
	import flash.ui.Keyboard;

	public class KeyboardCtrl {

		public function KeyboardCtrl(stage: Stage) {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, myKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, myKeyUp);
		}

		function myKeyDown(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W) {
				Model.turnsObj.up = true;
				Model.turnsObj.down = false;
			}
			if (e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S) {

				Model.turnsObj.down = true;
				Model.turnsObj.up = false;
			}
			if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.D) {

				Model.turnsObj.left = true;
				Model.turnsObj.right = false;
			}
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.A) {

				Model.turnsObj.right = true;
				Model.turnsObj.left = false;
			}


			if (e.keyCode == Keyboard.G) {
				Model.G = true;
			}
			if (e.keyCode == Keyboard.H) {
				Model.H = true;
			}

			if (e.keyCode == Keyboard.N) {
				Model.N = true;
			}

			if (e.keyCode == Keyboard.B) {
				Model.B = true;
			}

			
		}

		function myKeyUp(e: KeyboardEvent): void {

			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W) {
				Model.turnsObj.up = false;
			}
			if (e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S) {

				Model.turnsObj.down = false;
			}
			if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.D) {

				Model.turnsObj.left = false;
			}
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.A) {

				Model.turnsObj.right = false;
			}
			

			if (e.keyCode == Keyboard.G) {
				Model.G = false;
			}
			if (e.keyCode == Keyboard.H) {
				Model.H = false;
			}

			if (e.keyCode == Keyboard.N) {
				Model.N = false;
			}

			if (e.keyCode == Keyboard.B) {
				Model.B = false;
			}

			
		}

	}

}