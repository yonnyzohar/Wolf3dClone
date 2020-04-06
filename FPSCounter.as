package {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.text.engine.EastAsianJustifier;
	import flash.display.Stage;

	public class FPSCounter {
		private static var startTime: Number;
		private static var framesNumber: Number = 0;
		private static var fps: TextField = new TextField();

		public function FPSCounter() {

		}

		public static function fpsCounter(_stage: Stage): void {
			startTime = getTimer();
			_stage.addChild(fps);

			_stage.addEventListener(Event.ENTER_FRAME, function (e: Event) {
				var currentTime: Number = (getTimer() - startTime) / 1000;

				framesNumber++;

				if (currentTime > 1) {
					fps.text = "FPS: " + (Math.floor((framesNumber / currentTime) * 10.0) / 10.0);
					startTime = getTimer();
					framesNumber = 0;
				}
			});
		}

		
	}
}