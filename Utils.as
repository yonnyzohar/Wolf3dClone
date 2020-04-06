package {

	public class Utils {

		public static function hexToRGB(hex: Number, obj:Object): Object {
			obj.r= ((hex & 0xFF0000) >> 16),
			obj.g= ((hex & 0x00FF00) >> 8)
			obj.b= ((hex & 0x0000FF))
			

			return obj ;
		}
		
	
		public static function rgbToHex(r:uint,g:uint,b:uint): uint {
			return r << 16 | g << 8 | b;
		}

		public static function degFromRot(p_rotInput: Number): Number {
			var degOutput: Number = p_rotInput;
			while (degOutput >= 360) {
				degOutput -= 360;
			}
			while (degOutput < 0) {
				degOutput += 360;
			}
			return degOutput;
		}
		
		public static function radRotationFromRad(radAngle: Number):Number{
			while(radAngle < 0)
			{
				radAngle += Math.PI*2;
			}
			while(radAngle > Math.PI*2)
			{
				radAngle -= Math.PI*2;
			}
			return radAngle;
		}

		public static function rotFromDeg(p_degInput: Number): Number {
			var rotOutput: Number = p_degInput;
			while (rotOutput > 180) {
				rotOutput -= 360;
			}
			while (rotOutput < -180) {
				rotOutput += 360;
			}
			return rotOutput;
		}

		public static function degFromRad(p_radInput: Number): Number {
			var degOutput: Number = (180 / Math.PI) * p_radInput;
			return degOutput;
		}

		public static function radFromDeg(p_degInput: Number): Number {
			var radOutput: Number = (Math.PI / 180) * p_degInput;
			return radOutput;
		}
		public static function rotFromRad(p_radInput: Number): Number {
			return rotFromDeg(degFromRad(p_radInput));
		}

		public static function radFromRot(p_rotInput: Number): Number {
			return radFromDeg(degFromRot(p_rotInput));
		}

		public static function distanceTwoPoints(x1: Number, x2: Number, y1: Number, y2: Number): Number {
			var dx: Number = x1 - x2;
			var dy: Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}

	}

}